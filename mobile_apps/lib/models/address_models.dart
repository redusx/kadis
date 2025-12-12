/// Address models for parsing Turkish address data from minified JSON (3-Layer)
/// JSON Keys: n=name, t=towns, q=quarters, lat=latitude, lng=longitude
/// Hierarchy: City (İl) -> Town (İlçe) -> Quarter (Mahalle)
/// Removed District (Semt) layer as per new requirements.

/// Represents a Quarter (Mahalle) with coordinates
class QuarterModel {
  final String name;
  final double? latitude;
  final double? longitude;

  QuarterModel({
    required this.name,
    this.latitude,
    this.longitude,
  });

  factory QuarterModel.fromJson(Map<String, dynamic> json) {
    return QuarterModel(
      name: json['n'] ?? '',
      latitude: double.tryParse(json['lat']?.toString() ?? ''),
      longitude: double.tryParse(json['lng']?.toString() ?? ''),
    );
  }
}

/// Represents a Town (İlçe)
class TownModel {
  final String name;
  final List<QuarterModel> quarters;

  TownModel({required this.name, required this.quarters});

  factory TownModel.fromJson(Map<String, dynamic> json) {
    return TownModel(
      name: json['n'] ?? '',
      quarters: (json['q'] as List<dynamic>?)
              ?.map((q) => QuarterModel.fromJson(q))
              .toList() ??
          [],
    );
  }
}

/// Represents a City (İl)
class CityModel {
  final String name;
  final List<TownModel> towns;

  CityModel({
    required this.name,
    required this.towns,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['n'] ?? '',
      towns: (json['t'] as List<dynamic>?)
              ?.map((t) => TownModel.fromJson(t))
              .toList() ??
          [],
    );
  }
}
