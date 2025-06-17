import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../Requesthandler.dart';
import '../session_service.dart';

class ProfileService {
  final RequestHandler _http = RequestHandler();
  final SessionService _session = SessionService();

  // =================================================
  // OBTENER DATOS DEL USUARIO ACTUAL
  // =================================================
  Future<User> getUserProfile() async {
    final token = await _session.token;
    final headers = {'Authorization': 'Token $token'};

    // 1. Obtener e-mail del usuario

    final userJson = await _http.getRequest(
      'api/user/me/',
      headers: headers,
    ) as Map<String, dynamic>;

    final user = User.fromJson(userJson);

    if (kDebugMode) {
      print('[ProfileService] Perfil obtenido para ${user.email}');
    }

    return user;
  }

  // =================================================
  // ACTUALIZAR PARCIALMENTE DATOS DEL USUARIO (PATCH)
  // Devuelve el User actualizado.
  // =================================================
  Future<User> updateUserProfile({
    required Map<String, dynamic> data,
  }) async {
    final token = await _session.token;
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final json = await _http.patchRequest(
      'api/user/me/',
      data: data,
      headers: headers,
    ) as Map<String, dynamic>;

    final updatedUser = User.fromJson(json);

    if (kDebugMode) {
      print('[ProfileService] Perfil actualizado (PATCH) para ${updatedUser.email}');
    }

    return updatedUser;
  }

  // =================================================
  // CERRAR SESIÓN: Borra token y navega a Login
  // =================================================
  void salir(BuildContext context) {
    _session.clearToken();

    if (kDebugMode) {
      print('[ProfileService] Sesión cerrada');
    }

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }


}
