// lib/models/reservation_car.dart

class Reservation {
  final int car;
  final DateTime startDatetime;
  final DateTime endDatetime;

  // Campos que vienen en la respuesta
  final int? renter;
  final double? totalPrice;

  Reservation({
    required this.car,
    required this.startDatetime,
    required this.endDatetime,
    this.renter,
    this.totalPrice,
  });

  /// Para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'car': car,
      'start_datetime': startDatetime.toUtc().toIso8601String(),
      'end_datetime':   endDatetime.toUtc().toIso8601String(),
    };
  }

  /// Para parsear la respuesta del backend
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      car: json['car'] as int,
      startDatetime: DateTime.parse(json['start_datetime'] as String),
      endDatetime:   DateTime.parse(json['end_datetime']   as String),
      renter: json['renter'] as int?,
      totalPrice: json['total_price'] != null
          ? double.tryParse(json['total_price'].toString())
          : null,
    );
  }
}
