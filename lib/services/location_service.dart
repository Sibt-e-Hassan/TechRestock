import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  LocationService._();

  static const String _cachedCityKey = 'cached_user_city';

  /// Gets the cached city from local storage, if any.
  static Future<String?> getCachedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_cachedCityKey);
    } catch (e) {
      debugPrint('LocationService: Failed to get cached city: $e');
      return null;
    }
  }

  /// Caches the city locally.
  static Future<void> cacheCity(String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cachedCityKey, city);
    } catch (e) {
      debugPrint('LocationService: Failed to cache city: $e');
    }
  }

  /// Clears the cached city.
  static Future<void> clearCachedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedCityKey);
    } catch (e) {
      debugPrint('LocationService: Failed to clear cached city: $e');
    }
  }

  /// Detects the user's current city based on device coordinates and reverse geocoding.
  /// Returns null if permission is denied, service is disabled, or geocoding fails.
  static Future<String?> detectCurrentCity() async {
    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('LocationService: Location services are disabled.');
        return null;
      }

      // 2. Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('LocationService: Location permissions are denied.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('LocationService: Location permissions are permanently denied.');
        return null;
      }

      // 3. Get the current position with a short timeout to prevent hanging UI
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 5),
        ),
      );

      // 4. Reverse geocode to get locality (city)
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 4));

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final city = placemark.locality ??
            placemark.subAdministrativeArea ??
            placemark.administrativeArea;

        if (city != null && city.trim().isNotEmpty) {
          final cleanCity = city.trim();
          debugPrint('LocationService: Detected city: $cleanCity');
          await cacheCity(cleanCity);
          return cleanCity;
        }
      }
    } catch (e) {
      debugPrint('LocationService error detecting city: $e');
    }
    return null;
  }
}
