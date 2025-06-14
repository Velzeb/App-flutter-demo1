// lib/models/parking_available.dart

import 'package:flutter/widgets.dart';
import '../parking.dart';


/// Modelo que extiende Parking con información de disponibilidad y metadatos
class ParkingAvailable extends Parking {
  /// Identificador único de la disponibilidad
  final int id;

  /// Identificador del propietario
  final int owner;

  /// Fecha de creación en el sistema
  final DateTime createdAt;

  /// Fecha de última actualización
  final DateTime updatedAt;

  ParkingAvailable({
    required this.id,
    required this.owner,
    required this.createdAt,
    required this.updatedAt,
    required String name,
    required String address,
    required String description,
    required Uri image,
    required String hourlyRate,
    required bool isActive,
  }) : super(
    name: name,
    address: address,
    description: description,
    image: image,
    hourlyRate: hourlyRate,
    isActive: isActive,
  );

  /// Crea una instancia de ParkingAvailable a partir de un JSON.
  factory ParkingAvailable.fromJson(Map<String, dynamic> json) {
    return ParkingAvailable(
      id: json['id'] as int,
      owner: json['owner'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      name: json['name'] as String,
      address: json['address'] as String,
      description: json['description'] as String,
      image: Uri.parse(json['image'] as String),
      hourlyRate: json['hourly_rate'] as String,
      isActive: json['is_active'] as bool,
    );
  }

  /// Convierte la instancia de ParkingAvailable a JSON.
  @override
  Map<String, dynamic> toJson() {
    final parent = super.toJson();
    return {
      'id': id,
      'owner': owner,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      ...parent,
    };
  }


  @override
  ImageProvider get imageProvider => super.imageProvider;

  @override
  Widget imageWidget({BoxFit fit = BoxFit.cover}) =>
      super.imageWidget(fit: fit);
}
