import '../models/desk.dart';

class DeskReservationClient {
  static const _desks = [
    Desk(id: 'D-01', name: 'Desk 01'),
    Desk(id: 'D-02', name: 'Desk 02'),
    Desk(id: 'D-03', name: 'Desk 03'),
    Desk(id: 'D-04', name: 'Desk 04'),
    Desk(id: 'D-05', name: 'Desk 05'),
    Desk(id: 'D-06', name: 'Desk 06'),
  ];

  final Map<String, Map<String, String>> _seedReservations;

  DeskReservationClient() : _seedReservations = _createSeed();

  static Map<String, Map<String, String>> _createSeed() {
    String k(DateTime d) =>
        "${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}";
    final today = DateTime.now();
    DateTime strip(DateTime d) => DateTime(d.year, d.month, d.day);
    return {
      k(strip(today))                         : {'D-01': 'Alice Pop', 'D-04': 'Mihai Ionescu'},
      k(strip(today).add(const Duration(days: 1))): {'D-02': 'Bogdan R.'},
      k(strip(today).add(const Duration(days: 3))): {'D-03': 'C. Marinescu', 'D-05': 'Ioana T.'},
    };
  }

  static DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);
  static String _key(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}";

  Future<List<Desk>> fetchDesks() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _desks;
  }

  Future<Map<String, String>> fetchReservationsFor(DateTime day) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final key = _key(_stripTime(day));
    return Map<String, String>.from(_seedReservations[key] ?? {});
  }

  /// Reserve a desk for a day. Throws if already reserved.
  Future<void> reserveDesk({
    required String deskId,
    required DateTime day,
    required String reserverName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final key = _key(_stripTime(day));
    _seedReservations.putIfAbsent(key, () => {});
    if (_seedReservations[key]![deskId] != null) {
      throw Exception('Desk is already reserved for this date.');
    }
    _seedReservations[key]![deskId] = reserverName;
  }
}