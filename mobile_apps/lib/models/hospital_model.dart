import 'package:latlong2/latlong.dart';

/// Hospital model class for GeoJSON parsing
/// Handles coordinate swap: GeoJSON [lon, lat] -> LatLng(lat, lon)
class Hospital {
  final String? id;
  final String name;
  final double latitude;
  final double longitude;
  final String? category;
  final String? address;
  final String? phone;
  final String? website;
  final String? url; // Google Maps URL
  final String? imageUrl;
  final String? placeId;

  Hospital({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.category,
    this.address,
    this.phone,
    this.website,
    this.url,
    this.imageUrl,
    this.placeId,
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
    
    // Handle phone - check for "Telefon Yok" or empty
    String? phone = properties['phone']?.toString();
    if (phone == 'Telefon Yok' || phone?.isEmpty == true) {
      phone = null;
    }
    
    // Handle website - check for empty
    String? website = properties['website']?.toString();
    if (website?.isEmpty == true) {
      website = null;
    }
    
    return Hospital(
      id: feature['id']?.toString() ?? properties['placeId']?.toString(),
      name: properties['name']?.toString() ?? 'Bilinmeyen Hastane',
      latitude: latitude,
      longitude: longitude,
      category: properties['category']?.toString(),
      address: properties['address']?.toString(),
      phone: phone,
      website: website,
      url: properties['url']?.toString(),
      imageUrl: properties['imageUrl']?.toString(),
      placeId: properties['placeId']?.toString(),
    );
  }

  /// Get LatLng for map marker
  LatLng get latLng => LatLng(latitude, longitude);

  /// Check if has valid image
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  
  /// Check if has Google Maps URL
  bool get hasGoogleMapsUrl => url != null && url!.isNotEmpty;
}
