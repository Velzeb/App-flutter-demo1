// lib/models/car_available.dart

import '../car.dart';
import 'Availability.dart';

class CarAvailable extends Car {
  final int id;
  final String owner;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Nueva lista de disponibilidad
  final List<Availability> availability;

  CarAvailable({
    required this.id,
    required this.owner,
    required String make,
    required String model,
    required int year,
    required String description,
    required Uri imageFront,
    required Uri imageRear,
    required Uri imageInterior,
    required Uri registrationDocument,
    required String dailyRate,
    required bool isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.availability,
  }) : super(
    make: make,
    model: model,
    year: year,
    description: description,
    imageFront: imageFront,
    imageRear: imageRear,
    imageInterior: imageInterior,
    registrationDocument: registrationDocument,
    dailyRate: dailyRate,
    isActive: isActive,
  );

  factory CarAvailable.fromJson(Map<String, dynamic> json) {
    return CarAvailable(
      id: json['id'] as int,
      owner: json['owner'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      description: json['description'] as String,
      imageFront: Uri.parse(json['image_front'] as String),
      imageRear: Uri.parse(json['image_rear'] as String),
      imageInterior: Uri.parse(json['image_interior'] as String),
      registrationDocument:
      Uri.parse(json['registration_document'] as String),
      dailyRate: json['daily_rate'] as String,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      availability: (json['availability'] as List<dynamic>?)
          ?.map((e) =>
          Availability.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    return {
      'id': id,
      'owner': owner,
      ...base,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'availability': availability.map((a) => a.toJson()).toList(),
    };
  }
}
