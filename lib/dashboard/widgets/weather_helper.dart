import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:seat_booking_mobile/dashboard/widgets/weather_widget.dart';

import '../client/location_helper.dart';
import '../client/weather_client.dart';
import '../models/weather_model.dart';

class WeatherSnippet extends StatefulWidget {
  const WeatherSnippet({super.key, required this.apiKey});

  final String apiKey;

  @override
  State<WeatherSnippet> createState() => _WeatherSnippetState();
}

class _WeatherSnippetState extends State<WeatherSnippet> {
  late final WeatherClient _client = WeatherClient(apiKey: widget.apiKey);
  WeatherInfo? _info;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _info = null;
      _error = null;
    });
    try {
      // Local (GPS) weather:
      final pos = await LocationHelper.currentPosition();
      final info = await _client.fetchCurrent(
        lat: pos.latitude,
        lon: pos.longitude,
      );

      // Or by city: final info = await _client.fetchByCity(city: 'Bucharest', countryCode: 'RO');

      setState(() => _info = info);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (kDebugMode) {
        print('Weather error: $_error');
      }
      return Text('Error');
    }
    if (_info == null) {
      return const SizedBox(
        height: 28,
        child: Center(
          child: SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return WeatherWidget(info: _info!);
  }
}
