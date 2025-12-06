import 'package:latlong2/latlong.dart';

/// Hospital model class for GeoJSON parsing
/// Handles coordinate swap: GeoJSON [lon, lat] -> LatLng(lat, lon)
class Hospital {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? city;
  final String? district;
  final String? phone;
  final String? website;
  final bool hasEmergency;
  final String? operator;

  Hospital({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.city,
    this.district,
    this.phone,
    this.website,
    this.hasEmergency = false,
    this.operator,
  });

  /// Parse from GeoJSON feature
  /// CRITICAL: GeoJSON coordinates are [longitude, latitude]
  /// Flutter LatLng expects (latitude, longitude) - SWAP REQUIRED
  factory Hospital.fromGeoJson(Map<String, dynamic> feature) {
    final properties = feature['properties'] as Map<String, dynamic>? ?? {};
    final geometry = feature['geometry'] as Map<String, dynamic>? ?? {};
    final coordinates = geometry['coordinates'] as List<dynamic>? ?? [0.0, 0.0];
    
    // SWAP: GeoJSON [lon, lat] -> LatLng(lat, lon)
    final double longitude = (coordinates[0] as num).toDouble();
    final double latitude = (coordinates[1] as num).toDouble();
    
    return Hospital(
      id: feature['id']?.toString() ?? properties['@id']?.toString() ?? '',
      name: properties['name']?.toString() ?? 'Bilinmeyen Hastane',
      latitude: latitude,
      longitude: longitude,
      city: properties['addr:city']?.toString(),
      district: properties['addr:district']?.toString(),
      phone: properties['phone']?.toString() ?? properties['contact:phone']?.toString(),
      website: properties['website']?.toString(),
      hasEmergency: properties['emergency'] == 'yes',
      operator: properties['operator']?.toString(),
    );
  }

  /// Get LatLng for map marker
  LatLng get latLng => LatLng(latitude, longitude);

  /// Display name with city
  String get displayName {
    if (city != null) {
      return '$name - $city';
    }
    return name;
  }
}
