// lib/services/Main Screen/my_parkings_service.dart
// --------------------------------------------------
// Servicio: gestiona la obtención de los parqueos del usuario
// autenticado (filtrado por ID de propietario).
// --------------------------------------------------

import 'package:flutter/foundation.dart';

import '../../models/Main Screen/parkingAvailable.dart';
import '../requesthandler.dart';
import '../session_service.dart';

class MyParkingsService {
  final RequestHandler _http    = RequestHandler();
  final SessionService _session = SessionService();

  /// Devuelve la lista de [ParkingAvailable] cuyo `owner` coincide
  /// con el `pk` del usuario autenticado.
  Future<List<ParkingAvailable>> listMyParkings() async {
    // 1) Cabecera con token
    final token   = await _session.token;
    final headers = {'Authorization': 'Token $token'};

    // 2) Obtener ID del usuario
    final userJson = await _http.getRequest(
      'api/user/me/',
      headers: headers,
    ) as Map<String, dynamic>;
    final String email = userJson['email'] as String;

    // 3) Obtener lista completa de parqueos
    final rawList = await _http.getRequest(
      'api/rentals/list_parkings/',
      headers: headers,
    ) as List<dynamic>;

    // 4) Filtrar solo los parqueos cuyo owner == userId
    final parkings = rawList
        .where((e) => e is Map<String, dynamic> && e['owner'] == email)
        .map<ParkingAvailable>(
          (e) => ParkingAvailable.fromJson(e as Map<String, dynamic>),
    )
        .toList(growable: false);

    if (kDebugMode) {
      print('[MyParkingsService] ${parkings.length} parqueos para user $email');
    }
    return parkings;
  }


  // =================================================
  // ELIMINAR AUTO POR ID
  // =================================================
  Future<void> deleteParking(int id) async {
    final token = await _session.token;
    final headers = {'Authorization': 'Token $token'};

    await _http.deleteRequest(
      'api/rentals/parkings/$id/',
      headers: headers,
    );

    if (kDebugMode) {
      print('[MyParkingService] Auto $id eliminado');
    }
  }
  // =================================================
  // ACTUALIZAR AUTO POR ID (PUT multipart)
  // Devuelve el CarAvailable actualizado.
  // -------------------------------------------------

  Future<ParkingAvailable> updateCar(
      int id, {
        required Map<String, String> data,
        required Map<String, String> files,
      }) async {
    final token = await _session.token;
    final headers = {
      'Authorization': 'Token $token',
      // multipart lo maneja internamente, no definir Content-Type
    };

    final json = await _http.putMultipart(
      'api/rentals/parkings/$id/',
      data: data,
      files: files,
      headers: headers,
    ) as Map<String, dynamic>;

    final updated = ParkingAvailable.fromJson(json);
    if (kDebugMode) {
      print('[MyParkingService] Parking $id actualizado (multipart)');
    }
    return updated;
  }

}
