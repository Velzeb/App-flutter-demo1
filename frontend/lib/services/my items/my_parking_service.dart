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
    final int userId = userJson['pk'] as int;

    // 3) Obtener lista completa de parqueos
    final rawList = await _http.getRequest(
      'api/rentals/list_parkings/',
      headers: headers,
    ) as List<dynamic>;

    // 4) Filtrar solo los parqueos cuyo owner == userId
    final parkings = rawList
        .where((e) => e is Map<String, dynamic> && e['owner'] == userId)
        .map<ParkingAvailable>(
          (e) => ParkingAvailable.fromJson(e as Map<String, dynamic>),
    )
        .toList(growable: false);

    if (kDebugMode) {
      print('[MyParkingsService] ${parkings.length} parqueos para user $userId');
    }
    return parkings;
  }
}
