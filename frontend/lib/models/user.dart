// lib/models/user.dart

class User {
  /// Identificador único (no debe cambiar nunca).
  final int pk;

  /// Correo electrónico del usuario.
  final String email;

  /// Nombre completo.
  final String name;

  /// Número de teléfono (puede ser null).
  final String? phoneNumber;

  /// `true` si la cuenta está activa.
  final bool isActive;

  /// `true` si tiene permisos de staff.
  final bool isStaff;

  /// Región asociada (ID), puede ser null.
  final int? region;

  const User({
    required this.pk,
    required this.email,
    required this.name,
    this.phoneNumber,
    required this.isActive,
    required this.isStaff,
    this.region,
  });

  /// Crea un [User] a partir de un JSON.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      pk: json['pk'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String?,
      isActive: json['is_active'] as bool,
      isStaff: json['is_staff'] as bool,
      region: json['region'] is int ? json['region'] as int : null,
    );
  }

  /// Convierte este [User] a JSON.
  /// Nota: el campo `pk` no se envía en actualizaciones.
  Map<String, dynamic> toJson() {
    return {
      'pk': pk,
      'email': email,
      'name': name,
      'phone_number': phoneNumber,
      'is_active': isActive,
      'is_staff': isStaff,
      'region': region,
    };
  }

  /// Retorna una copia modificando solo los campos deseados
  /// (excepto `pk`, que permanece inmutable).
  User copyWith({
    String? email,
    String? name,
    String? phoneNumber,
    bool? isActive,
    bool? isStaff,
    int? region,
  }) {
    return User(
      pk: pk,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      region: region ?? this.region,
    );
  }
}
