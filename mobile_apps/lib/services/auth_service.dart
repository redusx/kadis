import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import '../core/api/api_response.dart';
import 'token_storage.dart';

/// Auth Service
/// Kimlik doğrulama işlemlerini yönetir

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Giriş yap
  /// Başarılı girişte JWT token döner ve saklanır
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.authLogin,
      body: {
        'phoneNumber': phoneNumber,
        'password': password,
      },
    );

    if (response.success && response.data != null) {
      final token = response.data!['access_token'] as String?;
      if (token != null) {
        await TokenStorage.saveToken(token);
        await TokenStorage.savePhoneNumber(phoneNumber);
        
        // Token'dan user bilgilerini decode edebiliriz (opsiyonel)
        // Şimdilik sadece token'ı saklıyoruz
      }
    }

    return response;
  }

  /// Kayıt ol
  Future<ApiResponse<Map<String, dynamic>>> signup({
    required String phoneNumber,
    required String password,
    String role = 'DONOR',
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.authSignup,
      body: {
        'phoneNumber': phoneNumber,
        'password': password,
        'role': role,
      },
    );

    return response;
  }

  /// Çıkış yap
  Future<void> logout() async {
    await TokenStorage.clearAll();
  }

  /// Giriş yapılmış mı kontrol et
  Future<bool> isLoggedIn() async {
    return await TokenStorage.hasToken();
  }

  /// Mevcut token'ı al
  Future<String?> getToken() async {
    return await TokenStorage.getToken();
  }

  /// Hesabı sil
  Future<ApiResponse<Map<String, dynamic>>> deleteAccount() async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiConfig.authDelete,
      requiresAuth: true,
    );

    if (response.success) {
      await logout();
    }

    return response;
  }
}
