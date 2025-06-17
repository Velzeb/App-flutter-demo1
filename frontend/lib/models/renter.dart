import 'user.dart';

class Renter {
  final int id;
  final User user;
  final String driverLicenseImage;
  final String photoIdImage;
  final bool isVerified;
  final DateTime? verifiedAt;

  Renter({
    required this.id,
    required this.user,
    required this.driverLicenseImage,
    required this.photoIdImage,
    required this.isVerified,
    this.verifiedAt,
  });

  factory Renter.fromJson(Map<String, dynamic> json) {
    return Renter(
      id: json['id'],
      user: User.fromJson(json['user']),
      driverLicenseImage: json['driver_license_image'] ?? '',
      photoIdImage: json['photo_id_image'] ?? '',
      isVerified: json['is_verified'] ?? false,
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'driver_license_image': driverLicenseImage,
      'photo_id_image': photoIdImage,
      'is_verified': isVerified,
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }

  /// Para enviar los campos como `multipart/form-data`
  Map<String, String> toMultipartData() {
    return {
      'is_verified': isVerified.toString(),
    };
  }

  /// Para subir las imágenes como archivo
  Map<String, String> toMultipartFiles() {
    return {
      'driver_license_image': driverLicenseImage,
      'photo_id_image': photoIdImage,
    };
  }
}
