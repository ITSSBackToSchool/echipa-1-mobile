import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/seat.dart';
import '../models/reservation.dart';
import '../models/building.dart';
import 'auth_service.dart';

class ApiClient {
  final AuthService _authService;
  late final String _baseUrl;

  ApiClient(this._authService) {
    _baseUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:8080';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get available seats for a specific date and building
  Future<List<Seat>> getAvailableSeats({
    required DateTime date,
    required int buildingId,
  }) async {
    final dateString = date.toIso8601String().split('T')[0];
    final url = Uri.parse(
        '$_baseUrl/api/seats/available?date=$dateString&buildingId=$buildingId');

    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      // Debug: Print the response
      if (kDebugMode) {
        print('API Response: ${response.body}');
      }

      final List<dynamic> data = json.decode(response.body);
      return data.map((json) {
        if (kDebugMode) {
          print('Parsing seat JSON: $json');
        }
        return Seat.fromJson(json);
      }).toList();
    } else {
      throw Exception(
          'Failed to load available seats: ${response.statusCode} ${response.body}');
    }
  }

  // Get all seats (without availability filter)
  Future<List<Seat>> getAllSeats() async {
    final url = Uri.parse('$_baseUrl/api/seats');

    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Seat.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load seats: ${response.statusCode}');
    }
  }

  // Create a new reservation
  Future<Reservation> createReservation({
    required int seatId,
    required DateTime reservationDate,
  }) async {
    final url = Uri.parse('$_baseUrl/api/reservations');
    final dateString = reservationDate.toIso8601String().split('T')[0];

    final requestBody = {
      'seatIds': [seatId], // Backend expects a List
      'reservationDate': dateString,
      'bookEntireRoom': false,
      // startTime and endTime are null for desk bookings (all-day)
    };

    if (kDebugMode) {
      print('Creating reservation - URL: $url');
      print('Request body: $requestBody');
    }

    final body = json.encode(requestBody);

    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: body,
    );

    if (kDebugMode) {
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final reservationsList = responseData['reservations'] as List;

      if (reservationsList.isEmpty) {
        throw Exception('No reservation created');
      }

      return Reservation.fromJson(reservationsList[0]);
    } else {
      throw Exception(
          'Failed to create reservation: ${response.statusCode} ${response.body}');
    }
  }

  // Get all user's reservations
  Future<List<Reservation>> getMyReservations() async {
    final url = Uri.parse('$_baseUrl/api/reservations');

    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // Response is wrapped: {reservations: [...]}
      final reservationsList = responseData['reservations'] as List;
      return reservationsList
          .map((json) => Reservation.fromJson(json))
          .toList();
    } else {
      throw Exception(
          'Failed to load reservations: ${response.statusCode}');
    }
  }

  // Cancel a reservation
  Future<void> cancelReservation(int reservationId) async {
    final url = Uri.parse('$_baseUrl/api/reservations/$reservationId');

    final response = await http.delete(url, headers: await _getHeaders());

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Failed to cancel reservation: ${response.statusCode}');
    }
  }

  Future<List<Building>> getBuildings() async {
    return const [
      Building(id: 1, name: 'T1'),
      Building(id: 2, name: 'T2'),
    ];
  }
}