import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  // Usando Nominatim (OpenStreetMap) - Gratuito
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  /// Obtiene la dirección a partir de coordenadas (Reverse Geocoding)
  static Future<String> getAddressFromCoordinates(LatLng coordinates) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/reverse?format=json&lat=${coordinates.latitude}&lon=${coordinates.longitude}&zoom=18&addressdetails=1&accept-language=es',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'Flutter RentCar App/1.0.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['display_name'] != null) {
          return _formatAddress(data);
        } else {
          return 'Ubicación no encontrada';
        }
      } else {
        return 'Error al obtener ubicación';
      }
    } catch (e) {
      print('Error en geocodificación: $e');
      return 'Error al obtener ubicación';
    }
  }

  /// Formatea la dirección para mostrar de forma legible
  static String _formatAddress(Map<String, dynamic> data) {
    try {
      final address = data['address'] as Map<String, dynamic>?;
      if (address == null) {
        return data['display_name'] ?? 'Ubicación desconocida';
      }

      // Construir dirección de manera jerárquica
      List<String> parts = [];

      // Número de casa y calle
      if (address['house_number'] != null && address['road'] != null) {
        parts.add('${address['road']} ${address['house_number']}');
      } else if (address['road'] != null) {
        parts.add(address['road']);
      }

      // Barrio o zona
      if (address['neighbourhood'] != null) {
        parts.add(address['neighbourhood']);
      } else if (address['suburb'] != null) {
        parts.add(address['suburb']);
      }

      // Ciudad
      if (address['city'] != null) {
        parts.add(address['city']);
      } else if (address['town'] != null) {
        parts.add(address['town']);
      } else if (address['municipality'] != null) {
        parts.add(address['municipality']);
      }

      // País
      if (address['country'] != null) {
        parts.add(address['country']);
      }

      if (parts.isNotEmpty) {
        return parts.join(', ');
      } else {
        // Si no hay componentes específicos, usar display_name
        String displayName = data['display_name'] ?? 'Ubicación desconocida';
        // Limitar a los primeros elementos para que no sea muy largo
        List<String> displayParts = displayName.split(', ');
        if (displayParts.length > 3) {
          return displayParts.take(3).join(', ');
        }
        return displayName;
      }
    } catch (e) {
      print('Error formateando dirección: $e');
      return data['display_name'] ?? 'Ubicación desconocida';
    }
  }

  /// Busca lugares por nombre (Forward Geocoding) - Opcional para búsqueda
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/search?format=json&q=${Uri.encodeComponent(query)}&limit=5&addressdetails=1&accept-language=es',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'Flutter RentCar App/1.0.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error en búsqueda de lugares: $e');
      return [];
    }
  }
}
