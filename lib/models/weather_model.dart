enum WeatherIcon { sun, cloud, rain, snow, thunder, fog, wind, unknown }

class WeatherInfo {
  final double tempC;
  final double feelsLike;
  final WeatherIcon icon;
  final String cityName;
  final String countryCode;
  final bool isNight; // true if it's nighttime

  const WeatherInfo({
    required this.tempC,
    required this.feelsLike,
    required this.icon,
    required this.cityName,
    required this.countryCode,
    required this.isNight,
  });
}
