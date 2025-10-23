import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/weather_model.dart';

class WeatherClient {
  WeatherClient({required this.apiKey});
  final String apiKey;

  static const _currentBase = 'https://api.openweathermap.org/data/2.5/weather';

  /// Fetches current weather by latitude & longitude (metric units).
  Future<WeatherInfo> fetchCurrent({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.parse(
      '$_currentBase?lat=$lat&lon=$lon&units=metric&appid=$apiKey',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Weather API error: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    // Extract main temperature and weather condition
    final main = data['main'] as Map<String, dynamic>? ?? {};
    final weatherList = (data['weather'] as List?) ?? const [];
    final weather = weatherList.isNotEmpty ? weatherList.first as Map<String, dynamic> : {};
    final sys = data['sys'] as Map<String, dynamic>? ?? {};

    final double tempC = (main['temp'] as num?)?.toDouble() ?? 0.0;
    final double feelsLike = (main['feels_like'] as num?)?.toDouble() ?? tempC;
    final int? id = weather['id'] as int?;
    final String? group = weather['main'] as String?;
    final String? iconCode = weather['icon'] as String?; // e.g., "01d" or "01n"
    final String cityName = data['name'] as String? ?? 'Unknown';
    final String countryCode = sys['country'] as String? ?? '';

    // Check if it's night (icon code ends with 'n')
    final bool isNight = iconCode?.endsWith('n') ?? false;

    return WeatherInfo(
      tempC: tempC,
      feelsLike: feelsLike,
      icon: _mapToIcon(id: id, group: group),
      cityName: cityName,
      countryCode: countryCode,
      isNight: isNight,
    );
  }

  /// Maps OpenWeather condition codes to local WeatherIcon enums
  WeatherIcon _mapToIcon({int? id, String? group}) {
    if (id != null) {
      if (id >= 200 && id < 300) return WeatherIcon.thunder;
      if (id >= 300 && id < 600) return WeatherIcon.rain;
      if (id >= 600 && id < 700) return WeatherIcon.snow;
      if (id >= 700 && id < 800) return WeatherIcon.fog;
      if (id == 800) return WeatherIcon.sun;
      if (id > 800 && id < 900) return WeatherIcon.cloud;
    }

    switch ((group ?? '').toLowerCase()) {
      case 'clear':
        return WeatherIcon.sun;
      case 'clouds':
        return WeatherIcon.cloud;
      case 'rain':
      case 'drizzle':
        return WeatherIcon.rain;
      case 'snow':
        return WeatherIcon.snow;
      case 'thunderstorm':
        return WeatherIcon.thunder;
      case 'mist':
      case 'haze':
      case 'fog':
      case 'smoke':
      case 'dust':
        return WeatherIcon.fog;
      default:
        return WeatherIcon.unknown;
    }
  }
}
