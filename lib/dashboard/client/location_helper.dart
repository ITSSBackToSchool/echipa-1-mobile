import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<Position> currentPosition() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Location services are disabled.');
    }
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }
    return Geolocator.getCurrentPosition();
  }
}
