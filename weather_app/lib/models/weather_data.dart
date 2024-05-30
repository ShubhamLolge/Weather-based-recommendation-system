import 'dart:convert';
import 'package:collection/collection.dart';

class WeatherData {
  // City and general information
  final String cityName; // Name of the city
  final String country; // Country code
  final double latitude; // Latitude of the city
  final double longitude; // Longitude of the city
  final int population; // Population of the city
  final int sunrise; // Sunrise time (UNIX timestamp)
  final int sunset; // Sunset time (UNIX timestamp)
  final int timezone; // Timezone offset in seconds

  // Weather information
  final double temperature; // Current temperature
  final double feelsLike; // Feels like temperature
  final int humidity; // Humidity percentage
  final int pressure; // Atmospheric pressure
  final int visibility; // Visibility in meters
  final double windSpeed; // Wind speed in meters/second
  final int clouds; // Cloudiness percentage
  final String weatherMain; // Main weather description (e.g., Rain)
  final String weatherDescription; // Detailed weather description

  // Additional less relevant properties stored in a map
  final Map<String, dynamic> additionalProperties;
  WeatherData({
    required this.cityName,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.population,
    required this.sunrise,
    required this.sunset,
    required this.timezone,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.visibility,
    required this.windSpeed,
    required this.clouds,
    required this.weatherMain,
    required this.weatherDescription,
    required this.additionalProperties,
  });

  WeatherData copyWith({
    String? cityName,
    String? country,
    double? latitude,
    double? longitude,
    int? population,
    int? sunrise,
    int? sunset,
    int? timezone,
    double? temperature,
    double? feelsLike,
    int? humidity,
    int? pressure,
    int? visibility,
    double? windSpeed,
    int? clouds,
    String? weatherMain,
    String? weatherDescription,
    Map<String, dynamic>? additionalProperties,
  }) {
    return WeatherData(
      cityName: cityName ?? this.cityName,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      population: population ?? this.population,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      timezone: timezone ?? this.timezone,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      humidity: humidity ?? this.humidity,
      pressure: pressure ?? this.pressure,
      visibility: visibility ?? this.visibility,
      windSpeed: windSpeed ?? this.windSpeed,
      clouds: clouds ?? this.clouds,
      weatherMain: weatherMain ?? this.weatherMain,
      weatherDescription: weatherDescription ?? this.weatherDescription,
      additionalProperties: additionalProperties ?? this.additionalProperties,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cityName': cityName,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'population': population,
      'sunrise': sunrise,
      'sunset': sunset,
      'timezone': timezone,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'pressure': pressure,
      'visibility': visibility,
      'windSpeed': windSpeed,
      'clouds': clouds,
      'weatherMain': weatherMain,
      'weatherDescription': weatherDescription,
      'additionalProperties': additionalProperties,
    };
  }

  factory WeatherData.fromMap(Map<String, dynamic> map) {
    return WeatherData(
      cityName: map['cityName'] as String,
      country: map['country'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      population: map['population'] as int,
      sunrise: map['sunrise'] as int,
      sunset: map['sunset'] as int,
      timezone: map['timezone'] as int,
      temperature: map['temperature'] as double,
      feelsLike: map['feelsLike'] as double,
      humidity: map['humidity'] as int,
      pressure: map['pressure'] as int,
      visibility: map['visibility'] as int,
      windSpeed: map['windSpeed'] as double,
      clouds: map['clouds'] as int,
      weatherMain: map['weatherMain'] as String,
      weatherDescription: map['weatherDescription'] as String,
      additionalProperties: Map<String, dynamic>.from(
        (map['additionalProperties'] as Map<String, dynamic>),
      ),
    );
  }

  // String toJson() => json.encode(toMap());

  // Method to convert WeatherData instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'city_name': cityName,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'population': population,
      'sunrise': sunrise,
      'sunset': sunset,
      'timezone': timezone,
      'temperature': temperature,
      'feels_like': feelsLike,
      'humidity': humidity,
      'pressure': pressure,
      'visibility': visibility,
      'wind_speed': windSpeed,
      'clouds': clouds,
      'weather_main': weatherMain,
      'weather_description': weatherDescription,
      'additional_properties': additionalProperties,
    };
  }

  factory WeatherData.fromJson(String source) => WeatherData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'WeatherData(cityName: $cityName, country: $country, latitude: $latitude, longitude: $longitude, population: $population, sunrise: $sunrise, sunset: $sunset, timezone: $timezone, temperature: $temperature, feelsLike: $feelsLike, humidity: $humidity, pressure: $pressure, visibility: $visibility, windSpeed: $windSpeed, clouds: $clouds, weatherMain: $weatherMain, weatherDescription: $weatherDescription, additionalProperties: $additionalProperties)';
  }

  @override
  bool operator ==(covariant WeatherData other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other.cityName == cityName &&
        other.country == country &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.population == population &&
        other.sunrise == sunrise &&
        other.sunset == sunset &&
        other.timezone == timezone &&
        other.temperature == temperature &&
        other.feelsLike == feelsLike &&
        other.humidity == humidity &&
        other.pressure == pressure &&
        other.visibility == visibility &&
        other.windSpeed == windSpeed &&
        other.clouds == clouds &&
        other.weatherMain == weatherMain &&
        other.weatherDescription == weatherDescription &&
        mapEquals(other.additionalProperties, additionalProperties);
  }

  @override
  int get hashCode {
    return cityName.hashCode ^
        country.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        population.hashCode ^
        sunrise.hashCode ^
        sunset.hashCode ^
        timezone.hashCode ^
        temperature.hashCode ^
        feelsLike.hashCode ^
        humidity.hashCode ^
        pressure.hashCode ^
        visibility.hashCode ^
        windSpeed.hashCode ^
        clouds.hashCode ^
        weatherMain.hashCode ^
        weatherDescription.hashCode ^
        additionalProperties.hashCode;
  }
}


