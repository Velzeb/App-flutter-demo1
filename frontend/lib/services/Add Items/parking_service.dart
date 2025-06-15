// lib/services/parking_service.dart
// --------------------------------------------------
// Servicio: gestiona el registro de nuevos parqueos.
// Similar a CarService pero usando el endpoint `/api/rentals/register_parking/`.
// --------------------------------------------------

import '../../models/parking.dart';
import '../requesthandler.dart';
import '../session_service.dart';

class ParkingService {
  final RequestHandler _handler;
  final SessionService _session;

  ParkingService({String? baseUrl})
      : _handler = RequestHandler(baseUrlOverride: baseUrl),
        _session = SessionService();

  String get _authHeader {
    final token = _session.token;
    if (token == null || token.isEmpty) {
      throw Exception('Usuario no autenticado');
    }
    return 'Token $token';
  }

  /// Registra un nuevo estacionamiento.
  ///
  /// - [parking]: datos básicos del parqueo.
  /// - [imagePath]: ruta local del archivo de imagen a subir.
  ///
  /// Devuelve el objeto [Parking] creado desde la respuesta JSON.
  Future<Parking> registerParking({
    required Parking parking,
    required String imagePath,
  }) async {
    // Campos de texto
    final data = <String, String>{
      'name': parking.name,
      'address': parking.address,
      'description': parking.description,
      'hourly_rate': parking.hourlyRate,
      'is_active': parking.isActive.toString(),
    };

    // Archivos
    final files = <String, String>{
      'image': imagePath,
    };

    final response = await _handler.postMultipart(
      'api/rentals/register_parking/',
      headers: {'Authorization': _authHeader},
      data: data,
      files: files,
    );

    return Parking.fromJson(response as Map<String, dynamic>);
  }

/* ----------------------------------------------------------------------
   * TODO: métodos updateParking / deleteParking si el backend los expone.
   * -------------------------------------------------------------------- */
}
