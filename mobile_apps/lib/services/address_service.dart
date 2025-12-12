import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/address_models.dart';

/// Top-level function for compute - must be top-level or static
List<CityModel> _parseJsonInBackground(String jsonString) {
  final List<dynamic> jsonList = json.decode(jsonString);
  final cities = jsonList.map((city) => CityModel.fromJson(city)).toList();
  // Sort cities alphabetically
  cities.sort((a, b) => a.name.compareTo(b.name));
  return cities;
}

/// Service for loading and parsing address data from JSON
/// Uses compute() for background parsing to avoid UI freeze
class AddressService {
  static List<CityModel>? _cachedCities;

  /// Loads cities from the assets/data/turkey_locations.json file
  /// Uses compute() for background thread parsing
  /// Returns cached data if already loaded
  static Future<List<CityModel>> loadCities() async {
    if (_cachedCities != null) {
      return _cachedCities!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/turkey_locations.json',
      );

      // Parse in background thread to avoid UI freeze
      _cachedCities = await compute(_parseJsonInBackground, jsonString);

      return _cachedCities!;
    } catch (e) {
      debugPrint('AddressService error: $e');
      // Return empty list on error
      return [];
    }
  }

  /// Clears the cached cities (useful for testing)
  static void clearCache() {
    _cachedCities = null;
  }
}
