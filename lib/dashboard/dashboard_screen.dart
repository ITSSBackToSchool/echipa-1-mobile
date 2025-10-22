import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:seat_booking_mobile/dashboard/widgets/desk_card.dart';
import 'package:seat_booking_mobile/dashboard/widgets/weather_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'client/client.dart';
import 'models/desk.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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

  final _client = DeskReservationClient();

  List<Desk> _desks = const [];
  Map<String, String> _reservationsForSelected = const {};
  bool _isLoading = true;
  String? _error;

  static DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final desks = await _client.fetchDesks();
      final reservations = await _client.fetchReservationsFor(selectedDay);
      setState(() {
        _desks = desks;
        _reservationsForSelected = reservations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFor(DateTime date) async {
    setState(() {
      selectedDay = _stripTime(date);
      focusedDay = selectedDay;
      _isLoading = true;
      _error = null;
    });
    try {
      final reservations = await _client.fetchReservationsFor(selectedDay);
      setState(() {
        _reservationsForSelected = reservations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load reservations: $e';
        _isLoading = false;
      });
    }
  }

  String? _reserverFor(String deskId) => _reservationsForSelected[deskId];

  Future<void> _onTapDesk(Desk desk) async {
    final reserverName = await _showReserveDialog(context, desk, selectedDay);
    if (reserverName == null || reserverName.trim().isEmpty) return;

    // Show loading while calling reserve
    setState(() => _isLoading = true);
    try {
      await _client.reserveDesk(
        deskId: desk.id,
        day: selectedDay,
        reserverName: reserverName.trim(),
      );
      // Reload reservations for the same date
      final reservations = await _client.fetchReservationsFor(selectedDay);
      setState(() {
        _reservationsForSelected = reservations;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reserved ${desk.name} for $reserverName')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAlreadyReservedNotice(BuildContext context, Desk desk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${desk.name} is already reserved for '
          '${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
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
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (_desks.isEmpty) {
                  return const Center(child: Text('No desks available.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  itemCount: _desks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final desk = _desks[index];
                    final reserver = _reserverFor(desk.id);
                    final isFree = reserver == null;

                    return DeskCard(
                      desk: desk,
                      reserver: reserver,
                      isFree: isFree,
                      onTap: () {
                        if (isFree) {
                          _onTapDesk(desk);
                        } else {
                          _showAlreadyReservedNotice(context, desk);
                        }
                      }, // << trigger popup + reserve call
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
Future<String?> _showReserveDialog(
  BuildContext context,
  Desk desk,
  DateTime date,
) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) {
      bool isSubmitting = false;
      return StatefulBuilder(
        builder: (context, setLocalState) {
          return AlertDialog(
            title: Text('Reserve ${desk.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${date.day}/${date.month}/${date.year}'),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isSubmitting,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final name = controller.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your name'),
                            ),
                          );
                          return;
                        }
                        // Return the name to caller; actual reserve happens outside.
                        setLocalState(() => isSubmitting = true);
                        // Slight delay to show button disabled state in dialog
                        await Future.delayed(const Duration(milliseconds: 150));
                        // Close and return the name
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context, name);
                      },
                child: isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Reserve'),
              ),
            ],
          );
        },
      );
    },
  );
}
