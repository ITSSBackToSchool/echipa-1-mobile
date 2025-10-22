import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:seat_booking_mobile/dashboard/widgets/weather_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/seat.dart';
import '../services/api_client.dart';

class DashboardScreen extends StatefulWidget {
  final int buildingId;
  final String buildingName;
  final ApiClient apiClient;

  const DashboardScreen({
    super.key,
    required this.buildingId,
    required this.buildingName,
    required this.apiClient,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DateTime today = DateTime.now();
  late final DateTime oneMonthLater = DateTime(
    today.year,
    today.month + 1,
    today.day,
  );

  late DateTime selectedDay = DateTime(today.year, today.month, today.day);
  late DateTime focusedDay = DateTime(today.year, today.month, today.day);

  List<Seat> _seats = const [];
  bool _isLoading = true;
  String? _error;

  static DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _loadAvailableSeats();
  }

  Future<void> _loadAvailableSeats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final seats = await widget.apiClient.getAvailableSeats(
        date: selectedDay,
        buildingId: widget.buildingId,
      );
      setState(() {
        _seats = seats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load available seats: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFor(DateTime date) async {
    setState(() {
      selectedDay = _stripTime(date);
      focusedDay = selectedDay;
    });
    await _loadAvailableSeats();
  }

  Future<void> _onTapSeat(Seat seat) async {
    final confirmed = await _showReserveDialog(context, seat, selectedDay);
    if (confirmed != true) return;

    // Show loading while calling reserve
    setState(() => _isLoading = true);
    try {
      await widget.apiClient.createReservation(
        seatId: seat.id,
        reservationDate: selectedDay,
      );

      // Reload available seats for the same date
      await _loadAvailableSeats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reserved ${seat.seatNumber} successfully!')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reserve: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.buildingName} - Book a Seat',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: WeatherSnippet(apiKey: dotenv.env['WEATHER_API_KEY'] ?? '')),
          ),
        ],
      ),
      body: Column(
        children: [
          // ---- Week calendar ----
          TableCalendar(
            calendarFormat: CalendarFormat.week,
            firstDay: _stripTime(today),
            lastDay: oneMonthLater,
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            onDaySelected: (selected, _) => _loadFor(selected),
            onPageChanged: (focused) {
              focusedDay = _stripTime(focused);
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),

          const SizedBox(height: 8),

          // ---- Content area ----
          Expanded(
            child: Builder(
              builder: (context) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadAvailableSeats,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (_seats.isEmpty) {
                  return const Center(
                    child: Text('No seats available for this date.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  itemCount: _seats.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final seat = _seats[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.event_seat, size: 32),
                        title: Text(
                          seat.seatNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: seat.roomName != null
                            ? Text('Room: ${seat.roomName}')
                            : null,
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _onTapSeat(seat),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// -------- Reserve Dialog --------
Future<bool?> _showReserveDialog(
  BuildContext context,
  Seat seat,
  DateTime date,
) async {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirm Reservation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seat: ${seat.seatNumber}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (seat.roomName != null) ...[
              const SizedBox(height: 4),
              Text('Room: ${seat.roomName}'),
            ],
            const SizedBox(height: 8),
            Text('Date: ${date.day}/${date.month}/${date.year}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reserve'),
          ),
        ],
      );
    },
  );
}
