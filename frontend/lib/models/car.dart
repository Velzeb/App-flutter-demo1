// lib/models/car.dart

import 'package:flutter/widgets.dart';

/// Modelo de datos para un auto, con manejo de imágenes y serialización/deserialización
class Car {
  final String make;
  final String model;
  final int year;
  final String description;

  // URLs de imágenes
  final Uri imageFront;
  final Uri imageRear;
  final Uri imageInterior;

  // Documento de registro
  final Uri registrationDocument;

  final String dailyRate;
  final bool isActive;

  Car({
    required this.make,
    required this.model,
    required this.year,
    required this.description,
    required this.imageFront,
    required this.imageRear,
    required this.imageInterior,
    required this.registrationDocument,
    required this.dailyRate,
    required this.isActive,
  });

  /// Crea una instancia de Car a partir de un JSON.
  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      description: json['description'] as String,
      imageFront: Uri.parse(json['image_front'] as String),
      imageRear: Uri.parse(json['image_rear'] as String),
      imageInterior: Uri.parse(json['image_interior'] as String),
      registrationDocument: Uri.parse(json['registration_document'] as String),
      dailyRate: json['daily_rate'] as String,
      isActive: json['is_active'] as bool,
    );
  }

  /// Convierte la instancia de Car a JSON.
  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'description': description,
      'image_front': imageFront.toString(),
      'image_rear': imageRear.toString(),
      'image_interior': imageInterior.toString(),
      'registration_document': registrationDocument.toString(),
      'daily_rate': dailyRate,
      'is_active': isActive,
    };
  }

  // ===========================
  // Helpers para manejar imágenes
  // ===========================

  /// Obtiene la imagen frontal como ImageProvider.
  ImageProvider get frontImageProvider => NetworkImage(imageFront.toString());

  /// Obtiene la imagen trasera como ImageProvider.
  ImageProvider get rearImageProvider => NetworkImage(imageRear.toString());

  /// Obtiene la imagen interior como ImageProvider.
  ImageProvider get interiorImageProvider => NetworkImage(imageInterior.toString());

  /// Widget de la imagen frontal.
  Widget frontImage({BoxFit fit = BoxFit.cover}) =>
      Image.network(imageFront.toString(), fit: fit);

  /// Widget de la imagen trasera.
  Widget rearImage({BoxFit fit = BoxFit.cover}) =>
      Image.network(imageRear.toString(), fit: fit);

  /// Widget de la imagen interior.
  Widget interiorImage({BoxFit fit = BoxFit.cover}) =>
      Image.network(imageInterior.toString(), fit: fit);

  /// Widget para el documento de registro.
  Widget registrationDocImage({BoxFit fit = BoxFit.cover}) =>
      Image.network(registrationDocument.toString(), fit: fit);
}
