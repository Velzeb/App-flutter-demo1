// lib/services/insurance_service.dart
// --------------------------------------------------
// Servicio: gestiona las operaciones CRUD de seguros
// - Registrar (comprar) un seguro
// - Obtener lista de seguros del usuario
// --------------------------------------------------

import 'package:flutter/foundation.dart';

import '../../models/insurance.dart';
import '../Requesthandler.dart';
import '../session_service.dart';

class InsuranceService {
  final RequestHandler _http    = RequestHandler();
  final SessionService _session = SessionService();

  /// Compra un seguro (registro) asociado a un auto y/o parqueo.
  /// Parámetros:
  /// - [premium]: monto de la prima (requerido)
  /// - [coverageDetails]: detalles de cobertura (opcional)
  /// - [carRent]: ID de la renta de auto (opcional)
  /// - [parkingRent]: ID de la renta de parqueo (opcional)
  Future<Insurance> purchaseInsurance({
    String? coverageDetails,
    required String premium,
    int? carRent,
    int? parkingRent,
  }) async {
    final token = _session.token;
    if (token == null) throw Exception('No autenticado');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final body = <String, dynamic>{
      if (coverageDetails != null) 'coverage_details': coverageDetails,
      'premium': premium,
      if (carRent != null) 'car_rent': carRent,
      if (parkingRent != null) 'parking_rent': parkingRent,
    };

    final json = await _http.postRequest(
      'api/rentals/purchase_insurance/',
      data: body,
      headers: headers,
    ) as Map<String, dynamic>;

    if (kDebugMode) {
      debugPrint('[InsuranceService] purchaseInsurance → $json');
    }
    return Insurance.fromJson(json);
  }

  /// Obtiene la lista de seguros asociados al usuario autenticado.
  Future<List<Insurance>> listMyInsurances() async {
    final token = _session.token;
    if (token == null) throw Exception('No autenticado');
    final headers = {'Authorization': 'Token $token'};

    final raw = await _http.getRequest(
      'api/rentals/list_insurances/',
      headers: headers,
    ) as List<dynamic>;

    final insurances = raw
        .whereType<Map<String, dynamic>>()
        .map((json) => Insurance.fromJson(json))
        .toList(growable: false);

    if (kDebugMode) {
      debugPrint('[InsuranceService] insurances=${insurances.length}');
    }
    return insurances;
  }
}
