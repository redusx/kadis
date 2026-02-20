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
      // Backend TransformInterceptor yanıtı { success, data: { access_token, userId } } şeklinde sarar
      final responseData = response.data!;
      final String? token;
      final String? userId;
      
      if (responseData.containsKey('data') && responseData['data'] is Map) {
        // Wrapped response: { data: { access_token: "...", userId: "..." } }
        final innerData = responseData['data'] as Map<String, dynamic>;
        token = innerData['access_token'] as String?;
        userId = innerData['userId'] as String?;
      } else {
        // Direct response: { access_token: "...", userId: "..." }
        token = responseData['access_token'] as String?;
        userId = responseData['userId'] as String?;
      }
      
      if (token != null) {
        await TokenStorage.saveToken(token);
        await TokenStorage.savePhoneNumber(phoneNumber);
      }
      if (userId != null) {
        await TokenStorage.saveUserId(userId);
      }
    }

    return response;
  }

  /// Kayıt ol
  Future<ApiResponse<Map<String, dynamic>>> signup({
    required String phoneNumber,
    required String password,
    String role = 'DONOR',
    String? firstName,
    String? lastName,
    String? bloodType,
    String? gender,
    String? birthDate,
    int? weight,
    String? email,
    String? city,
    String? town,
    String? quarter,
    String? street,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      'phoneNumber': phoneNumber,
      'password': password,
      'role': role,
    };

    // Donor profile alanlarını ekle (varsa)
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (bloodType != null) body['bloodType'] = bloodType;
    if (gender != null) body['gender'] = gender;
    if (birthDate != null) body['birthDate'] = birthDate;
    if (weight != null) body['weight'] = weight;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (city != null && city.isNotEmpty) body['city'] = city;
    if (town != null && town.isNotEmpty) body['town'] = town;
    if (quarter != null && quarter.isNotEmpty) body['quarter'] = quarter;
    if (street != null && street.isNotEmpty) body['street'] = street;
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.authSignup,
      body: body,
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
