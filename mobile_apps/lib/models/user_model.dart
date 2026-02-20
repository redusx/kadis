/// User Profile Model
/// Backend'den gelen kullanıcı profil verilerini temsil eder

class UserProfile {
  final String id;
  final String phoneNumber;
  final String? email;
  final String role;
  final bool isVerified;
  final bool kvkkConsent;
  final DateTime createdAt;
  final DonorProfileModel? donorProfile;

  UserProfile({
    required this.id,
    required this.phoneNumber,
    this.email,
    required this.role,
    required this.isVerified,
    required this.kvkkConsent,
    required this.createdAt,
    this.donorProfile,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      role: json['role'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
      kvkkConsent: json['kvkkConsent'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      donorProfile: json['donorProfile'] != null
          ? DonorProfileModel.fromJson(json['donorProfile'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Kullanıcının tam adını döndürür
  String get fullName {
    if (donorProfile != null) {
      return '${donorProfile!.firstName} ${donorProfile!.lastName}';
    }
    return phoneNumber;
  }

  /// Kan grubunu okunabilir formatta döndürür
  String get bloodTypeDisplay {
    if (donorProfile == null) return '-';
    return donorProfile!.bloodTypeDisplay;
  }
}

class DonorProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  final String bloodType;
  final String gender;
  final DateTime birthDate;
  final int? weight;
  final DateTime? lastDonationDate;
  final int totalDonations;
  final double trustScore;
  final String? city;
  final String? town;
  final String? quarter;
  final String? street;

  DonorProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.bloodType,
    required this.gender,
    required this.birthDate,
    this.weight,
    this.lastDonationDate,
    required this.totalDonations,
    required this.trustScore,
    this.city,
    this.town,
    this.quarter,
    this.street,
  });

  factory DonorProfileModel.fromJson(Map<String, dynamic> json) {
    return DonorProfileModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      bloodType: json['bloodType'] as String,
      gender: json['gender'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      weight: json['weight'] as int?,
      lastDonationDate: json['lastDonationDate'] != null
          ? DateTime.parse(json['lastDonationDate'] as String)
          : null,
      totalDonations: json['totalDonations'] as int? ?? 0,
      trustScore: (json['trustScore'] as num?)?.toDouble() ?? 10.0,
      city: json['city'] as String?,
      town: json['town'] as String?,
      quarter: json['quarter'] as String?,
      street: json['street'] as String?,
    );
  }

  /// Adres bilgisini okunabilir formatta döndürür
  String get addressDisplay {
    final parts = <String>[];
    if (quarter != null && quarter!.isNotEmpty) parts.add(quarter!);
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (town != null && town!.isNotEmpty) parts.add(town!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    return parts.isNotEmpty ? parts.join(', ') : 'Belirtilmemiş';
  }

  /// Kan grubunu okunabilir formatta döndürür (A_RH_POS → A+)
  String get bloodTypeDisplay {
    final map = {
      'A_RH_POS': 'A+',
      'A_RH_NEG': 'A-',
      'B_RH_POS': 'B+',
      'B_RH_NEG': 'B-',
      'AB_RH_POS': 'AB+',
      'AB_RH_NEG': 'AB-',
      'O_RH_POS': '0+',
      'O_RH_NEG': '0-',
    };
    return map[bloodType] ?? bloodType;
  }

  /// Cinsiyet okunabilir format
  String get genderDisplay {
    final map = {
      'MALE': 'Erkek',
      'FEMALE': 'Kadın',
      'OTHER': 'Diğer',
    };
    return map[gender] ?? gender;
  }

  /// Yaş hesapla
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
