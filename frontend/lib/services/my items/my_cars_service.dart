// lib/services/Main Screen/my_cars_service.dart
// --------------------------------------------------
// Servicio: obtiene todos los CarAvailable del usuario autenticado.
// --------------------------------------------------

import 'package:flutter/foundation.dart';

import '../../models/Main Screen/carAvailable.dart';
import '../requesthandler.dart';
import '../session_service.dart';

class MyCarsService {
  final RequestHandler _http = RequestHandler();
  final SessionService _session = SessionService();

  /// Devuelve la lista de autos cuyo `owner` coincide con el e‑mail del
  /// usuario autenticado. Lanza excepción si algo falla.
  Future<List<CarAvailable>> listMyCars() async {
    // 1) Cabecera con token
    final token = await _session.token;
    final headers = {'Authorization': 'Token $token'};

    // 2) Obtener JSON del usuario
    final userJson = await _http.getRequest('api/user/me/', headers: headers)
    as Map<String, dynamic>;
    final email = userJson['email'] as String;

    // 3) Obtener lista completa de autos
    final rawList = await _http.getRequest('api/rentals/list_cars/', headers: headers)
    as List<dynamic>;

    // 4) Filtrar por owner
    final cars = rawList
        .where((e) => e is Map<String, dynamic> && e['owner'] == email)
        .map<CarAvailable>((e) => CarAvailable.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    if (kDebugMode) {
      print('[MyCarsService] ${cars.length} autos encontrados para $email');
    }
    return cars;
  }
}
