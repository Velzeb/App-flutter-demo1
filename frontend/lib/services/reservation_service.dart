// lib/services/reservation_service.dart


import '../models/reservation_car.dart';
import 'Requesthandler.dart';
import 'session_service.dart';

class ReservationService {
  final RequestHandler _handler;

  ReservationService({String? baseUrl})
      : _handler = RequestHandler(baseUrlOverride: baseUrl);

  String get _authToken {
    final t = SessionService().token;
    if (t == null || t.isEmpty) {
      throw Exception('Usuario no autenticado');
    }
    return t;
  }

  /// Crea una reserva en el endpoint POST api/rentals/book_car/
  Future<Reservation> bookCar({
    required int carId,
    required DateTime start,
    required DateTime end,
  }) async {
    final headers = {
      'Authorization': 'Token $_authToken',
      'Content-Type': 'application/json',
    };

    final data = Reservation(
      car: carId,
      startDatetime: start,
      endDatetime: end,
    ).toJson();

    final response = await _handler.postRequest(
      'api/rentals/book_car/',
      headers: headers,
      data: data,
    );

    if (response is Map<String, dynamic>) {
      return Reservation.fromJson(response);
    } else {
      throw Exception(
          'Respuesta inesperada al crear reserva: ${response.runtimeType}');
    }
  }
}
