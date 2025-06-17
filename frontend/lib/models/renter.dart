// lib/models/renter.dart

import 'user.dart';

/// Extiende [User] con información específica de rentador.
class Renter extends User {
  final int id;

  /// URI de la imagen de la licencia de conducir (puede ser null si no existe).
  final Uri? driverLicenseImage;

  /// URI de la imagen del documento de identidad (puede ser null si no existe).
  final Uri? photoIdImage;

  /// Indica si ya fue verificado.
  final bool isVerified;

  /// Fecha de verificación (opcional).
  final DateTime? verifiedAt;

  const Renter({
    required this.id,
    required int pk,
    required String email,
    required String name,
    String? phoneNumber,
    required bool isActive,
    required bool isStaff,
    int? region,
    this.driverLicenseImage,
    this.photoIdImage,
    required this.isVerified,
    this.verifiedAt,
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

    // Validar licencias y documentos
    final licStr = json['driver_license_image'] as String?;
    final idStr = json['photo_id_image']   as String?;
    final uriLic = (licStr != null && licStr.isNotEmpty)
        ? Uri.parse(licStr)
        : null;
    final uriId  = (idStr  != null && idStr.isNotEmpty)
        ? Uri.parse(idStr)
        : null;

    final rawVerified = json['verified_at'];
    final parsedVerifiedAt = (rawVerified is String && rawVerified.isNotEmpty)
        ? DateTime.parse(rawVerified)
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
      driverLicenseImage: uriLic,
      photoIdImage:       uriId,
      isVerified: json['is_verified'] as bool? ?? false,
      verifiedAt: parsedVerifiedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': super.toJson(),
      'driver_license_image': driverLicenseImage?.toString() ?? '',
      'photo_id_image': photoIdImage?.toString() ?? '',
      'is_verified': isVerified,
      'verified_at': verifiedAt?.toIso8601String() ?? '',
    };
  }

  @override
  Renter copyWith({
    int? id,
    String? email,
    String? name,
    String? phoneNumber,
    bool? isActive,
    bool? isStaff,
    int? region,
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
      driverLicenseImage: driverLicenseImage ?? this.driverLicenseImage,
      photoIdImage:       photoIdImage       ?? this.photoIdImage,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}
