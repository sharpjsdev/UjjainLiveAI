import 'package:json_annotation/json_annotation.dart';

part 'location_info.g.dart';

@JsonSerializable()
class LocationInfo {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final DateTime timestamp;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory LocationInfo.fromJson(Map<String, dynamic> json) => _$LocationInfoFromJson(json);
  
  Map<String, dynamic> toJson() => _$LocationInfoToJson(this);

  @override
  String toString() {
    if (address != null) return address!;
    if (city != null && country != null) return '$city, $country';
    return 'Lat: $latitude, Lng: $longitude';
  }
}

@JsonSerializable()
class PlaceRecommendation {
  final String name;
  final String? description;
  final double? rating;
  final String? address;
  final String? phoneNumber;
  final String? website;
  final List<String> categories;
  final double? priceLevel;
  final Map<String, dynamic>? hours;
  final LocationInfo location;
  final List<String> photos;

  PlaceRecommendation({
    required this.name,
    this.description,
    this.rating,
    this.address,
    this.phoneNumber,
    this.website,
    this.categories = const [],
    this.priceLevel,
    this.hours,
    required this.location,
    this.photos = const [],
  });

  factory PlaceRecommendation.fromJson(Map<String, dynamic> json) => _$PlaceRecommendationFromJson(json);
  
  Map<String, dynamic> toJson() => _$PlaceRecommendationToJson(this);
}