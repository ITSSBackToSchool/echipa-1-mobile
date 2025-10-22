import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  late final Auth0 _auth0;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _idTokenKey = 'id_token';
  static const String _userIdKey = 'user_id';

  AuthService() {
    final domain = dotenv.env['AUTH0_DOMAIN']!;
    final clientId = dotenv.env['AUTH0_CLIENT_ID']!;

    _auth0 = Auth0(domain, clientId);
  }

  Future<bool> login() async {
    try {
      final credentials = await _auth0
          .webAuthentication(scheme: 'com.example.seatBookingMobile')
          .login(
            parameters: {
              'audience': 'https://api.deskops.com'
            },
          );

      // Store tokens securely
      await _storage.write(
          key: _accessTokenKey, value: credentials.accessToken);
      await _storage.write(key: _idTokenKey, value: credentials.idToken);
      await _storage.write(key: _userIdKey, value: credentials.user.sub);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth0
          .webAuthentication(scheme: 'com.example.seatBookingMobile')
          .logout();
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
    } finally {
      // Clear stored tokens regardless of logout success
      await _clearTokens();
    }
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _idTokenKey);
    await _storage.delete(key: _userIdKey);
  }
}