class Car {
  final String id;
  final String ownerId;
  final String ownerName;
  final String brand;
  final String model;
  final int year;
  final String color;
  final double pricePerDay;
  final String location;
  final String description;
  final String imageUrl;
  final bool isAvailable;
  final DateTime createdAt;

  Car({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.pricePerDay,
    required this.location,
    required this.description,
    required this.imageUrl,
    this.isAvailable = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'pricePerDay': pricePerDay,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      ownerId: json['ownerId'],
      ownerName: json['ownerName'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      color: json['color'],
      pricePerDay: json['pricePerDay'].toDouble(),
      location: json['location'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      isAvailable: json['isAvailable'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Car copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? brand,
    String? model,
    int? year,
    String? color,
    double? pricePerDay,
    String? location,
    String? description,
    String? imageUrl,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return Car(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      location: location ?? this.location,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
