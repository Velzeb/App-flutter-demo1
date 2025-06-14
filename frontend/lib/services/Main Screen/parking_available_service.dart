// lib/services/parking_available_service.dart

import '../../models/Main Screen/Availability.dart';
import '../../models/Main Screen/parkingAvailable.dart';
import '../session_service.dart';
import '../Requesthandler.dart';

class ParkingAvailableService {
  final RequestHandler _handler;

  ParkingAvailableService({String? baseUrl})
      : _handler = RequestHandler(baseUrlOverride: baseUrl);

  /// Token de sesión o lanza si no existe.
  String get _authToken {
    final token = SessionService().token;
    if (token == null || token.isEmpty) {
      throw Exception('Usuario no autenticado');
    }
    return token;
  }

  /// 1) Lista todos los parqueos disponibles (sin fechas).
  Future<List<ParkingAvailable>> fetchAvailableParkings() async {
    final headers = {
      'Authorization': 'Token $_authToken',
      'Content-Type': 'application/json',
    };

    final response = await _handler.getRequest(
      'api/rentals/list_available_parkings/',
      headers: headers,
    );

    if (response is! List) {
      throw Exception(
          'Formato inválido: esperaba lista de parkings, obtuvo ${response.runtimeType}');
    }

    return (response as List).map((e) {
      final json = e as Map<String, dynamic>;
      return ParkingAvailable.fromJson(json);
    }).toList();
  }

  /// 2) Obtiene la disponibilidad de un parqueo (rangos de fecha/hora).
  Future<List<Availability>> fetchParkingAvailability(int parkingId) async {
    final headers = {
      'Authorization': 'Token $_authToken',
      'Content-Type': 'application/json',
    };

    final response = await _handler.getRequest(
      'api/rentals/list_parking_availability/',
      headers: headers,
      params: {'parking_id': parkingId.toString()},
    );

    if (response is! List) {
      throw Exception(
          'Formato inválido de disponibilidad: ${response.runtimeType}');
    }

    return (response as List)
        .map((e) => Availability.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
