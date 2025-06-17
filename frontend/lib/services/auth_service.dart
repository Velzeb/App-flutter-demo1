// lib/services/auth_service.dart

import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'session_service.dart';
import 'requesthandler.dart';

class AuthService {
  static final RequestHandler _requestHandler = RequestHandler();
  static final List<User> _users = [];
  static bool _isStaff = false;
  static bool get isStaff => _isStaff;

  static User? _currentUser;
  static User? get currentUser => _currentUser;

  /// Simula login contra el backend.
  /// Almacena token, establece currentUser e isStaff.
  static Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final response = await _requestHandler.postRequest(
        'api/user/login/',
        data: {'email': email, 'password': password},
      ) as Map<String, dynamic>;

      final token = response['token'] as String?;
      if (token == null) return false;

      // Esperar a que se persista el token
      await SessionService().setToken(token);

      // Parsear y guardar User
      _currentUser = User.fromJson(response);
      _isStaff     = _currentUser?.isStaff ?? false;

      if (kDebugMode) {
        debugPrint('[AuthService] login ok: ${_currentUser!.email}, staff=$_isStaff');
      }
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthService] login error: $e');
      return false;
    }
  }

  /// Simula registro de un nuevo usuario.
  /// No inicia sesión automáticamente.
  static Future<bool> register(String name, String email, String password) async {
    try {
      const endpoint = 'api/user/create/';
      final response = await _requestHandler.postRequest(
        endpoint,
        data: {'name': name, 'email': email, 'password': password},
        headers: {'Content-Type': 'application/json'},
      );
      if (kDebugMode) debugPrint('[AuthService] register resp: $response');

      if (response is Map<String, dynamic> &&
          (response.containsKey('email') || response.containsKey('pk'))) {
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthService] register error: $e');
      return false;
    }
  }

  /// Cierra sesión: borra token y usuario.
  static Future<void> logout() async {
    final token = SessionService().token;
    if (token != null) {
      try {
        await _requestHandler.postRequest(
          'api/user/logout/',
          headers: {'Authorization': 'Token $token'},
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Logout API error: $e');
      }
    }
    // Esperar a que se elimine el token persistido
    await SessionService().clearToken();
    _currentUser = null;
    _isStaff     = false;
  }

  /// Indica si hay usuario autenticado.
  static bool isLoggedIn() {
    return SessionService().token != null;
  }

  /// Para debugging: lista de usuarios creados localmente.
  static List<User> getUsers() => List.from(_users);
}
