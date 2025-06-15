// lib/services/requesthandler.dart

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class RequestHandler {
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

  /// Envía un PUT multipart/form-data con campos de texto y archivos.
  Future<dynamic> putMultipart(
      String endpoint, {
        Map<String, String>? data,
        Map<String, String>? files,
        Map<String, String>? params,
        Map<String, String>? headers,
      }) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: params);
    print('[Intentando PUT multipart en: $uri]');

    final request = http.MultipartRequest('PUT', uri);

    if (headers != null) {
      request.headers.addAll(headers);
    }

    // Agregar campos de texto
    if (data != null) {
      request.fields.addAll(data);
    }

    // Agregar archivos
    if (files != null) {
      for (final entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            entry.value,
            filename: entry.value.split('/').last,
          ),
        );
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response, uri);
  }

  Future<dynamic> postMultipart(
      String endpoint, {
        Map<String, String>? data,
        Map<String, String>? files,
        Map<String, String>? params,
        Map<String, String>? headers,
      }) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: params);
    print('[Intentando POST multipart en: $uri]');

    final request = http.MultipartRequest('POST', uri);

    if (headers != null) request.headers.addAll(headers);

    if (data != null) request.fields.addAll(data);

    if (files != null) {
      for (final entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            entry.value,
            filename: entry.value.split('/').last,
          ),
        );
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response, uri);
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
            '[Advertencia] Respuesta de $uri no es JSON (content-type: $contentType).'
        );
        return response.body;
      }
    } else {
      throw Exception(
          'Error HTTP ${response.statusCode}: ${response.body}'
      );
    }
  }

  void _handleError(dynamic error, String endpoint) {
    throw Exception('Error en la petición HTTP a "$endpoint": $error');
  }
}
