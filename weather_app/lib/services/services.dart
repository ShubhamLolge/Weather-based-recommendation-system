import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather_data.dart';

String apiID = '773211ac46a8a3e591f72ae278de8280';
String flaskAPIuri = 'http://127.0.0.1:5000';
String weatherURI = 'http://api.openweathermap.org';

class Services {
  Future<Map<String, dynamic>> uploadAndPredict({
    required BuildContext context,
    required WeatherData weatherData,
    required String storeName,
    required String storeLocation,
    required String csvData,
  }) async {
    try {
      final data = {
        ...weatherData.toJson(),
        'store_name': storeName,
        'store_location': storeLocation,
        'csv_data': csvData,
      };

      http.Response res = await http.post(
        Uri.parse('$flaskAPIuri/upload'),
        body: jsonEncode(data),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        _httpErrorHandle(response: res, context: context);
        return {};
      }
    } catch (e) {
      debugPrint(e.toString());
      _showSnackbar(context: context, text: e.toString());
      return {};
    }
  }

  Future<WeatherData> fetchWeather({
    required BuildContext context,
    required String location,
  }) async {
    try {
      final weatherUrl = '$weatherURI/data/2.5/weather?q=$location&appid=$apiID&units=metric';

      // Make a GET request to the /weather endpoint
      http.Response res = await http.get(Uri.parse(weatherUrl));

      // Check if response is valid JSON
      if (res.headers['content-type']?.contains('application/json') == true) {
        final weatherData = json.decode(res.body);

        // Create WeatherData object
        final WeatherData weather = WeatherData(
          cityName: weatherData['name'],
          country: weatherData['sys']['country'],
          latitude: weatherData['coord']['lat'],
          longitude: weatherData['coord']['lon'],
          population: 0, // Add population if available
          sunrise: weatherData['sys']['sunrise'],
          sunset: weatherData['sys']['sunset'],
          timezone: weatherData['timezone'],
          temperature: weatherData['main']['temp'],
          feelsLike: weatherData['main']['feels_like'],
          humidity: weatherData['main']['humidity'],
          pressure: weatherData['main']['pressure'],
          visibility: weatherData['visibility'],
          windSpeed: weatherData['wind']['speed'],
          clouds: weatherData['clouds']['all'],
          weatherMain: weatherData['weather'][0]['main'],
          weatherDescription: weatherData['weather'][0]['description'],
          additionalProperties: {
            'rain': weatherData['rain']?['1h'] ?? 0,
            'wind_deg': weatherData['wind']['deg'],
            'wind_gust': weatherData['wind']['gust'],
          },
        );

        debugPrint("Weather data: $weather");
        return weather;
      } else {
        throw const FormatException('Invalid JSON response');
      }
    } catch (e) {
      debugPrint(e.toString());
      _showSnackbar(context: context, text: e.toString());
      throw e;
    }
  }

  void _httpErrorHandle({
    required http.Response response,
    required BuildContext context,
  }) {
    switch (response.statusCode) {
      case 400:
        _showSnackbar(context: context, text: jsonDecode(response.body)['msg']);
        break;
      case 500:
        _showSnackbar(context: context, text: jsonDecode(response.body)['error']);
        break;
      default:
        _showSnackbar(context: context, text: response.body);
    }
  }

  void _showSnackbar({
    required BuildContext context,
    required String text,
  }) {
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
