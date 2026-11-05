// Map Marker Model for OpenStreetMap Integration
import 'package:latlong2/latlong.dart';

class MapMarkerData {
  final String id;
  final String name;
  final String hindiName;
  final LatLng position;
  final String category;
  final String icon;
  final String description;
  final String? timing;
  final String? gates;
  final String? pricing;

  MapMarkerData({
    required this.id,
    required this.name,
    required this.hindiName,
    required this.position,
    required this.category,
    required this.icon,
    required this.description,
    this.timing,
    this.gates,
    this.pricing,
  });

  // Convert from SimhasthaPlace model
  factory MapMarkerData.fromSimhasthaPlace(dynamic place) {
    return MapMarkerData(
      id: place.id,
      name: place.name,
      hindiName: place.hindiName,
      position: LatLng(place.lat, place.lon),
      category: place.category,
      icon: place.icon,
      description: place.description,
      timing: place.timing,
      gates: place.gates,
      pricing: place.pricing,
    );
  }
}

// Predefined important locations in Ujjain
class UjjainLocations {
  static final LatLng mahakaleshwar = LatLng(23.1827, 75.7682);
  static final LatLng kalBhairav = LatLng(23.1892, 75.7757);
  static final LatLng harsiddhi = LatLng(23.1816, 75.7704);
  static final LatLng ramGhat = LatLng(23.1867, 75.7744);
  static final LatLng ujjainRailway = LatLng(23.17954, 75.78195);
  static final LatLng ujjainCenter = mahakaleshwar; // Default center

  // Bounds for Ujjain city
  static const double minLat = 23.140;
  static const double maxLat = 23.225;
  static const double minLon = 75.725;
  static const double maxLon = 75.815;
}
