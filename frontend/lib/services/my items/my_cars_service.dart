// lib/services/Main Screen/my_cars_service.dart
// --------------------------------------------------
// Servicio: gestiona las operaciones CRUD para los autos del usuario
// autenticado (listar, eliminar, modificar con multipart).
// --------------------------------------------------

import 'package:flutter/foundation.dart';

import '../../models/Main Screen/carAvailable.dart';

import '../Requesthandler.dart';
import '../session_service.dart';

class MyCarsService {
  final RequestHandler _http = RequestHandler();
  final SessionService _session = SessionService();

  // =================================================
  // LISTAR AUTOS DEL USUARIO
  // =================================================
  Future<List<CarAvailable>> listMyCars() async {
    final token = await _session.token;
    final headers = {'Authorization': 'Token $token'};

    // 1. Obtener e-mail del usuario
    final userJson = await _http.getRequest(
      'api/user/me/',
      headers: headers,
    ) as Map<String, dynamic>;
    final email = userJson['email'] as String;

    // 2. Obtener lista completa de autos
    final rawList = await _http.getRequest(
      'api/rentals/list_cars/',
      headers: headers,
    ) as List<dynamic>;

    // 3. Filtrar solo los que pertenecen al usuario
    final cars = rawList
        .where((e) => e is Map<String, dynamic> && e['owner'] == email)
        .map<CarAvailable>(
          (e) => CarAvailable.fromJson(e as Map<String, dynamic>),
    )
        .toList(growable: false);

    if (kDebugMode) {
      print('[MyCarsService] ${cars.length} autos encontrados para $email');
    }
    return cars;
  }

  // =================================================
  // ELIMINAR AUTO POR ID
  // =================================================
  Future<void> deleteCar(int id) async {
    final token = await _session.token;
    final headers = {'Authorization': 'Token $token'};

    await _http.deleteRequest(
      'api/rentals/cars/$id/',
      headers: headers,
    );

    if (kDebugMode) {
      print('[MyCarsService] Auto $id eliminado');
    }
  }

  // =================================================
  // ACTUALIZAR AUTO POR ID (PUT multipart)
  // Devuelve el CarAvailable actualizado.
  // -------------------------------------------------
  // - `data`: campos de texto (make, model, year, description,
  //   daily_rate, is_active)
  // - `files`: rutas de archivos para image_front, image_rear,
  //   image_interior, registration_document
  // =================================================
  Future<CarAvailable> updateCar(
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
      'api/rentals/cars/$id/',
      data: data,
      files: files,
      headers: headers,
    ) as Map<String, dynamic>;

    final updated = CarAvailable.fromJson(json);
    if (kDebugMode) {
      print('[MyCarsService] Auto $id actualizado (multipart)');
    }
    return updated;
  }

}
