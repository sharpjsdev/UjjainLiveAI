import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/location_info.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  LocationInfo? _lastKnownLocation;

  LocationInfo? get lastKnownLocation => _lastKnownLocation;

  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Permission.location.request();
      return permission == PermissionStatus.granted;
    } catch (e) {
      print('Location permission request failed: $e');
      return false;
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('Error checking location service: $e');
      return false;
    }
  }

  /// Fetches actual current GPS coordinates of the user.
  /// Always prioritizes fresh satellite/network fix (high accuracy) first,
  /// falling back to cached position only if live fix is unavailable.
  Future<LocationInfo?> getCurrentLocation({bool forceRefresh = false}) async {
    try {
      // 1. Check if location services are enabled on device
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('[LocationService] Location service disabled on device');
        return forceRefresh ? null : _lastKnownLocation;
      }

      // 2. Check & request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('[LocationService] Location permission denied: $permission');
        return forceRefresh ? null : _lastKnownLocation;
      }

      Position? position;

      // 3. Always attempt to acquire fresh, live GPS coordinates first (not static/cached)
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 4),
        );
        print(
          '[LocationService] Acquired fresh live GPS coordinates: ${position.latitude}, ${position.longitude}',
        );
      } catch (e) {
        print(
          '[LocationService] Live GPS query timed out/unavailable ($e), falling back to cached...',
        );
      }

      // 4. Fallback to last known position only if live GPS could not get a lock
      if (position == null && !forceRefresh) {
        try {
          position = await Geolocator.getLastKnownPosition();
          if (position != null) {
            print(
              '[LocationService] Fallback to last known position: ${position.latitude}, ${position.longitude}',
            );
          }
        } catch (_) {}
      }

      if (position == null) {
        print('[LocationService] No location available from GPS or cache');
        return forceRefresh ? null : _lastKnownLocation;
      }

      // 5. Try reverse geocoding (fails gracefully in offline mode)
      String? street;
      String? city;
      String? country;
      String? postalCode;

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          street = placemark.street;
          city = placemark.locality;
          country = placemark.country;
          postalCode = placemark.postalCode;
        }
      } catch (_) {
        // Expected offline: reverse geocoding requires internet
      }

      // 6. If city couldn't be resolved (offline mode), use offline coordinate-to-city lookup
      city ??= _resolveOfflineCity(position.latitude, position.longitude);

      final address = (street != null && city != null)
          ? '$street, $city'
          : (city != null
                ? '$city${country != null ? ", $country" : ""}'
                : 'Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}');

      final locationInfo = LocationInfo(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        city: city,
        country: country ?? 'India',
        postalCode: postalCode,
      );

      _lastKnownLocation = locationInfo;
      return locationInfo;
    } catch (e) {
      print('[LocationService] Error getting current location: $e');
      return _lastKnownLocation;
    }
  }

  /// Offline coordinate-to-city mapper so city is known even without internet
  String _resolveOfflineCity(double lat, double lon) {
    const cities = [
      {'name': 'Ujjain', 'lat': 23.1827, 'lon': 75.7682, 'radius': 25.0},
      {'name': 'Dewas', 'lat': 22.9623, 'lon': 76.0509, 'radius': 25.0},
      {'name': 'Indore', 'lat': 22.7196, 'lon': 75.8577, 'radius': 35.0},
      {'name': 'Bhopal', 'lat': 23.2599, 'lon': 77.4126, 'radius': 40.0},
      {'name': 'Ratlam', 'lat': 23.3315, 'lon': 75.0367, 'radius': 30.0},
      {'name': 'Nagda', 'lat': 23.4560, 'lon': 75.4180, 'radius': 25.0},
      {'name': 'Omkareshwar', 'lat': 22.2434, 'lon': 76.1499, 'radius': 25.0},
      {'name': 'Gwalior', 'lat': 26.2183, 'lon': 78.1828, 'radius': 40.0},
      {'name': 'Jabalpur', 'lat': 23.1815, 'lon': 79.9864, 'radius': 40.0},
      {'name': 'Ahmedabad', 'lat': 23.0225, 'lon': 72.5714, 'radius': 45.0},
      {'name': 'Jaipur', 'lat': 26.9124, 'lon': 75.7873, 'radius': 45.0},
      {'name': 'Delhi', 'lat': 28.6139, 'lon': 77.2090, 'radius': 50.0},
      {'name': 'Mumbai', 'lat': 19.0760, 'lon': 72.8777, 'radius': 50.0},
      {'name': 'Pune', 'lat': 18.5204, 'lon': 73.8567, 'radius': 45.0},
      {'name': 'Nagpur', 'lat': 21.1458, 'lon': 79.0882, 'radius': 45.0},
      {'name': 'Hyderabad', 'lat': 17.3850, 'lon': 78.4867, 'radius': 45.0},
      {'name': 'Bengaluru', 'lat': 12.9716, 'lon': 77.5946, 'radius': 45.0},
      {'name': 'Lucknow', 'lat': 26.8467, 'lon': 80.9462, 'radius': 45.0},
      {'name': 'Varanasi', 'lat': 25.3176, 'lon': 82.9739, 'radius': 40.0},
    ];

    for (final c in cities) {
      final d =
          Geolocator.distanceBetween(
            lat,
            lon,
            c['lat'] as double,
            c['lon'] as double,
          ) /
          1000;
      if (d <= (c['radius'] as double)) {
        return c['name'] as String;
      }
    }
    return 'Madhya Pradesh';
  }

  Future<LocationInfo?> getLocationFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) return null;

      final location = locations.first;

      // Get detailed address information safely
      String? street;
      String? locality;
      String? country;
      String? postalCode;

      try {
        final placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          street = placemark.street;
          locality = placemark.locality;
          country = placemark.country;
          postalCode = placemark.postalCode;
        }
      } catch (_) {}

      return LocationInfo(
        latitude: location.latitude,
        longitude: location.longitude,
        address: (street != null && locality != null)
            ? '$street, $locality'
            : address,
        city: locality,
        country: country,
        postalCode: postalCode,
      );
    } catch (e) {
      print('[LocationService] Error getting location from address: $e');
      return null;
    }
  }

  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) {
        return 'Lat: ${latitude.toStringAsFixed(4)}, Lon: ${longitude.toStringAsFixed(4)}';
      }

      final placemark = placemarks.first;
      final parts = [
        placemark.street,
        placemark.locality,
        placemark.country,
      ].where((p) => p != null && p.trim().isNotEmpty).join(', ');
      return parts.isNotEmpty
          ? parts
          : 'Lat: ${latitude.toStringAsFixed(4)}, Lon: ${longitude.toStringAsFixed(4)}';
    } catch (e) {
      print('[LocationService] Error getting address from coordinates: $e');
      return 'Lat: ${latitude.toStringAsFixed(4)}, Lon: ${longitude.toStringAsFixed(4)}';
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('Error getting last known position: $e');
      return null;
    }
  }

  Stream<Position> getPositionStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter:
          10, // minimum distance (in meters) to move before location update
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      print('Error opening location settings: $e');
      return false;
    }
  }

  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
      return false;
    }
  }
}
