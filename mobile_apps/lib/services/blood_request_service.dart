import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import '../core/api/api_response.dart';
import '../models/blood_request_model.dart';
import 'token_storage.dart';

/// Blood Request Service
/// Kan talebi işlemlerini yönetir

class BloodRequestService {
  static final BloodRequestService _instance = BloodRequestService._internal();
  factory BloodRequestService() => _instance;
  BloodRequestService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Yeni kan talebi oluştur
  Future<ApiResponse<Map<String, dynamic>>> createRequest({
    required String hospitalName,
    required BloodType bloodType,
    required int unitsNeeded,
    required double latitude,
    required double longitude,
    required Urgency urgency,
    String? description,
  }) async {
    // User ID'yi token'dan veya storage'dan al
    final userId = await TokenStorage.getUserId();
    
    if (userId == null) {
      return ApiResponse.error('Kullanıcı girişi yapılmamış');
    }

    final dto = CreateBloodRequestDto(
      requesterId: userId,
      hospitalName: hospitalName,
      bloodType: bloodType.value,
      unitsNeeded: unitsNeeded,
      latitude: latitude,
      longitude: longitude,
      urgency: urgency.value,
      description: description,
    );

    return await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.request,
      body: dto.toJson(),
      requiresAuth: true,
    );
  }

  /// Tüm kan taleplerini listele
  Future<ApiResponse<List<BloodRequest>>> getAllRequests() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConfig.request,
    );

    if (response.success && response.data != null) {
      final requests = response.data!
          .map((json) => BloodRequest.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(requests, statusCode: response.statusCode);
    }

    return ApiResponse.error(
      response.message ?? 'Talepler yüklenemedi',
      statusCode: response.statusCode,
    );
  }

  /// Yakındaki kan taleplerini bul
  Future<ApiResponse<List<BloodRequest>>> getNearbyRequests({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConfig.requestNearby,
      queryParams: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
      },
    );

    if (response.success && response.data != null) {
      final requests = response.data!
          .map((json) => BloodRequest.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(requests, statusCode: response.statusCode);
    }

    return ApiResponse.error(
      response.message ?? 'Yakın talepler yüklenemedi',
      statusCode: response.statusCode,
    );
  }

  /// Kan talebini kabul et (donör)
  Future<ApiResponse<Map<String, dynamic>>> acceptRequest({
    required String requestId,
  }) async {
    final userId = await TokenStorage.getUserId();
    
    if (userId == null) {
      return ApiResponse.error('Kullanıcı girişi yapılmamış');
    }

    return await _apiClient.post<Map<String, dynamic>>(
      '${ApiConfig.request}/$requestId/accept',
      body: {'donorId': userId},
      requiresAuth: true,
    );
  }

  /// Bağışı bildir (donör merkeze varınca)
  Future<ApiResponse<Map<String, dynamic>>> reportDonation({
    required String requestId,
  }) async {
    final userId = await TokenStorage.getUserId();
    
    if (userId == null) {
      return ApiResponse.error('Kullanıcı girişi yapılmamış');
    }

    return await _apiClient.post<Map<String, dynamic>>(
      '${ApiConfig.request}/$requestId/report',
      body: {'donorId': userId},
      requiresAuth: true,
    );
  }

  /// Bağışı onayla (talep sahibi)
  Future<ApiResponse<Map<String, dynamic>>> confirmDonation({
    required String requestId,
  }) async {
    final userId = await TokenStorage.getUserId();
    
    if (userId == null) {
      return ApiResponse.error('Kullanıcı girişi yapılmamış');
    }

    return await _apiClient.post<Map<String, dynamic>>(
      '${ApiConfig.request}/$requestId/confirm',
      body: {'requesterId': userId},
      requiresAuth: true,
    );
  }

  /// Donör profilini getir
  Future<ApiResponse<Map<String, dynamic>>> getDonorProfile(String userId) async {
    return await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.requestProfile}/$userId',
    );
  }
}
