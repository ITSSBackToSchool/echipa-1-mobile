class Reservation {
  final int id;
  final int seatId;
  final String? seatNumber;
  final String? roomName;
  final DateTime reservationDate;
  final String status;

  const Reservation({
    required this.id,
    required this.seatId,
    this.seatNumber,
    this.roomName,
    required this.reservationDate,
    required this.status,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final seatId = json['seatId'];
    final reservationDate = json['reservationDate'];
    final status = json['status'];

    if (id == null) {
      throw Exception('Reservation id is null: $json');
    }
    if (seatId == null) {
      throw Exception('Reservation seatId is null: $json');
    }
    if (reservationDate == null) {
      throw Exception('Reservation reservationDate is null: $json');
    }
    if (status == null) {
      throw Exception('Reservation status is null: $json');
    }

    return Reservation(
      id: id is int ? id : int.parse(id.toString()),
      seatId: seatId is int ? seatId : int.parse(seatId.toString()),
      seatNumber: json['seatNumber']?.toString(),
      roomName: json['roomName']?.toString(),
      reservationDate: DateTime.parse(reservationDate.toString()),
      status: status.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seatId': seatId,
      if (seatNumber != null) 'seatNumber': seatNumber,
      if (roomName != null) 'roomName': roomName,
      'reservationDate': reservationDate.toIso8601String().split('T')[0],
      'status': status,
    };
  }
}