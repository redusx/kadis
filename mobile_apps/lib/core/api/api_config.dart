/// API Configuration
/// Base URL ve timeout ayarları

class ApiConfig {
  // Fiziksel cihaz için local IP adresi kullanılıyor
  // Emulator için: http://10.0.2.2:3000 (Android) veya http://localhost:3000 (iOS)
  static const String baseUrl = 'http://192.168.1.104:3000';
  
  static const Duration timeout = Duration(seconds: 30);
  
  // API Endpoints
  static const String authLogin = '/auth/login';
  static const String authSignup = '/auth/signup';
  static const String authDelete = '/auth/delete';
  
  static const String userProfile = '/user/profile';
  static const String userUpdate = '/user';
  
  static const String request = '/request';
  static const String requestNearby = '/request/nearby';
  static const String requestAccept = '/request'; // /:id/accept
  static const String requestReport = '/request'; // /:id/report
  static const String requestConfirm = '/request'; // /:id/confirm
  static const String requestProfile = '/request/profile'; // /:userId
}
