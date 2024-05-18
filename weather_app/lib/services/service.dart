import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String baseUrl;
  WeatherService({required this.baseUrl});

  Future<Map<String, dynamic>> fetchForecast(String location) async {
    final response = await http.get(Uri.parse('$baseUrl/forecast?location=$location'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
