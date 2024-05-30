import 'dart:async';
import 'dart:html' as html;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_data.dart';
import 'package:weather_app/services/services.dart';

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
  final TextEditingController _storeNameController = TextEditingController(text: "The Mount Stuart - JD Wetherspoon");
  final TextEditingController _storeLocationController = TextEditingController(text: "Cardiff");
  final Services services = Services();

  List<List<dynamic>> _csvData = [];

  String _prediction = '';
  String csv = "";

  WeatherData? weatherData;

  bool _isLoadingCsv = false;
  bool _isLoadingWeather = false;
  bool _isLoadingPrediction = false;

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
    final location = _storeLocationController.text;
    if (location.isNotEmpty) {
      setState(() {
        _isLoadingWeather = true;
      });

      try {
        WeatherData wd = await services.fetchWeather(
          context: context,
          location: location,
        );

        setState(() {
          weatherData = wd;
          _isLoadingWeather = false;
        });
      } catch (e) {
        debugPrint(e.toString());
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

    final storeName = _storeNameController.text;
    final storeLocation = _storeLocationController.text;

    if (weatherData == null) {
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
      final data = await services.uploadAndPredict(
        context: context,
        weatherData: weatherData!, // nullable
        storeName: storeName,
        storeLocation: storeLocation,
        csvData: csvData,
      );

      setState(() {
        if (data.containsKey('predicted_sales')) {
          _prediction = data['predicted_sales'][0].toString();
        } else {
          _prediction = 'Error: Could not fetch prediction.';
        }
        _isLoadingPrediction = false;
      });
    } catch (e) {
      debugPrint('Exception: $e');
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
                      Text(_storeLocationController.text.isEmpty ? "No location data" : "location: ${_storeLocationController.text}"),
                      const SizedBox(height: 20),
                      weatherData == null
                          ? const Text("No Weather Data")
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("temperature: ${weatherData!.temperature}"),
                                Text("rain: ${weatherData!.additionalProperties['rain']}"),
                                Text("wind_speed: ${weatherData!.windSpeed}"),
                                Text("humidity: ${weatherData!.humidity}"),
                                Text("pressure: ${weatherData!.pressure}"),
                                Text("visibility: ${weatherData!.visibility}"),
                                Text("clouds: ${weatherData!.clouds}"),
                                Text("weather: ${weatherData!.weatherMain}"),
                              ],
                            ),
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
                        onPressed: _isLoadingPrediction
                            ? null
                            : () {
                                setState(() {
                                  _prediction = "";
                                });
                                _sendDataAndPredict();
                              },
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
