/// API Response wrapper
/// Generic API yanıt modeli

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
  });

  factory ApiResponse.success(T data, {int statusCode = 200}) {
    return ApiResponse(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message, {int statusCode = 500}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}

/// API Error model
class ApiError {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiError({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => message;
}
