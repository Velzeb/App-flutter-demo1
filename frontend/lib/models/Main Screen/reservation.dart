// lib/models/reservation.dart


class Reservation {
  /// Id del auto (si la reserva es de auto)
  final int? car;

  /// Id del parqueo (si la reserva es de parqueo)
  final int? parking;

  /// Fecha / hora de inicio
  final DateTime startDatetime;

  /// Fecha / hora de fin
  final DateTime endDatetime;

  // --- Solo vienen en la respuesta ---
  final int? renter;
  final double? totalPrice;

  Reservation({
    this.car,
    this.parking,
    required this.startDatetime,
    required this.endDatetime,
    this.renter,
    this.totalPrice,
  }) : assert(
  // Debe indicarse uno y solo uno
  (car != null) ^ (parking != null),
  'Debes proporcionar exactamente uno de los campos: car o parking',
  );

  /// Mapa para enviar al backend (POST).
  Map<String, dynamic> toJson() {
    return {
      if (car != null) 'car': car,
      if (parking != null) 'parking': parking,
      'start_datetime': startDatetime.toUtc().toIso8601String(),
      'end_datetime':   endDatetime .toUtc().toIso8601String(),
    };
  }

  /// Crea la instancia a partir de la respuesta del backend.
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      car:      json['car']     as int?,
      parking:  json['parking'] as int?,
      startDatetime: DateTime.parse(json['start_datetime'] as String),
      endDatetime:   DateTime.parse(json['end_datetime']   as String),
      renter: json['renter'] as int?,
      totalPrice: json['total_price'] != null
          ? double.tryParse(json['total_price'].toString())
          : null,
    );
  }
}
