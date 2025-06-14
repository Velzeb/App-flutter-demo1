// lib/services/image_service.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Servicio para construir URLs completas de imágenes
class ImageService {
  // Getter estático que elige la base según plataforma
  static String get _baseUrl {
    if (kIsWeb) {
      // En web apuntamos a localhost directamente
      return 'http://localhost:8080';
    } else if (Platform.isAndroid) {
      // En emulador Android usamos 10.0.2.2
      return 'http://10.0.2.2:8080';
    } else {
      // iOS o cualquier otra plataforma (e.g. desktop) a localhost
      return 'http://localhost:8080';
    }
  }

  /// Convierte un path relativo en la URL completa
  /// Asegura que el `relativePath` comience con `/`
  static String getFullImageUrl(String relativePath) {
    final path = relativePath.startsWith('/') ? relativePath : '/$relativePath';
    return '$_baseUrl$path';
  }
}
