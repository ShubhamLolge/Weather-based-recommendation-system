// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'inventory_preview.dart';
import 'package:weather_app/services/service.dart';

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
      home: const InventoryPreviewPage(),
    );
  }
}

class InventoryPreviewPage extends StatefulWidget {
  const InventoryPreviewPage({super.key});

  @override
  InventoryPreviewPageState createState() => InventoryPreviewPageState();
}

class InventoryPreviewPageState extends State<InventoryPreviewPage> {
  List<List<dynamic>> _data = [];
  bool _isLoading = false;

  void _loadCsvData() async {
    setState(() {
      _isLoading = true;
    });

    final inventoryPreview = InventoryPreview();
    final data = await inventoryPreview.loadCsvFile();
    setState(() {
      _data = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Preview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : () => _loadCsvData(),
              child: _isLoading ? const CircularProgressIndicator() : const Text('Load CSV File'),
            ),
            const SizedBox(height: 20),
            _data.isEmpty
                ? const Text('No data loaded.')
                : Expanded(
                    child: ListView.builder(
                      itemCount: _data.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_data[index].join(', ')),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  WeatherPageState createState() => WeatherPageState();
}

class WeatherPageState extends State<WeatherPage> {
  final TextEditingController _controller = TextEditingController(text: "cardiff");
  final WeatherService weatherService = WeatherService(baseUrl: 'http://127.0.0.1:5000');
  String weatherInfo = '';

  void _fetchForecast() async {
    final location = _controller.text;
    if (location.isNotEmpty) {
      try {
        final weatherData = await weatherService.fetchForecast(location);
        setState(() {
          weatherInfo = weatherData.toString();
          // debugPrint(weatherInfo);
        });
      } catch (e) {
        setState(() {
          weatherInfo = 'Error fetching weather data';
        });
      }
    } else {
      setState(() {
        weatherInfo = 'Please enter a location';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Enter Location',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchForecast,
                child: const Text('Get Forecast'),
              ),
              const SizedBox(height: 20),
              Text(weatherInfo),
            ],
          ),
        ),
      ),
    );
  }
}
