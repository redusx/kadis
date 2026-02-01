/// Blood Type Enum
enum BloodType {
  aRhPos('A_RH_POS', 'A Rh+'),
  aRhNeg('A_RH_NEG', 'A Rh-'),
  bRhPos('B_RH_POS', 'B Rh+'),
  bRhNeg('B_RH_NEG', 'B Rh-'),
  abRhPos('AB_RH_POS', 'AB Rh+'),
  abRhNeg('AB_RH_NEG', 'AB Rh-'),
  oRhPos('O_RH_POS', '0 Rh+'),
  oRhNeg('O_RH_NEG', '0 Rh-');

  final String value;
  final String displayName;
  const BloodType(this.value, this.displayName);

  static BloodType fromValue(String value) {
    return BloodType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BloodType.aRhPos,
    );
  }
}

/// Urgency Enum
enum Urgency {
  low('LOW', 'Düşük'),
  medium('MEDIUM', 'Orta'),
  high('HIGH', 'Yüksek'),
  critical('CRITICAL', 'Kritik');

  final String value;
  final String displayName;
  const Urgency(this.value, this.displayName);

  static Urgency fromValue(String value) {
    return Urgency.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Urgency.high,
    );
  }
}

/// Request Status Enum
enum RequestStatus {
  pending('PENDING', 'Beklemede'),
  active('ACTIVE', 'Aktif'),
  fulfilled('FULFILLED', 'Tamamlandı'),
  cancelled('CANCELLED', 'İptal Edildi'),
  expired('EXPIRED', 'Süresi Doldu');

  final String value;
  final String displayName;
  const RequestStatus(this.value, this.displayName);

  static RequestStatus fromValue(String value) {
    return RequestStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RequestStatus.pending,
    );
  }
}

/// Blood Request Model
class BloodRequest {
  final String id;
  final String requesterId;
  final String hospitalName;
  final BloodType bloodType;
  final int unitsNeeded;
  final Urgency urgency;
  final RequestStatus status;
  final String? description;
  final double? latitude;
  final double? longitude;
  final double? distanceMeters;
  final DateTime createdAt;
  final DateTime expiresAt;

  BloodRequest({
    required this.id,
    required this.requesterId,
    required this.hospitalName,
    required this.bloodType,
    required this.unitsNeeded,
    required this.urgency,
    required this.status,
    this.description,
    this.latitude,
    this.longitude,
    this.distanceMeters,
    required this.createdAt,
    required this.expiresAt,
  });

  factory BloodRequest.fromJson(Map<String, dynamic> json) {
    return BloodRequest(
      id: json['id'] ?? '',
      requesterId: json['requesterId'] ?? '',
      hospitalName: json['hospitalName'] ?? '',
      bloodType: BloodType.fromValue(json['bloodType'] ?? 'A_RH_POS'),
      unitsNeeded: json['unitsNeeded'] ?? 1,
      urgency: Urgency.fromValue(json['urgency'] ?? 'HIGH'),
      status: RequestStatus.fromValue(json['status'] ?? 'PENDING'),
      description: json['description'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      distanceMeters: json['distance_meters']?.toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(json['expiresAt'] ?? '') ?? DateTime.now().add(const Duration(hours: 24)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requesterId': requesterId,
      'hospitalName': hospitalName,
      'bloodType': bloodType.value,
      'unitsNeeded': unitsNeeded,
      'urgency': urgency.value,
      'status': status.value,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  /// Distance'ı km olarak göster
  String get distanceDisplay {
    if (distanceMeters == null) return '';
    if (distanceMeters! < 1000) {
      return '${distanceMeters!.toInt()} m';
    }
    return '${(distanceMeters! / 1000).toStringAsFixed(1)} km';
  }
}

/// Create Blood Request DTO
class CreateBloodRequestDto {
  final String requesterId;
  final String hospitalName;
  final String bloodType;
  final int unitsNeeded;
  final double latitude;
  final double longitude;
  final String urgency;
  final String? description;

  CreateBloodRequestDto({
    required this.requesterId,
    required this.hospitalName,
    required this.bloodType,
    required this.unitsNeeded,
    required this.latitude,
    required this.longitude,
    required this.urgency,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'requesterId': requesterId,
      'hospitalName': hospitalName,
      'bloodType': bloodType,
      'unitsNeeded': unitsNeeded,
      'latitude': latitude,
      'longitude': longitude,
      'urgency': urgency,
      if (description != null) 'description': description,
    };
  }
}
