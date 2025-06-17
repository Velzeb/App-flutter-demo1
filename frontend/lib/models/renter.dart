// lib/models/renter.dart

import 'user.dart';

/// Extiende [User] con información específica de rentador.
class Renter extends User {
  final int id;
  final Uri driverLicenseImage;
  final Uri photoIdImage;
  final bool isVerified;
  final DateTime? verifiedAt;    // <-- ahora nullable

  const Renter({
    required this.id,
    required int pk,
    required String email,
    required String name,
    String? phoneNumber,
    required bool isActive,
    required bool isStaff,
    int? region,
    required this.driverLicenseImage,
    required this.photoIdImage,
    required this.isVerified,
    this.verifiedAt,            // <-- opcional
  }) : super(
    pk: pk,
    email: email,
    name: name,
    phoneNumber: phoneNumber,
    isActive: isActive,
    isStaff: isStaff,
    region: region,
  );

  factory Renter.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>;
    final user = User.fromJson(userJson);

    // Aquí comprobamos si viene null o no
    final rawVerified = json['verified_at'];
    final parsedVerifiedAt = rawVerified != null
        ? DateTime.parse(rawVerified as String)
        : null;

    return Renter(
      id: json['id'] as int,
      pk: user.pk,
      email: user.email,
      name: user.name,
      phoneNumber: user.phoneNumber,
      isActive: user.isActive,
      isStaff: user.isStaff,
      region: user.region,
      driverLicenseImage: Uri.parse(json['driver_license_image'] as String),
      photoIdImage: Uri.parse(json['photo_id_image'] as String),
      isVerified: json['is_verified'] as bool? ?? false,
      verifiedAt: parsedVerifiedAt,
    );
  }

  /// Convierte este [Renter] a JSON con la misma forma que viene del backend.
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': super.toJson(),
      'driver_license_image': driverLicenseImage.toString(),
      'photo_id_image': photoIdImage.toString(),
      'is_verified': isVerified,
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }

  /// Copia este objeto cambiando únicamente los campos indicados.
  @override
  Renter copyWith({
    int? id,
    // campos de User:
    String? email,
    String? name,
    String? phoneNumber,
    bool? isActive,
    bool? isStaff,
    int? region,
    // campos de Renter:
    Uri? driverLicenseImage,
    Uri? photoIdImage,
    bool? isVerified,
    DateTime? verifiedAt,
  }) {
    return Renter(
      id: id ?? this.id,
      pk: pk,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      region: region ?? this.region,
      driverLicenseImage:
      driverLicenseImage ?? this.driverLicenseImage,
      photoIdImage: photoIdImage ?? this.photoIdImage,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}
