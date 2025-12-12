/// Address models for parsing Turkish address data from JSON
/// Hierarchy: City (İl) -> Town (İlçe) -> District (Semt/Bucak) -> Quarter (Mahalle)

/// Represents a Quarter (Mahalle)
class QuarterModel {
  final String name;

  QuarterModel({required this.name});

  factory QuarterModel.fromJson(Map<String, dynamic> json) {
    return QuarterModel(name: json['name'] ?? '');
  }
}

/// Represents a District (Semt/Bucak)
class DistrictModel {
  final String name;
  final List<QuarterModel> quarters;

  DistrictModel({required this.name, required this.quarters});

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      name: json['name'] ?? '',
      quarters: (json['quarters'] as List<dynamic>?)
              ?.map((q) => QuarterModel.fromJson(q))
              .toList() ??
          [],
    );
  }
}

/// Represents a Town (İlçe)
class TownModel {
  final String name;
  final List<DistrictModel> districts;

  TownModel({required this.name, required this.districts});

  factory TownModel.fromJson(Map<String, dynamic> json) {
    return TownModel(
      name: json['name'] ?? '',
      districts: (json['districts'] as List<dynamic>?)
              ?.map((d) => DistrictModel.fromJson(d))
              .toList() ??
          [],
    );
  }
}

/// Represents a City (İl)
class CityModel {
  final String name;
  final String alpha2Code;
  final List<TownModel> towns;

  CityModel({
    required this.name,
    required this.alpha2Code,
    required this.towns,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] ?? '',
      alpha2Code: json['alpha_2_code'] ?? '',
      towns: (json['towns'] as List<dynamic>?)
              ?.map((t) => TownModel.fromJson(t))
              .toList() ??
          [],
    );
  }
}
