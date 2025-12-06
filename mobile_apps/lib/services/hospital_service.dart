import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hospital_model.dart';

/// Service for loading hospital data from GeoJSON
class HospitalService {
  static List<Hospital>? _cachedHospitals;

  /// Load hospitals from GeoJSON asset
  /// Uses caching to avoid reloading on every call
  static Future<List<Hospital>> loadHospitals() async {
    // Return cached data if available
    if (_cachedHospitals != null) {
      return _cachedHospitals!;
    }

    try {
      // Load GeoJSON from assets
      final String jsonString = await rootBundle.loadString(
        'assets/data/hospitals.geojson',
      );
      
      // Parse JSON
      final Map<String, dynamic> geoJson = json.decode(jsonString);
      final List<dynamic> features = geoJson['features'] as List<dynamic>? ?? [];
      
      // Convert features to Hospital objects
      _cachedHospitals = features
          .where((feature) => 
              feature['geometry'] != null && 
              feature['geometry']['coordinates'] != null)
          .map((feature) => Hospital.fromGeoJson(feature as Map<String, dynamic>))
          .toList();
      
      return _cachedHospitals!;
    } catch (e) {
      // Return empty list on error
      print('Error loading hospitals: $e');
      return [];
    }
  }

  /// Clear cached data (useful for refresh)
  static void clearCache() {
    _cachedHospitals = null;
  }
}
