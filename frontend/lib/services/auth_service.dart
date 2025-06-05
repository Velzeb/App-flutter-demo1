import 'package:flutter/foundation.dart';

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
  static final List<User> _users = [
    User(
      name: 'Usuario Demo',
      email: 'demo@example.com',
      password: '123456',
    ),
    User(
      name: 'Admin',
      email: 'admin@example.com',
      password: 'admin123',
    ),
  ];

  static User? _currentUser;

  // Obtener usuario actual
  static User? get currentUser => _currentUser;

  // Simular login
  static Future<bool> login(String email, String password) async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 1));

    try {
      final user = _users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
      _currentUser = user;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Simular registro
  static Future<bool> register(String name, String email, String password) async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 1));

    // Verificar si el email ya existe
    bool emailExists = _users.any((user) => user.email == email);
    if (emailExists) {
      return false;
    }

    // Crear nuevo usuario
    final newUser = User(
      name: name,
      email: email,
      password: password,
    );

    _users.add(newUser);
    
    if (kDebugMode) {
      print('Usuario registrado: ${newUser.toJson()}');
    }
    
    return true;
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
