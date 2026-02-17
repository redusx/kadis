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
  
  /// Log seviyesini kontrol etmek için
  static bool verboseLogging = true;

  /// Timestamp formatter
  String _timestamp() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';
  }

  /// Debug log helper
  void _log(String message, {String level = 'INFO'}) {
    if (kDebugMode) {
      final emoji = switch (level) {
        'ERROR' => '❌',
        'SUCCESS' => '✅',
        'REQUEST' => '📤',
        'RESPONSE' => '📥',
        'WARNING' => '⚠️',
        _ => '🔗',
      };
      debugPrint('$emoji [${_timestamp()}] API: $message');
    }
  }

  /// Detaylı request log
  void _logRequest(String method, Uri uri, Map<String, String> headers, dynamic body) {
    if (kDebugMode && verboseLogging) {
      debugPrint('');
      debugPrint('╔══════════════════════════════════════════════════════════════');
      debugPrint('║ 📤 REQUEST: $method ${uri.path}');
      debugPrint('║ ⏰ Time: ${_timestamp()}');
      debugPrint('║ 🌐 Full URL: $uri');
      debugPrint('║ 📋 Headers:');
      headers.forEach((key, value) {
        // Authorization header'ı gizle
        if (key.toLowerCase() == 'authorization') {
          debugPrint('║    $key: Bearer ***[HIDDEN]***');
        } else {
          debugPrint('║    $key: $value');
        }
      });
      if (body != null) {
        debugPrint('║ 📦 Body:');
        try {
          final prettyJson = const JsonEncoder.withIndent('  ').convert(body);
          for (final line in prettyJson.split('\n')) {
            debugPrint('║    $line');
          }
        } catch (_) {
          debugPrint('║    $body');
        }
      }
      debugPrint('╚══════════════════════════════════════════════════════════════');
      debugPrint('');
    }
  }

  /// Detaylı response log
  void _logResponse(String method, Uri uri, int statusCode, String body, Duration duration) {
    if (kDebugMode && verboseLogging) {
      final isSuccess = statusCode >= 200 && statusCode < 300;
      final emoji = isSuccess ? '✅' : '❌';
      
      debugPrint('');
      debugPrint('╔══════════════════════════════════════════════════════════════');
      debugPrint('║ $emoji RESPONSE: $method ${uri.path}');
      debugPrint('║ ⏰ Time: ${_timestamp()} (${duration.inMilliseconds}ms)');
      debugPrint('║ 📊 Status: $statusCode ${_getStatusText(statusCode)}');
      debugPrint('║ 📦 Body:');
      try {
        if (body.isNotEmpty) {
          final dynamic jsonBody = jsonDecode(body);
          final prettyJson = const JsonEncoder.withIndent('  ').convert(jsonBody);
          for (final line in prettyJson.split('\n')) {
            debugPrint('║    $line');
          }
        } else {
          debugPrint('║    [Empty Response]');
        }
      } catch (_) {
        // JSON değilse direkt yazdır
        final truncated = body.length > 500 ? '${body.substring(0, 500)}...[truncated]' : body;
        debugPrint('║    $truncated');
      }
      debugPrint('╚══════════════════════════════════════════════════════════════');
      debugPrint('');
    }
  }

  /// Hata log
  void _logError(String method, Uri uri, dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('╔══════════════════════════════════════════════════════════════');
      debugPrint('║ ❌ ERROR: $method ${uri.path}');
      debugPrint('║ ⏰ Time: ${_timestamp()}');
      debugPrint('║ 🚨 Error: $error');
      if (stackTrace != null && verboseLogging) {
        debugPrint('║ 📍 Stack Trace:');
        final lines = stackTrace.toString().split('\n').take(10);
        for (final line in lines) {
          debugPrint('║    $line');
        }
      }
      debugPrint('╚══════════════════════════════════════════════════════════════');
      debugPrint('');
    }
  }

  /// HTTP status code açıklaması
  String _getStatusText(int code) {
    return switch (code) {
      200 => 'OK',
      201 => 'Created',
      204 => 'No Content',
      400 => 'Bad Request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not Found',
      409 => 'Conflict',
      422 => 'Unprocessable Entity',
      500 => 'Internal Server Error',
      502 => 'Bad Gateway',
      503 => 'Service Unavailable',
      _ => '',
    };
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
    final stopwatch = Stopwatch()..start();
    Uri? uri;
    
    try {
      uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await _getHeaders(requiresAuth: requiresAuth);
      _logRequest('GET', uri, headers, null);
      
      final response = await _client
          .get(uri, headers: headers)
          .timeout(ApiConfig.timeout);

      stopwatch.stop();
      _logResponse('GET', uri, response.statusCode, response.body, stopwatch.elapsed);
      return _handleResponse<T>(response, fromJson, 'GET', uri, stopwatch.elapsed);
    } catch (e, stackTrace) {
      stopwatch.stop();
      _logError('GET', uri ?? Uri.parse(endpoint), e, stackTrace);
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
    final stopwatch = Stopwatch()..start();
    Uri? uri;
    
    try {
      uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      _logRequest('POST', uri, headers, body);
      
      final response = await _client
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      stopwatch.stop();
      _logResponse('POST', uri, response.statusCode, response.body, stopwatch.elapsed);
      return _handleResponse<T>(response, fromJson, 'POST', uri, stopwatch.elapsed);
    } catch (e, stackTrace) {
      stopwatch.stop();
      _logError('POST', uri ?? Uri.parse(endpoint), e, stackTrace);
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
    final stopwatch = Stopwatch()..start();
    Uri? uri;
    
    try {
      uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      _logRequest('PATCH', uri, headers, body);
      
      final response = await _client
          .patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      stopwatch.stop();
      _logResponse('PATCH', uri, response.statusCode, response.body, stopwatch.elapsed);
      return _handleResponse<T>(response, fromJson, 'PATCH', uri, stopwatch.elapsed);
    } catch (e, stackTrace) {
      stopwatch.stop();
      _logError('PATCH', uri ?? Uri.parse(endpoint), e, stackTrace);
      return ApiResponse.error(e.toString());
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    final stopwatch = Stopwatch()..start();
    Uri? uri;
    
    try {
      uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      _logRequest('DELETE', uri, headers, null);
      
      final response = await _client
          .delete(uri, headers: headers)
          .timeout(ApiConfig.timeout);

      stopwatch.stop();
      _logResponse('DELETE', uri, response.statusCode, response.body, stopwatch.elapsed);
      return _handleResponse<T>(response, fromJson, 'DELETE', uri, stopwatch.elapsed);
    } catch (e, stackTrace) {
      stopwatch.stop();
      _logError('DELETE', uri ?? Uri.parse(endpoint), e, stackTrace);
      return ApiResponse.error(e.toString());
    }
  }

  /// Response handler
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
    String method,
    Uri uri,
    Duration duration,
  ) {
    final statusCode = response.statusCode;
    
    if (statusCode >= 200 && statusCode < 300) {
      _log('$method ${uri.path} başarılı (${duration.inMilliseconds}ms)', level: 'SUCCESS');
      
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
      
      _log('$method ${uri.path} başarısız: $statusCode - $errorMessage', level: 'ERROR');
      return ApiResponse.error(errorMessage, statusCode: statusCode);
    }
  }
}
