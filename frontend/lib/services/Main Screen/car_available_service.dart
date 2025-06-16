// lib/services/car_available_service.dart

import '../../models/Main Screen/Availability.dart';
import '../../models/Main Screen/carAvailable.dart';
import '../session_service.dart';
import '../Requesthandler.dart';

class CarAvailableService {
  final RequestHandler _handler;

  CarAvailableService({String? baseUrl})
      : _handler = RequestHandler(baseUrlOverride: baseUrl);

  /// Token de sesión o lanza si no existe.
  String get _authToken {
    final token = SessionService().token;
    if (token == null || token.isEmpty) {
      throw Exception('Usuario no autenticado');
    }
    return token;
  }

  /// 1) Solo lista los autos disponibles (sin fechas).
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
          'Formato inválido: esperaba lista de autos, obtuvo ${response.runtimeType}');
    }

    return (response as List).map((e) {
      final json = e as Map<String, dynamic>;
      return CarAvailable(
        id: json['id'] as int,
        owner: json['owner'] as String,
        make: json['make'] as String,
        model: json['model'] as String,
        year: json['year'] as int,
        description: json['description'] as String,
        imageFront: Uri.parse(json['image_front'] as String),
        imageRear: Uri.parse(json['image_rear'] as String),
        imageInterior: Uri.parse(json['image_interior'] as String),
        registrationDocument:
        Uri.parse(json['registration_document'] as String),
        dailyRate: json['daily_rate'] as String,
        isActive: json['is_active'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        availability: [], // vacío por ahora
      );
    }).toList();
  }

  /// 2) Cuando el usuario hace tap, llama a este método para obtener las fechas.
  Future<List<Availability>> fetchCarAvailability(int carId) async {
    final headers = {
      'Authorization': 'Token ${_authToken}',
      'Content-Type': 'application/json',
    };

    final response = await _handler.getRequest(
      'api/rentals/list_car_availability/',
      headers: headers,
      params: {'car_id': carId.toString()},
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