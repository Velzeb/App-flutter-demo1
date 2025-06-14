// lib/models/parking.dart

import 'package:flutter/widgets.dart';

/// Modelo de datos para un estacionamiento, con serialización/deserialización
class Parking {
  final String name;
  final String address;
  final String description;

  /// URL de la imagen del parking
  final Uri image;

  /// Tarifa por hora (se maneja como String para enviar exactamente el valor recibido)
  final String hourlyRate;

  final bool isActive;

  Parking({
    required this.name,
    required this.address,
    required this.description,
    required this.image,
    required this.hourlyRate,
    required this.isActive,
  });

  /// Crea una instancia de Parking a partir de un JSON.
  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      name: json['name'] as String,
      address: json['address'] as String,
      description: json['description'] as String,
      image: Uri.parse(json['image'] as String),
      hourlyRate: json['hourly_rate'] as String,
      isActive: json['is_active'] as bool,
    );
  }

  /// Convierte la instancia de Parking a JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'description': description,
      'image': image.toString(),
      'hourly_rate': hourlyRate,
      'is_active': isActive,
    };
  }

  // ===========================
  // Helpers para manejar imagen
  // ===========================

  /// Obtiene la imagen como ImageProvider.
  ImageProvider get imageProvider => NetworkImage(image.toString());

  /// Widget de la imagen.
  Widget imageWidget({BoxFit fit = BoxFit.cover}) =>
      Image.network(image.toString(), fit: fit);
}
