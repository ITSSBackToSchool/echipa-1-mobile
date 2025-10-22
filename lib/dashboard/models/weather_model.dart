enum WeatherIcon { sun, cloud, rain, snow, thunder, fog, wind, unknown }

class WeatherInfo {
  final double tempC;
  final WeatherIcon icon;
  const WeatherInfo({required this.tempC, required this.icon});
}
