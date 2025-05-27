class Rental {
  final String id;
  final String carId;
  final String renterId;
  final String renterName;
  final String ownerId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final RentalStatus status;
  final DateTime createdAt;

  Rental({
    required this.id,
    required this.carId,
    required this.renterId,
    required this.renterName,
    required this.ownerId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    this.status = RentalStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'renterId': renterId,
      'renterName': renterName,
      'ownerId': ownerId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'],
      carId: json['carId'],
      renterId: json['renterId'],
      renterName: json['renterName'],
      ownerId: json['ownerId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalPrice: json['totalPrice'].toDouble(),
      status: RentalStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => RentalStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }
}

enum RentalStatus { pending, confirmed, active, completed, cancelled }
