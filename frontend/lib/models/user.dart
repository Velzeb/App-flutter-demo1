class User {
  final String email;
  final String password;
  final String name;
  final String? phoneNumber;
  final bool isActive;
  final bool isStaff;

  /// Región del usuario. Es opcional y puede ser nula.
  final int? region;

  User({
    required this.email,
    required this.password,
    required this.name,
    this.phoneNumber,
    required this.isActive,
    required this.isStaff,
    this.region,
  });

  /// Crea una instancia de User desde un JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
      password: json['password'] != null ? json['password'] as String : '', // Previene error
      name: json['name'] as String,
      phoneNumber: json['phone_number'] != null ? json['phone_number'] as String : null,
      isActive: json['is_active'] as bool,
      isStaff: json['is_staff'] as bool,
      region: json['region'] != null ? json['region'] as int : null,
    );
  }

  /// Convierte la instancia de User a JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'phone_number': phoneNumber,
      'is_active': isActive,
      'is_staff': isStaff,
      if (region != null) 'region': region,
    };
  }
}
