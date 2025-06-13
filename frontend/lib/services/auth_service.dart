import 'package:flutter/foundation.dart';
import 'package:login_app/services/session_service.dart';
import 'Requesthandler.dart';
// Modelo Usuario
class User {
  final String name;
  final String email;
  final String password;

  User({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      password: json['password'],
    );
  }
}

class AuthService {
  // Simulamos una base de datos local con algunos usuarios de prueba
  static final RequestHandler _requestHandler = RequestHandler();
  static final List<User> _users = [];

  static User? _currentUser;

  // Obtener usuario actual
  static User? get currentUser => _currentUser;

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

  // Cerrar sesión
  static void logout() {
    _currentUser = null;
  }

  // Verificar si hay usuario logueado
  static bool isLoggedIn() {
    return _currentUser != null;
  }

  // Obtener lista de usuarios (solo para debug)
  static List<User> getUsers() {
    return List.from(_users);
  }

  // Get current user as Map (for compatibility with new screens)
  static Map<String, String>? getCurrentUser() {
    if (_currentUser == null) return null;
    return {
      'name': _currentUser!.name,
      'email': _currentUser!.email,
    };
  }
}
