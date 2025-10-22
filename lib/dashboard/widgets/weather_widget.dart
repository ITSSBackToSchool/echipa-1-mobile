import 'package:flutter/material.dart';

import '../../models/weather_model.dart';

class WeatherWidget extends StatelessWidget {
  final WeatherInfo info;
  const WeatherWidget({super.key, required this.info});

  IconData _toIcon(WeatherIcon w) {
    switch (w) {
      case WeatherIcon.sun: return Icons.wb_sunny_rounded;
      case WeatherIcon.cloud: return Icons.cloud_rounded;
      case WeatherIcon.rain: return Icons.umbrella_rounded;
      case WeatherIcon.snow: return Icons.ac_unit_rounded;
      case WeatherIcon.thunder: return Icons.thunderstorm_rounded;
      case WeatherIcon.fog: return Icons.deblur_rounded; // fallback if foggy_rounded not available
      case WeatherIcon.wind: return Icons.air_rounded;
      case WeatherIcon.unknown: return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_toIcon(info.icon), size: 18),
          const SizedBox(width: 6),
          Text('${info.tempC.toStringAsFixed(0)}°C'),
        ],
      ),
    );
  }
}
