import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_response.dart';
import '../../services/token_storage.dart';

/// API Client
/// HTTP isteklerini yöneten merkezi sınıf

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();

  /// Debug log helper
  void _log(String message) {
    if (kDebugMode) {
      debugPrint('🔗 API: $message');
    }
  }

  /// Headers oluştur (JWT token varsa ekle)
  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await TokenStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        _log('Token attached to request');
      }
    }

    return headers;
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    bool requiresAuth = false,
    T Function(dynamic)? fromJson,
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      _log('GET $uri');
      final response = await _client
          .get(uri, headers: await _getHeaders(requiresAuth: requiresAuth))
          .timeout(ApiConfig.timeout);

      _log('GET $uri -> ${response.statusCode}');
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      _log('GET ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      _log('POST $uri');
      if (body != null) {
        _log('Body: ${jsonEncode(body)}');
      }
      
      final response = await _client
          .post(
            uri,
            headers: await _getHeaders(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      _log('POST $uri -> ${response.statusCode}');
      _log('Response: ${response.body}');
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      _log('POST ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      _log('PATCH $uri');
      if (body != null) {
        _log('Body: ${jsonEncode(body)}');
      }
      
      final response = await _client
          .patch(
            uri,
            headers: await _getHeaders(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      _log('PATCH $uri -> ${response.statusCode}');
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      _log('PATCH ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      _log('DELETE $uri');
      
      final response = await _client
          .delete(uri, headers: await _getHeaders(requiresAuth: requiresAuth))
          .timeout(ApiConfig.timeout);

      _log('DELETE $uri -> ${response.statusCode}');
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      _log('DELETE ERROR: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Response handler
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    final statusCode = response.statusCode;
    
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse.success(null as T, statusCode: statusCode);
      }
      
      final data = jsonDecode(response.body);
      
      if (fromJson != null) {
        return ApiResponse.success(fromJson(data), statusCode: statusCode);
      }
      
      return ApiResponse.success(data as T, statusCode: statusCode);
    } else {
      String errorMessage = 'Bir hata oluştu';
      
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (_) {}
      
      return ApiResponse.error(errorMessage, statusCode: statusCode);
    }
  }
}
