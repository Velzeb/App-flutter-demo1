import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../models/renter.dart';
import '../Requesthandler.dart';
import '../session_service.dart';

class RenterService {
  final RequestHandler _http = RequestHandler();
  final SessionService _session = SessionService();

  final String _baseUrl = 'api/rentals/profile/';

  // ========================================
  // OBTENER PERFIL DEL RENTADOR (GET)
  // ========================================
  Future<Renter> getRenterProfile() async {
    final token = await _session.token;
    final headers = {'Authorization': 'Token $token'};

    final json = await _http.getRequest(
      _baseUrl,
      headers: headers,
    ) as Map<String, dynamic>;

    if (kDebugMode) {
      print('[RenterService] Perfil de rentador obtenido');
    }

    return Renter.fromJson(json);
  }

  // ========================================
  // REGISTRAR COMO RENTADOR (POST multipart)
  // ========================================
  Future<Renter> registerRenter({
    //De momento son Srings
    required String driverLicenseImage,
    required String photoIdImage,
    bool isVerified = false,
  }) async {
    final token = await _session.token;

    final headers = {'Authorization': 'Token $token'};

    final data = {
      'is_verified': isVerified.toString(),
    };

    final files = {
      'driver_license_image': driverLicenseImage,
      'photo_id_image': photoIdImage,
    };

    final json = await _http.postMultipart(
      _baseUrl,
      headers: headers,
      files: files,
      data: data,
    ) as Map<String, dynamic>;

    if (kDebugMode) {
      print('[RenterService] Rentador registrado correctamente');
    }

    return Renter.fromJson(json);
  }
}
