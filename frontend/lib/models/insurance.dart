// lib/models/insurance.dart

class Insurance {
  /// Número de póliza
  final String policyNumber;

  /// Nombre del proveedor
  final String providerName;

  /// Detalles de cobertura
  final String coverageDetails;

  /// Prima (monto)
  final String premium;

  /// ID de la renta de auto asociada (0 si no aplica)
  final int carRent;

  /// ID de la renta de parqueo asociada (0 si no aplica)
  final int parkingRent;

  const Insurance({
    required this.policyNumber,
    required this.providerName,
    required this.coverageDetails,
    required this.premium,
    required this.carRent,
    required this.parkingRent,
  });

  /// Crea una instancia de [Insurance] a partir de un JSON.
  factory Insurance.fromJson(Map<String, dynamic> json) {
    return Insurance(
      policyNumber:   json['policy_number']   as String,
      providerName:   json['provider_name']   as String,
      coverageDetails:json['coverage_details']as String,
      premium:        json['premium']         as String,
      carRent:        (json['car_rent']       as num).toInt(),
      parkingRent:    (json['parking_rent']   as num).toInt(),
    );
  }

  /// Convierte este [Insurance] a JSON.
  Map<String, dynamic> toJson() {
    return {
      'policy_number'    : policyNumber,
      'provider_name'    : providerName,
      'coverage_details' : coverageDetails,
      'premium'          : premium,
      'car_rent'         : carRent,
      'parking_rent'     : parkingRent,
    };
  }

  /// Crea una copia modificada (sin alterar la original).
  Insurance copyWith({
    String? policyNumber,
    String? providerName,
    String? coverageDetails,
    String? premium,
    int? carRent,
    int? parkingRent,
  }) {
    return Insurance(
      policyNumber:   policyNumber   ?? this.policyNumber,
      providerName:   providerName   ?? this.providerName,
      coverageDetails:coverageDetails?? this.coverageDetails,
      premium:        premium        ?? this.premium,
      carRent:        carRent        ?? this.carRent,
      parkingRent:    parkingRent    ?? this.parkingRent,
    );
  }
}
