import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class RequestHandler {
  /// Si [baseUrlOverride] está definido, se usa tal cual.
  /// Si no, se elige según plataforma:
  /// - Web: localhost:8080
  /// - Android: 10.0.2.2:8080
  /// - Resto (iOS, desktop): localhost:8080
  late final String baseUrl;

  RequestHandler({String? baseUrlOverride}) {
    baseUrl = baseUrlOverride ?? _determineBaseUrl();
  }

  static String _determineBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080/';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/';
    }
    return 'http://localhost:8080/';
  }

  Future<dynamic> getRequest(String endpoint,
      {Map<String, String>? params, Map<String, String>? headers}) {
    return _sendRequest('GET', endpoint, params: params, headers: headers);
  }

  Future<dynamic> postRequest(String endpoint,
      {Map<String, dynamic>? data,
       Map<String, String>? params,
       Map<String, String>? headers}) {
    return _sendRequest('POST', endpoint,
        data: data, params: params, headers: headers);
  }

  Future<dynamic> putRequest(String endpoint,
      {Map<String, dynamic>? data,
       Map<String, String>? params,
       Map<String, String>? headers}) {
    return _sendRequest('PUT', endpoint,
        data: data, params: params, headers: headers);
  }

  Future<dynamic> deleteRequest(String endpoint,
      {Map<String, String>? params, Map<String, String>? headers}) {
    return _sendRequest('DELETE', endpoint, params: params, headers: headers);
  }

  Future<dynamic> patchRequest(String endpoint,
      {Map<String, dynamic>? data,
       Map<String, String>? params,
       Map<String, String>? headers}) {
    return _sendRequest('PATCH', endpoint,
        data: data, params: params, headers: headers);
  }

  Future<dynamic> _sendRequest(String method, String endpoint,
      {Map<String, dynamic>? data,
       Map<String, String>? params,
       Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$endpoint')
        .replace(queryParameters: params);
    print('[Intentando $method en: $uri]');

    final defaultHeaders = <String, String>{
      'Content-Type': 'application/json',
      if (headers?.containsKey('Authorization') ?? false)
        'Authorization': headers!['Authorization']!
            .replaceAll(RegExp(r'^(Token|Bearer)\s*'), ''),
      ...?headers,
    };

    late http.Response response;
    switch (method) {
      case 'GET':
        response = await http.get(uri, headers: defaultHeaders);
        break;
      case 'POST':
        response = await http.post(uri,
            body: jsonEncode(data), headers: defaultHeaders);
        break;
      case 'PUT':
        response = await http.put(uri,
            body: jsonEncode(data), headers: defaultHeaders);
        break;
      case 'PATCH':
        response = await http.patch(uri,
            body: jsonEncode(data), headers: defaultHeaders);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: defaultHeaders);
        break;
      default:
        throw Exception('Método HTTP no soportado: $method');
    }

    return _handleResponse(response, uri);
  }

  dynamic _handleResponse(http.Response response, Uri uri) {
    final contentType = response.headers['content-type'] ?? '';
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (contentType.contains('application/json')) {
        return jsonDecode(response.body);
      } else {
        print(
            '[Advertencia] Respuesta de $uri no es JSON (content-type: $contentType).');
        return response.body;
      }
    } else {
      throw Exception(
          'Error HTTP ${response.statusCode}: ${response.body}');
    }
  }

  void _handleError(dynamic error, String endpoint) {
    throw Exception('Error en la petición HTTP a "$endpoint": $error');
  }
}
