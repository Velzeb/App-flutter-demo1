import 'package:flutter/foundation.dart';
import 'package:login_app/services/session_service.dart';
import 'Requesthandler.dart';
// Modelo Usuario

class AuthService {
  // Simulamos una base de datos local con algunos usuarios de prueba
  static final RequestHandler _requestHandler = RequestHandler();

  static bool _isStaff = false;
  static bool get isStaff => _isStaff;

  // Simular login
  static Future<bool> login(String email, String password) async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 1));

    try {

      final response = await _requestHandler.postRequest(
        'api/user/login/', // Cambia esto al endpoint correcto de tu backend
        data: {
          'email': email,
          'password': password,
        },

      );
      print(response);
      // Puedes adaptar esto según la respuesta del backend
      if (response != null && response['token'] != null) {
        final String tokenRecibido = response['token'];
        _isStaff = (response['is_staff'] as bool? ?? false);

        SessionService().setToken(tokenRecibido);

        print('[REGISTER] Token guardado en sesión: $tokenRecibido');
        print('[LOGIN] Token recibido: ${response['token']}');
        return true;
      }

      return false;
    } catch (e) {
      print('[LOGIN ERROR] $e');
      return false;
    }
  }

  // Simular registro
  static Future<bool> register(String name, String email, String password) async {
    try {
      const String endpoint = 'api/user/create/';
      final token = SessionService().token;

      final Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'password': password,
      };

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      final response = await _requestHandler.postRequest(
        endpoint,
        data: data,
        headers: headers,
      );

      if (kDebugMode) {
        print('Respuesta del servidor: $response');
      }

      // Verificamos que el response no sea null y que sea un Map (como se espera en JSON)
      if (response != null && response is Map<String, dynamic>) {
        if (response.containsKey('email') || response.containsKey('id')) {
          // Asumimos que si devuelve un usuario, el registro fue exitoso
          return true;
        }
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error en register(): $e');
      }
      return false;
    }
  }

}
