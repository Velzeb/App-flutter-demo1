// lib/services/car_available_service.dart

import '../models/Availability.dart';
import '../models/carAvailable.dart';
import '../services/session_service.dart';
import 'Requesthandler.dart';

class CarAvailableService {
  final RequestHandler _handler;

  CarAvailableService({String? baseUrl})
      : _handler = RequestHandler(baseUrlOverride: baseUrl);

  /// Obtiene el token de sesión o lanza si no existe.
  String get _authToken {
    final token = SessionService().token;
    if (token == null || token.isEmpty) {
      throw Exception('Usuario no autenticado');
    }
    return token;
  }

  /// Obtiene la disponibilidad de un auto a partir de su [carId].
  Future<List<Availability>> fetchCarAvailability(int carId) async {
    final headers = {
      'Authorization': 'Token ${_authToken}',
      'Content-Type': 'application/json',
    };
    final response = await _handler.getRequest(
      'api/rentals/list_car_availability/',
      params: {'car_id': carId.toString()},
      headers: headers,
    );

    if (response is! List) {
      throw Exception(
          'Formato inválido de disponibilidad: esperado List, obtuvo ${response.runtimeType}');
    }

    return (response as List)
        .map((e) => Availability.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene los autos disponibles y les inyecta sus fechas de disponibilidad.
  Future<List<CarAvailable>> fetchAvailableCars() async {
    final headers = {
      'Authorization': 'Token ${_authToken}',
      'Content-Type': 'application/json',
    };
    final response = await _handler.getRequest(
      'api/rentals/list_available_cars/',
      headers: headers,
    );

    if (response is! List) {
      throw Exception(
          'Formato inválido de autos disponibles: esperado List, obtuvo ${response.runtimeType}');
    }

    final List<CarAvailable> cars = [];
    for (var item in response as List) {
      final data = item as Map<String, dynamic>;
      // 1) Obtiene las fechas para este auto
      final availability = await fetchCarAvailability(data['id'] as int);

      // 2) Construye la instancia con la disponibilidad
      cars.add(CarAvailable(
        id: data['id'] as int,
        owner: data['owner'] as int,
        make: data['make'] as String,
        model: data['model'] as String,
        year: data['year'] as int,
        description: data['description'] as String,
        imageFront: Uri.parse(data['image_front'] as String),
        imageRear: Uri.parse(data['image_rear'] as String),
        imageInterior: Uri.parse(data['image_interior'] as String),
        registrationDocument:
        Uri.parse(data['registration_document'] as String),
        dailyRate: data['daily_rate'] as String,
        isActive: data['is_active'] as bool,
        createdAt: DateTime.parse(data['created_at'] as String),
        updatedAt: DateTime.parse(data['updated_at'] as String),
        availability: availability,
      ));
    }

    return cars;
  }
}
