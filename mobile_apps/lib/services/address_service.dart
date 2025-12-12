import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/address_models.dart';

/// Service for loading and parsing address data from JSON
class AddressService {
  static List<CityModel>? _cachedCities;

  /// Loads cities from the assets/data/data.json file
  /// Returns cached data if already loaded
  static Future<List<CityModel>> loadCities() async {
    if (_cachedCities != null) {
      return _cachedCities!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/data/data.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedCities = jsonList.map((city) => CityModel.fromJson(city)).toList();
      
      // Sort cities alphabetically
      _cachedCities!.sort((a, b) => a.name.compareTo(b.name));
      
      return _cachedCities!;
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  /// Clears the cached cities (useful for testing)
  static void clearCache() {
    _cachedCities = null;
  }
}
