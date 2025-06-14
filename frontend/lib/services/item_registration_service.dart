import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'Requesthandler.dart';
import 'session_service.dart';

class ItemRegistrationService {
  final RequestHandler _requestHandler = RequestHandler();
  final SessionService _sessionService = SessionService();
  // Registrar un auto
  Future<Map<String, dynamic>> registerCar(Map<String, dynamic> carData) async {
    try {
      // Obtener token de autenticación
      final token = _sessionService.token;
      if (token == null) {
        throw Exception('No hay sesión activa. Inicie sesión primero.');
      }

      // Crear una solicitud multipart directamente con http
      final uri = Uri.parse(
        '${_requestHandler.baseUrl}api/rentals/register_car/',
      );
      final request = http.MultipartRequest('POST', uri);

      // Agregar el token de autenticación al encabezado
      request.headers['Authorization'] = 'Token $token';

      // Agregar datos de texto
      request.fields['make'] = carData['make'];
      request.fields['model'] = carData['model'];
      request.fields['year'] = carData['year'].toString();
      request.fields['daily_rate'] = carData['daily_rate'].toString();

      if (carData['description'] != null && carData['description'].isNotEmpty) {
        request.fields['description'] = carData['description'];
      }

      // Agregar archivos
      if (carData['image_front_path'] != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image_front',
            carData['image_front_path'],
          ),
        );
      }

      if (carData['image_rear_path'] != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image_rear',
            carData['image_rear_path'],
          ),
        );
      }

      if (carData['image_interior_path'] != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image_interior',
            carData['image_interior_path'],
          ),
        );
      }

      if (carData['registration_document_path'] != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'registration_document',
            carData['registration_document_path'],
          ),
        );
      }

      // Enviar la solicitud
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Verificar el código de estado
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw _handleError(e, 'Error al registrar auto');
    }
  }

  // Registrar un parqueo
  Future<Map<String, dynamic>> registerParking(
    Map<String, dynamic> parkingData,
  ) async {
    try {
      // Obtener token de autenticación
      final token = _sessionService.token;
      if (token == null) {
        throw Exception('No hay sesión activa. Inicie sesión primero.');
      }

      // Crear una solicitud multipart directamente con http
      final uri = Uri.parse(
        '${_requestHandler.baseUrl}api/rentals/register_parking/',
      );
      final request = http.MultipartRequest('POST', uri);

      // Agregar el token de autenticación al encabezado
      request.headers['Authorization'] = 'Token $token';

      // Agregar datos de texto
      request.fields['name'] = parkingData['name'];
      request.fields['address'] = parkingData['address'];
      request.fields['hourly_rate'] = parkingData['hourly_rate'].toString();

      if (parkingData['description'] != null &&
          parkingData['description'].isNotEmpty) {
        request.fields['description'] = parkingData['description'];
      }

      // Agregar imagen
      if (parkingData['image_path'] != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', parkingData['image_path']),
        );
      }

      // Enviar la solicitud
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Verificar el código de estado
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw _handleError(e, 'Error al registrar parqueo');
    }
  }

  // Registrar disponibilidad de un auto
  Future<Map<String, dynamic>> createCarAvailability(
    Map<String, dynamic> availabilityData,
  ) async {
    try {
      // Obtener token de autenticación
      final token = _sessionService.token;
      if (token == null) {
        throw Exception('No hay sesión activa. Inicie sesión primero.');
      }

      // Preparar headers con el token
      final headers = {'Authorization': 'Token $token'};

      // Hacer la solicitud HTTP para crear disponibilidad
      final response = await _requestHandler.postRequest(
        'api/rentals/create_car_availability/',
        data: availabilityData,
        headers: headers,
      );

      return response;
    } catch (e) {
      throw _handleError(e, 'Error al registrar disponibilidad de auto');
    }
  }

  // Registrar disponibilidad de un parqueo
  Future<Map<String, dynamic>> createParkingAvailability(
    Map<String, dynamic> availabilityData,
  ) async {
    try {
      // Obtener token de autenticación
      final token = _sessionService.token;
      if (token == null) {
        throw Exception('No hay sesión activa. Inicie sesión primero.');
      }

      // Preparar headers con el token
      final headers = {'Authorization': 'Token $token'};

      // Hacer la solicitud HTTP para crear disponibilidad
      final response = await _requestHandler.postRequest(
        'api/rentals/create_parking_availability/',
        data: availabilityData,
        headers: headers,
      );

      return response;
    } catch (e) {
      throw _handleError(e, 'Error al registrar disponibilidad de parqueo');
    }
  }

  // Listar autos del usuario
  Future<List<dynamic>> listUserCars() async {
    try {
      // Obtener token de autenticación
      final token = _sessionService.token;
      if (token == null) {
        throw Exception('No hay sesión activa. Inicie sesión primero.');
      }

      // Preparar headers con el token
      final headers = {'Authorization': 'Token $token'};

      // Hacer la solicitud HTTP para listar los autos
      final response = await _requestHandler.getRequest(
        'api/rentals/list_cars/',
        headers: headers,
      );

      return response;
    } catch (e) {
      throw _handleError(e, 'Error al listar autos');
    }
  }

  // Listar parqueos del usuario
  Future<List<dynamic>> listUserParkings() async {
    try {
      // Obtener token de autenticación
      final token = _sessionService.token;
      if (token == null) {
        throw Exception('No hay sesión activa. Inicie sesión primero.');
      }

      // Preparar headers con el token
      final headers = {'Authorization': 'Token $token'};

      // Hacer la solicitud HTTP para listar los parqueos
      final response = await _requestHandler.getRequest(
        'api/rentals/list_parkings/',
        headers: headers,
      );

      return response;
    } catch (e) {
      throw _handleError(e, 'Error al listar parqueos');
    }
  }

  // Manejar errores
  Exception _handleError(dynamic e, String message) {
    if (e is http.ClientException) {
      return Exception('$message: Error de conexión');
    } else if (e is SocketException) {
      return Exception('$message: No se pudo conectar al servidor');
    } else if (e is FormatException) {
      return Exception('$message: Formato de respuesta inválido');
    } else {
      return Exception('$message: ${e.toString()}');
    }
  }
}
