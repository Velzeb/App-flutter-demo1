// lib/services/renter_service.dart
// --------------------------------------------------
// Servicio: gestiona perfil y verificaciones de rentadores.
// Endpoints:
// - POST   api/rentals/profile/                          -> registra imágenes de licencias
// - GET    api/rentals/renters/pending-verifications/    -> lista verificaciones pendientes (solo staff)
// - POST   api/rentals/verify_renter/{id}/               -> aprueba un rentador
// --------------------------------------------------

import 'package:flutter/foundation.dart';

import '../../models/renter.dart';
import '../Requesthandler.dart';
import '../session_service.dart';


class RenterService {
  final RequestHandler _http    = RequestHandler();
  final SessionService _session = SessionService();

  /// Registra o actualiza el perfil de rentador (licencia e ID).
  Future<Renter> registerProfile({
    required String driverLicensePath,
    required String photoIdPath,
  }) async {
    final token = _session.token;
    if (token == null) throw Exception('No autenticado');
    final headers = {'Authorization': 'Token $token'};

    final files = {
      'driver_license_image': driverLicensePath,
      'photo_id_image':       photoIdPath,
    };

    final json = await _http.postMultipart(
      'api/rentals/profile/',
      headers: headers,
      files: files,
    ) as Map<String, dynamic>;

    if (kDebugMode) {
      debugPrint('[RenterService] registerProfile → \$json');
    }
    return Renter.fromJson(json);
  }

  /// Obtiene lista de rentadores con verificaciones pendientes.
  /// Solo accesible si el usuario es staff.
  Future<List<Renter>> listPendingVerifications() async {
    final token = _session.token;
    if (token == null) throw Exception('No autenticado');
    final headers = {'Authorization': 'Token $token'};

    final raw = await _http.getRequest(
      'api/rentals/renters/pending-verifications/',
      headers: headers,
    ) as List<dynamic>;

    final pendings = raw
        .whereType<Map<String, dynamic>>()
        .map((json) => Renter.fromJson(json))
        .toList(growable: false);

    if (kDebugMode) {
      debugPrint('[RenterService] pendingVerifications count=\${pendings.length}');
    }
    return pendings;
  }

  /// Aprueba (verifica) al rentador indicado por [renterId].
  Future<void> verifyRenter(int renterId) async {
    final token = _session.token;
    if (token == null) throw Exception('No autenticado');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    await _http.postRequest(
      'api/rentals/verify_renter/\$renterId/',
      headers: headers,
    );

    if (kDebugMode) {
      debugPrint('[RenterService] verifyRenter id=\$renterId');
    }
  }
}
