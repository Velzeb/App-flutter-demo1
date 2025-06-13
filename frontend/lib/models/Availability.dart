// lib/models/availability.dart

class Availability {
  final DateTime start;
  final DateTime end;
  final bool isBooked;

  Availability({
    required this.start,
    required this.end,
    required this.isBooked,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      isBooked: json['is_booked'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'is_booked': isBooked,
  };
}
