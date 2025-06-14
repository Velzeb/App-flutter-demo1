// lib/services/car_service.dart

import '../../models/car.dart';
import '../Requesthandler.dart';
import '../session_service.dart';

class CarService {
  final RequestHandler _handler;
  final SessionService _session;

  CarService({String? baseUrl})
      : _handler = RequestHandler(baseUrlOverride: baseUrl),
        _session = SessionService();


  String get _authHeader {
    final token = _session.token;
    if (token == null || token.isEmpty) {
      throw Exception('Usuario no autenticado');
    }
    return 'Token $token';
  }
  Future<Car> registerCar({
    required Car car,
    String? imageFrontPath,
    String? imageRearPath,
    String? imageInteriorPath,
    String? registrationDocumentPath,
  }) async {
    final response = await _handler.postMultipart(
      'api/rentals/register_car/',
      headers: {'Authorization': _authHeader},
      data: {
        'make': car.make,
        'model': car.model,
        'year': car.year.toString(),
        'daily_rate': car.dailyRate,
        if (car.description != null && car.description!.isNotEmpty)
          'description': car.description!,
        "is_active": car.isActive.toString(),
      },
      files: {
        if (imageFrontPath != null && imageFrontPath.isNotEmpty)
          'image_front': imageFrontPath,
        if (imageRearPath != null && imageRearPath.isNotEmpty)
          'image_rear': imageRearPath,
        if (imageInteriorPath != null && imageInteriorPath.isNotEmpty)
          'image_interior': imageInteriorPath,
        if (registrationDocumentPath != null &&
            registrationDocumentPath.isNotEmpty)
          'registration_document': registrationDocumentPath,
      },
    );

    return Car.fromJson(response as Map<String, dynamic>);
  }

  /* ----------------------------------------------------------------------
   * Listado de autos del usuario autenticado (READ)
   * -------------------------------------------------------------------- */

  /// Devuelve la lista de autos registrados por el usuario.
  Future<List<Car>> listUserCars() async {
    final response = await _handler.getRequest(
      'api/rentals/list_cars/',
      headers: {'Authorization': _authHeader},
    );

    return (response as List)
        .map<Car>((e) => Car.fromJson(e as Map<String, dynamic>))
        .toList();
  }

/* ----------------------------------------------------------------------
   * TODO: métodos updateCar / deleteCar.
   * -------------------------------------------------------------------- */
}

