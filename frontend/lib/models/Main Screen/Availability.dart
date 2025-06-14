// lib/models/availability.dart

class Availability {
  final DateTime start;
  final DateTime end;

  Availability({
    required this.start,
    required this.end,

  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      start: DateTime.parse(json['start_datetime'] as String),
      end: DateTime.parse(json['end_datetime'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
  };
}
