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
  List<List<dynamic>> _csvData = [];
  String _prediction = '';
  // bool _isLoading = false;
  bool _isLoadingCsv = false;
  bool _isLoadingWeather = false;
  bool _isLoadingPrediction = false;
  String csv = "";
  double? temperature;
  double? rain;
  double? windSpeed;

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

      final weatherResponse = await http.get(
        Uri.parse('http://api.openweathermap.org/data/2.5/weather?q=$location&appid=773211ac46a8a3e591f72ae278de8280&units=metric'),
      );

      if (weatherResponse.statusCode == 200) {
        final weatherData = json.decode(weatherResponse.body);
        setState(() {
          temperature = weatherData['main']['temp'];
          rain = weatherData['rain'] != null ? weatherData['rain']['1h'] ?? 0 : 0;
          windSpeed = weatherData['wind']['speed'];
          _isLoadingWeather = false;
        });
      } else {
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
    if (temperature == null || rain == null || windSpeed == null) {
      setState(() {
        _prediction = 'Please fetch weather data first.';
      });
      return;
    }

    final csvData = const ListToCsvConverter().convert(_csvData);

    setState(() {
      _isLoadingPrediction = true;
    });

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/upload'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'location': _locationController.text,
        'temperature': temperature,
        'rain': rain,
        'wind_speed': windSpeed,
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
      setState(() {
        _prediction = 'Error: Could not fetch prediction.';
        _isLoadingPrediction = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Prediction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isLoadingCsv ? null : _loadCsvData,
                  child: _isLoadingCsv ? const CircularProgressIndicator() : const Text('Load Inventory'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isLoadingWeather ? null : _fetchWeatherData,
                  child: _isLoadingWeather ? const CircularProgressIndicator() : const Text('Fetch weather data'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isLoadingPrediction ? null : () => _sendDataAndPredict(),
                  child: _isLoadingPrediction ? const CircularProgressIndicator() : const Text('Predict Sales'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Text("Inventory Data", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text(csv.isEmpty ? 'No Data.' : csv),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Weather Data", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text(_locationController.text.isEmpty ? "No _locationController Data" : "location: ${_locationController.text}"),
                    Text(temperature == null ? "No temperature Data" : "temperature: $temperature"),
                    Text(rain == null ? "No rain Data" : "rain: $rain"),
                    Text(windSpeed == null ? "No windSpeed Data" : "wind_speed: $windSpeed"),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Prediction", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text(_prediction.isEmpty ? 'Click Predict Sales' : 'Predicted Sales: $_prediction'),
                  ],
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
