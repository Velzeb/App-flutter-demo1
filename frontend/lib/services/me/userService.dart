// lib/services/user_service.dart
// --------------------------------------------------
// Servicio: obtiene y modifica el perfil del usuario autenticado.
// Endpoints:
//  GET  api/user/me/
//  PATCH api/user/me/
// --------------------------------------------------

import 'package:flutter/foundation.dart';

import '../../models/user.dart';
import '../Requesthandler.dart';
import '../session_service.dart';

class UserService {
  final RequestHandler _http = RequestHandler();
  final SessionService _session = SessionService();

  /// Obtiene los datos del usuario en sesión.
  Future<User> fetchCurrentUser() async {
    final token = _session.token;
    if (token == null) throw Exception('No autenticado');
    final headers = {'Authorization': 'Token $token'};

    final json = await _http.getRequest(
      'api/user/me/',
      headers: headers,
    ) as Map<String, dynamic>;

    if (kDebugMode) {
      debugPrint('[UserService] fetchCurrentUser → $json');
    }
    return User.fromJson(json);
  }

  /// Actualiza el perfil del usuario.
  /// Solo los campos no nulos serán enviados al backend.
  /// Los campos 'is_active', 'is_staff' y 'region' se mantienen en valores por defecto.
  Future<User> updateCurrentUser({
    String? email,
    String? password,
    String? name,
    String? phoneNumber,
  }) async {
    final token = _session.token;
    if (token == null) throw Exception('No autenticado');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    // Armar payload solo con campos proporcionados
    final body = <String, dynamic>{
      'is_active': true,
      'is_staff': false,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (name != null) 'name': name,
      if (phoneNumber != null) 'phone_number': phoneNumber,
    };

    final json = await _http.patchRequest(
      'api/user/me/',
      data: body,
      headers: headers,
    ) as Map<String, dynamic>;

    if (kDebugMode) {
      debugPrint('[UserService] updateCurrentUser → $json');
    }
    return User.fromJson(json);
  }
}
