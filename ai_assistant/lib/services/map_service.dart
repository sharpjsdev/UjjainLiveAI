// OpenStreetMap Service
// Handles map routing, distance calculations, and location operations

import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import '../models/map_marker.dart';

class MapService {
  static final MapService _instance = MapService._internal();
  factory MapService() => _instance;
  MapService._internal();

  // Calculate distance between two points using Haversine formula
  double calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, point1, point2);
  }

  // Calculate bearing (direction) from point1 to point2
  double calculateBearing(LatLng point1, LatLng point2) {
    final lat1 = _toRadians(point1.latitude);
    final lat2 = _toRadians(point2.latitude);
    final dLon = _toRadians(point2.longitude - point1.longitude);

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final bearing = math.atan2(y, x);
    return (_toDegrees(bearing) + 360) % 360;
  }

  // Format distance for display
  String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} m';
    } else {
      return '${distanceInKm.toStringAsFixed(2)} km';
    }
  }

  // Estimate walking time (assuming 5 km/h)
  String estimateWalkingTime(double distanceInKm) {
    final minutes = (distanceInKm / 5.0 * 60).round();
    if (minutes < 60) {
      return '$minutes min walk';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours hr ${remainingMinutes > 0 ? "$remainingMinutes min" : ""} walk';
    }
  }

  // Estimate driving time (assuming 30 km/h in city)
  String estimateDrivingTime(double distanceInKm) {
    final minutes = (distanceInKm / 30.0 * 60).round();
    if (minutes < 60) {
      return '$minutes min drive';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours hr ${remainingMinutes > 0 ? "$remainingMinutes min" : ""} drive';
    }
  }

  // Create a simple straight-line route (polyline) between two points
  // For actual turn-by-turn navigation, you'd need OSRM or similar routing service
  List<LatLng> createStraightRoute(LatLng start, LatLng end, {int points = 50}) {
    final route = <LatLng>[];
    for (int i = 0; i <= points; i++) {
      final t = i / points;
      final lat = start.latitude + (end.latitude - start.latitude) * t;
      final lon = start.longitude + (end.longitude - start.longitude) * t;
      route.add(LatLng(lat, lon));
    }
    return route;
  }

  // Find nearest marker from a given location
  MapMarkerData? findNearestMarker(
    LatLng userLocation,
    List<MapMarkerData> markers,
  ) {
    if (markers.isEmpty) return null;

    MapMarkerData? nearest;
    double minDistance = double.infinity;

    for (final marker in markers) {
      final distance = calculateDistance(userLocation, marker.position);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = marker;
      }
    }

    return nearest;
  }

  // Check if location is within Ujjain bounds
  bool isWithinUjjainBounds(LatLng location) {
    return location.latitude >= UjjainLocations.minLat &&
        location.latitude <= UjjainLocations.maxLat &&
        location.longitude >= UjjainLocations.minLon &&
        location.longitude <= UjjainLocations.maxLon;
  }

  // Helper methods
  double _toRadians(double degrees) => degrees * math.pi / 180.0;
  double _toDegrees(double radians) => radians * 180.0 / math.pi;

  // Generate Google Maps URL for external navigation
  String generateGoogleMapsUrl(LatLng from, LatLng to) {
    return 'https://www.google.com/maps/dir/?api=1&origin=${from.latitude},${from.longitude}&destination=${to.latitude},${to.longitude}&travelmode=driving';
  }

  // Generate OpenStreetMap URL
  String generateOSMUrl(LatLng location) {
    return 'https://www.openstreetmap.org/?mlat=${location.latitude}&mlon=${location.longitude}&zoom=15';
  }
}
