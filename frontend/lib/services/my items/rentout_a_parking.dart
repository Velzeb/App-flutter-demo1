// lib/services/Main Screen/rentout_a_car_service.dart
// --------------------------------------------------
// Servicio para habilitar la renta de un auto, publicando
// su disponibilidad en el backend.
// --------------------------------------------------

import 'package:flutter/foundation.dart';

import '../../models/Main Screen/availability.dart';
import '../Requesthandler.dart';
import '../session_service.dart';

class RentOutParkingService {
  final RequestHandler _http = RequestHandler();
  final SessionService _session = SessionService();

  /// Publica un nuevo rango de disponibilidad para el auto [carId].
  /// Devuelve la instancia [Availability] creada.
  Future<Availability> rentOutParking({
    required int ParkingId,
    required DateTime start,
    required DateTime end,
  }) async {
    final token = await _session.token;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };

    // Construir payload según el API:
    final body = {
      'parking': ParkingId,
      'start_datetime': start.toIso8601String(),
      'end_datetime': end.toIso8601String(),
    };

    // Llamada HTTP POST
    final json = await _http.postRequest(
      'api/rentals/create_parking_availability/',
      data: body,
      headers: headers,
    ) as Map<String, dynamic>;

    if (kDebugMode) {
      debugPrint('[RentOutParkingService] Disponibilidad creada: \$json');
    }

    return Availability.fromJson(json);
  }
}
