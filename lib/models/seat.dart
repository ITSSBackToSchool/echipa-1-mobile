class Seat {
  final int id;
  final String seatNumber;
  final int? roomId;
  final String? roomName;
  final String? floorName;
  final String? buildingName;

  const Seat({
    required this.id,
    required this.seatNumber,
    this.roomId,
    this.roomName,
    this.floorName,
    this.buildingName,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase and snake_case
    final id = json['id'];
    final seatNumber = json['seatNumber'] ?? json['seat_number'];
    final roomId = json['roomId'] ?? json['room_id'];
    final roomName = json['roomName'] ?? json['room_name'];
    final floorName = json['floorName'] ?? json['floor_name'];
    final buildingName = json['buildingName'] ?? json['building_name'];

    if (id == null) {
      throw Exception('Seat id is null: $json');
    }
    if (seatNumber == null) {
      throw Exception('Seat seatNumber is null: $json');
    }

    return Seat(
      id: id is int ? id : int.parse(id.toString()),
      seatNumber: seatNumber.toString(),
      roomId: roomId != null
          ? (roomId is int ? roomId : int.parse(roomId.toString()))
          : null,
      roomName: roomName?.toString(),
      floorName: floorName?.toString(),
      buildingName: buildingName?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seatNumber': seatNumber,
      if (roomId != null) 'roomId': roomId,
      if (roomName != null) 'roomName': roomName,
      if (floorName != null) 'floorName': floorName,
      if (buildingName != null) 'buildingName': buildingName,
    };
  }
}