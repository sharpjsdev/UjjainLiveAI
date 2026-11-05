// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationInfo _$LocationInfoFromJson(Map<String, dynamic> json) => LocationInfo(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$LocationInfoToJson(LocationInfo instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'postalCode': instance.postalCode,
      'timestamp': instance.timestamp.toIso8601String(),
    };

PlaceRecommendation _$PlaceRecommendationFromJson(Map<String, dynamic> json) =>
    PlaceRecommendation(
      name: json['name'] as String,
      description: json['description'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      address: json['address'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      priceLevel: (json['priceLevel'] as num?)?.toDouble(),
      hours: json['hours'] as Map<String, dynamic>?,
      location: LocationInfo.fromJson(json['location'] as Map<String, dynamic>),
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PlaceRecommendationToJson(
        PlaceRecommendation instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'rating': instance.rating,
      'address': instance.address,
      'phoneNumber': instance.phoneNumber,
      'website': instance.website,
      'categories': instance.categories,
      'priceLevel': instance.priceLevel,
      'hours': instance.hours,
      'location': instance.location,
      'photos': instance.photos,
    };
