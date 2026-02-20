import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import '../core/api/api_response.dart';
import '../models/user_model.dart';

/// User Service
/// Kullanıcı profil işlemlerini yönetir

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Kullanıcı profilini getir
  /// JWT token ile kimlik doğrulaması yapılır
  Future<ApiResponse<UserProfile>> getProfile() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.userProfile,
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      try {
        // Backend TransformInterceptor yanıtı { success, data: { ... } } şeklinde sarar
        final responseData = response.data!;
        final Map<String, dynamic> userData;
        
        if (responseData.containsKey('data') && responseData['data'] is Map) {
          userData = responseData['data'] as Map<String, dynamic>;
        } else {
          userData = responseData;
        }
        
        final userProfile = UserProfile.fromJson(userData);
        return ApiResponse.success(userProfile);
      } catch (e) {
        return ApiResponse.error('Profil verisi işlenemedi: $e');
      }
    }

    return ApiResponse.error(response.message ?? 'Profil getirilemedi', statusCode: response.statusCode);
  }

  /// Kullanıcı profilini güncelle
  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    String? phoneNumber,
  }) async {
    final body = <String, dynamic>{};
    if (phoneNumber != null) body['phoneNumber'] = phoneNumber;

    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiConfig.userUpdate,
      body: body,
      requiresAuth: true,
    );

    return response;
  }
}