// class WeatherData {
//   // City and general information
//   final String cityName; // Name of the city
//   final String country; // Country code
//   final double latitude; // Latitude of the city
//   final double longitude; // Longitude of the city
//   final int population; // Population of the city
//   final int sunrise; // Sunrise time (UNIX timestamp)
//   final int sunset; // Sunset time (UNIX timestamp)
//   final int timezone; // Timezone offset in seconds

//   // Weather information
//   final double temperature; // Current temperature
//   final double feelsLike; // Feels like temperature
//   final int humidity; // Humidity percentage
//   final int pressure; // Atmospheric pressure
//   final int visibility; // Visibility in meters
//   final double windSpeed; // Wind speed in meters/second
//   final int clouds; // Cloudiness percentage
//   final String weatherMain; // Main weather description (e.g., Rain)
//   final String weatherDescription; // Detailed weather description

//   // Additional less relevant properties stored in a map
//   final Map<String, dynamic> additionalProperties;

//   // Constructor
//   WeatherData({
//     required this.cityName,
//     required this.country,
//     required this.latitude,
//     required this.longitude,
//     required this.population,
//     required this.sunrise,
//     required this.sunset,
//     required this.timezone,
//     required this.temperature,
//     required this.feelsLike,
//     required this.humidity,
//     required this.pressure,
//     required this.visibility,
//     required this.windSpeed,
//     required this.clouds,
//     required this.weatherMain,
//     required this.weatherDescription,
//     required this.additionalProperties,
//   });

//   // Factory method to create WeatherData instance from JSON
//   factory WeatherData.fromJson(Map<String, dynamic> json) {
//     var city = json['city'];
//     var weatherList = json['list'][0];

//     return WeatherData(
//       cityName: city['name'],
//       country: city['country'],
//       latitude: city['coord']['lat'],
//       longitude: city['coord']['lon'],
//       population: city['population'],
//       sunrise: city['sunrise'],
//       sunset: city['sunset'],
//       timezone: city['timezone'],
//       temperature: weatherList['main']['temp'],
//       feelsLike: weatherList['main']['feels_like'],
//       humidity: weatherList['main']['humidity'],
//       pressure: weatherList['main']['pressure'],
//       visibility: weatherList['visibility'],
//       windSpeed: weatherList['wind']['speed'],
//       clouds: weatherList['clouds']['all'],
//       weatherMain: weatherList['weather'][0]['main'],
//       weatherDescription: weatherList['weather'][0]['description'],
//       additionalProperties: {
//         'grnd_level': weatherList['main']['grnd_level'],
//         'sea_level': weatherList['main']['sea_level'],
//         'temp_kf': weatherList['main']['temp_kf'],
//         'temp_max': weatherList['main']['temp_max'],
//         'temp_min': weatherList['main']['temp_min'],
//         'pop': weatherList['pop'],
//         'rain': weatherList['rain']?['3h'],
//         'pod': weatherList['sys']['pod'],
//         'wind_deg': weatherList['wind']['deg'],
//         'wind_gust': weatherList['wind']['gust'],
//       },
//     );
//   }

//   // Method to convert WeatherData instance to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'city_name': cityName,
//       'country': country,
//       'latitude': latitude,
//       'longitude': longitude,
//       'population': population,
//       'sunrise': sunrise,
//       'sunset': sunset,
//       'timezone': timezone,
//       'temperature': temperature,
//       'feels_like': feelsLike,
//       'humidity': humidity,
//       'pressure': pressure,
//       'visibility': visibility,
//       'wind_speed': windSpeed,
//       'clouds': clouds,
//       'weather_main': weatherMain,
//       'weather_description': weatherDescription,
//       'additional_properties': additionalProperties,
//     };
//   }
// }
