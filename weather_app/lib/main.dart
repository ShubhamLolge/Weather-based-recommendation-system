// ignore_for_file: avoid_print, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory Preview',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SalesPredictionPage(),
    );
  }
}

class SalesPredictionPage extends StatefulWidget {
  const SalesPredictionPage({super.key});

  @override
  SalesPredictionPageState createState() => SalesPredictionPageState();
}

class SalesPredictionPageState extends State<SalesPredictionPage> {
  final TextEditingController _locationController = TextEditingController(text: "cardiff");
  final TextEditingController _storeNameController = TextEditingController(text: "The Mount Stuart - JD Wetherspoon");
  final TextEditingController _storeLocationController = TextEditingController(text: "Cardiff Bay");
  List<List<dynamic>> _csvData = [];
  String _prediction = '';
  bool _isLoadingCsv = false;
  bool _isLoadingWeather = false;
  bool _isLoadingPrediction = false;
  String csv = "";
  double? temperature;
  double? rain;
  double? windSpeed;
  int? humidity;
  int? pressure;
  int? visibility;
  int? clouds;
  String? weatherMain;

  void _loadCsvData() async {
    setState(() {
      _isLoadingCsv = true;
    });

    final inventoryPreview = InventoryPreview();
    final data = await inventoryPreview.loadCsvFile();
    final csvData = const ListToCsvConverter().convert(data);
    setState(() {
      _csvData = data;
      csv = csvData;
      _isLoadingCsv = false;
    });
  }

  Future<void> _fetchWeatherData() async {
    final location = _locationController.text;
    if (location.isNotEmpty) {
      setState(() {
        _isLoadingWeather = true;
      });

      try {
        final weatherUrl = 'http://api.openweathermap.org/data/2.5/weather?q=$location&appid=773211ac46a8a3e591f72ae278de8280&units=metric';
        print('Fetching weather data from: $weatherUrl'); // Debugging line

        final weatherResponse = await http.get(Uri.parse(weatherUrl));

        if (weatherResponse.statusCode == 200) {
          final weatherData = json.decode(weatherResponse.body);
          print('Weather data fetched successfully: $weatherData'); // Debugging line
          setState(() {
            temperature = weatherData['main']['temp'];
            rain = weatherData['rain'] != null ? weatherData['rain']['1h'] ?? 0 : 0;
            windSpeed = weatherData['wind']['speed'];
            humidity = weatherData['main']['humidity'];
            pressure = weatherData['main']['pressure'];
            visibility = weatherData['visibility'];
            clouds = weatherData['clouds']['all'];
            weatherMain = weatherData['weather'][0]['main'];
            _isLoadingWeather = false;
          });
        } else {
          throw Exception('Error fetching weather data: ${weatherResponse.body}');
        }
      } catch (e) {
        print(e);
        setState(() {
          _prediction = 'Error: Could not fetch weather data.';
          _isLoadingWeather = false;
        });
      }
    } else {
      setState(() {
        _prediction = 'Please enter a location';
      });
    }
  }

  Future<void> _sendDataAndPredict() async {
    if (_csvData.isEmpty) {
      setState(() {
        _prediction = 'Please upload inventory data first.';
      });
      return;
    }

    final location = _locationController.text;
    final storeName = _storeNameController.text;
    final storeLocation = _storeLocationController.text;

    if (temperature == null ||
        rain == null ||
        windSpeed == null ||
        humidity == null ||
        pressure == null ||
        visibility == null ||
        clouds == null ||
        weatherMain == null) {
      setState(() {
        _prediction = 'Please fetch weather data first.';
      });
      return;
    }

    final csvData = const ListToCsvConverter().convert(_csvData);

    setState(() {
      _isLoadingPrediction = true;
    });

    try {
      // Print the data being sent to the API
      print(
          'Sending data to Flask API: location: $location, temperature: $temperature, rain: $rain, wind_speed: $windSpeed, humidity: $humidity, pressure: $pressure, visibility: $visibility, clouds: $clouds, weather: $weatherMain, store_name: $storeName, store_location: $storeLocation, csv_data: $csvData');

      // Send data to Flask API
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/upload'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'location': location,
          'temperature': temperature,
          'rain': rain,
          'wind_speed': windSpeed,
          'humidity': humidity,
          'pressure': pressure,
          'visibility': visibility,
          'clouds': clouds,
          'weather_main': weatherMain,
          'store_name': storeName,
          'store_location': storeLocation,
          'csv_data': csvData,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _prediction = data['predicted_sales'][0].toString();
          _isLoadingPrediction = false;
        });
      } else {
        print('Error fetching prediction: ${response.body}'); // Debugging line
        setState(() {
          _prediction = 'Error: Could not fetch prediction.';
          _isLoadingPrediction = false;
        });
      }
    } catch (e) {
      print('Exception: $e'); // Print any exception that occurs
      setState(() {
        _prediction = 'Error: Could not fetch prediction.';
        _isLoadingPrediction = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Prediction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _storeNameController,
              decoration: const InputDecoration(labelText: 'Store Name'),
            ),
            TextField(
              controller: _storeLocationController,
              decoration: const InputDecoration(labelText: 'Store Location'),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Weather Location'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: size.height * 0.5,
                  width: size.width * 0.3,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: _isLoadingCsv ? null : _loadCsvData,
                          child: _isLoadingCsv ? const CircularProgressIndicator() : const Text('Load Inventory'),
                        ),
                        const SizedBox(height: 10),
                        const Text("Inventory Data", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Text(csv.isEmpty ? 'No Data.' : csv),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  height: size.height * 0.5,
                  width: size.width * 0.3,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: _isLoadingWeather ? null : _fetchWeatherData,
                        child: _isLoadingWeather ? const CircularProgressIndicator() : const Text('Fetch weather data'),
                      ),
                      const SizedBox(height: 10),
                      const Text("Weather Data", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Text(_locationController.text.isEmpty ? "No location data" : "location: ${_locationController.text}"),
                      Text(temperature == null ? "No temperature data" : "temperature: $temperature"),
                      Text(rain == null ? "No rain data" : "rain: $rain"),
                      Text(windSpeed == null ? "No wind speed data" : "wind_speed: $windSpeed"),
                      Text(humidity == null ? "No humidity data" : "humidity: $humidity"),
                      Text(pressure == null ? "No pressure data" : "pressure: $pressure"),
                      Text(visibility == null ? "No visibility data" : "visibility: $visibility"),
                      Text(clouds == null ? "No clouds data" : "clouds: $clouds"),
                      Text(weatherMain == null ? "No weather data" : "weather: $weatherMain"),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  height: size.height * 0.5,
                  width: size.width * 0.3,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: _isLoadingPrediction ? null : _sendDataAndPredict,
                        child: _isLoadingPrediction ? const CircularProgressIndicator() : const Text('Predict Sales'),
                      ),
                      const SizedBox(height: 10),
                      const Text("Prediction", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Text(_prediction.isEmpty ? 'Click Predict Sales' : 'Predicted Sales: $_prediction'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryPreview {
  Future<List<List<dynamic>>> loadCsvFile() async {
    final completer = Completer<List<List<dynamic>>>();
    final input = html.FileUploadInputElement()..accept = '.csv';
    input.click();

    input.onChange.listen((e) {
      final reader = html.FileReader();
      reader.readAsText(input.files!.first);
      reader.onLoadEnd.listen((e) {
        final csvData = reader.result as String;
        final List<List<dynamic>> data = const CsvToListConverter().convert(csvData);
        completer.complete(data);
      });
    });

    return completer.future;
  }
}
