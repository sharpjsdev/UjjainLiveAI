import 'dart:math' as math;

import 'package:dio/dio.dart';

import '../models/location_info.dart';

/// Searches OpenStreetMap data for real places around the user's location or
/// a place named in the query. No Google Places API key is required.
class PlaceSearchService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'User-Agent': 'SimhasthaAIAssistant/1.0'},
    ),
  );

  static bool shouldSearch(String text) {
    final message = text.toLowerCase();
    final placeTypes = [
      'hotel', 'hotels', 'dharamshala', 'guest house', 'hostel', 'motel',
      'restaurant', 'restaurants', 'cafe', 'cafes', 'coffee', 'food',
      'hospital', 'clinic', 'doctor', 'pharmacy', 'chemist', 'atm',
      'bank', 'fuel', 'petrol pump', 'gas station', 'parking', 'toilet',
      'temple', 'mandir', 'ghat', 'museum', 'tourist place', 'tourist attraction',
      'shop', 'supermarket', 'grocery', 'bookstore', 'bus stop', 'railway station',
      'accommodation', 'stay', 'eat', 'breakfast', 'lunch', 'dinner',
      'police station', 'school', 'park', 'cinema', 'mall', 'library',
      'aspatal', 'dawai', 'khana', 'होटल', 'धर्मशाला', 'रेस्टोरेंट', 'कैफे',
      'अस्पताल', 'फार्मेसी', 'दवा', 'मंदिर', 'एटीएम', 'पेट्रोल पंप',
    ];
    final hasPlaceType = placeTypes.any(message.contains);
    final asksForPlaces = [
      'near me', 'nearby', 'nearest', 'closest', 'near ', 'around ', 'close to',
      'find ', 'search ', 'show me', 'best ', 'recommend', 'suggest', ' in ',
      'good ', 'top ', 'all ', 'all the ', 'where can i', 'kahan', 'paas',
      'सारे', 'सभी', 'बताओ', 'के पास', 'आसपास', 'नज़दीक', 'नजदीक',
      'के नज़दीक', 'के नजदीक', 'निकट',
    ].any(message.contains);
    final lodgingTerms = [
      'hotel',
      'hotels',
      'lodging',
      'accommodation',
      'dharamshala',
      'guest house',
      'hostel',
      'होटल',
      'धर्मशाला',
      'अतिथि गृह',
    ];
    final isLodgingRequest = lodgingTerms.any(message.contains);
    return isLodgingRequest || (hasPlaceType && asksForPlaces);
  }

  Future<PlaceSearchResult> search({
    required String query,
    required String language,
    LocationInfo? userLocation,
  }) async {
    final category = _categoryFor(query);
    final anchor = _locationAnchor(query);
    if (anchor == null && userLocation == null) {
      return PlaceSearchResult(
        response: language.toLowerCase().startsWith('hi')
            ? 'आपके आस-पास के स्थान खोजने के लिए कृपया ऐप को GPS लोकेशन की अनुमति दें। किसी शहर या जगह का नाम बताकर भी खोज सकते हैं।'
            : 'Please allow GPS location to search nearby places, or include a city or landmark in your request.',
      );
    }
    LocationInfo? target;
    try {
      target = await _resolveTarget(anchor, userLocation);
    } catch (_) {
      // The full text search below can still return results if geocoding fails.
    }

    if (category != null && target != null) {
      try {
        final places = await _searchAround(category, target);
        if (places.isNotEmpty) {
          return _formatPlaces(
            places,
            query: query,
            language: language,
            reference: target,
            userLocation: userLocation,
          );
        }
      } catch (_) {
        // Try Photon text search if the nearby Overpass endpoint is unavailable.
      }
    }

    final places = await _searchPhoton(
      query: _cleanSearchQuery(query),
      location: userLocation,
    );
    if (places.isNotEmpty) {
      return _formatPlaces(
        places,
        query: query,
        language: language,
        reference: target ?? userLocation,
        userLocation: userLocation,
      );
    }

    return PlaceSearchResult(
      response: language.toLowerCase().startsWith('hi')
          ? 'इस खोज के लिए अभी कोई स्थान परिणाम नहीं मिला। कृपया जगह का नाम या खोज के शब्द बदलकर फिर कोशिश करें।'
          : 'I could not find places for that search right now. Try a nearby landmark or a different search phrase.',
    );
  }

  Future<LocationInfo?> _resolveTarget(
    String? anchor,
    LocationInfo? userLocation,
  ) async {
    if (anchor == null || anchor.isEmpty) return userLocation;

    final ujjainLandmarks = [
      'mahakal', 'mahakaleshwar', 'harsiddhi', 'kal bhairav',
      'ram ghat', 'mangalnath', 'chintaman',
    ];
    final isUjjainLandmark =
        ujjainLandmarks.any((landmark) => anchor.toLowerCase().contains(landmark));
    final query = userLocation == null && isUjjainLandmark
        ? '$anchor, Ujjain, India'
        : anchor;
    final response = await _dio.get<Map<String, dynamic>>(
      'https://photon.komoot.io/api/',
      queryParameters: {
        'q': query,
        'limit': 5,
        if (userLocation != null) 'lat': userLocation.latitude,
        if (userLocation != null) 'lon': userLocation.longitude,
        'lang': 'en',
      },
    );
    final features = response.data?['features'];
    if (features is! List || features.isEmpty) return userLocation;

    Map<String, dynamic>? best;
    var bestDistance = double.infinity;
    for (final raw in features) {
      if (raw is! Map<String, dynamic>) continue;
      final geometry = raw['geometry'];
      final coordinates = geometry is Map ? geometry['coordinates'] : null;
      if (coordinates is! List || coordinates.length < 2) continue;
      final properties = raw['properties'];
      final country = properties is Map ? properties['country']?.toString() : null;
      if (userLocation?.country != null &&
          country != null &&
          country.toLowerCase() != userLocation!.country!.toLowerCase()) {
        continue;
      }
      final candidate = LocationInfo(
        latitude: (coordinates[1] as num).toDouble(),
        longitude: (coordinates[0] as num).toDouble(),
        address: _photonAddress(properties),
        city: properties is Map
            ? (properties['city'] ?? properties['county'])?.toString()
            : null,
        country: country,
      );
      final distance = userLocation == null
          ? 0.0
          : _distanceMeters(
              userLocation.latitude,
              userLocation.longitude,
              candidate.latitude,
              candidate.longitude,
            );
      if (distance < bestDistance) {
        bestDistance = distance;
        best = {'location': candidate};
      }
    }
    final resolved = best?['location'];
    return resolved is LocationInfo ? resolved : userLocation;
  }

  Future<List<_FoundPlace>> _searchAround(
    _PlaceCategory category,
    LocationInfo center,
  ) async {
    final query = StringBuffer('[out:json][timeout:18];(');
    for (final filter in category.filters) {
      for (final kind in const ['node', 'way', 'relation']) {
        query.write(
          '$kind(around:5000,${center.latitude},${center.longitude})'
          '["${filter.key}"~"${filter.value}"];',
        );
      }
    }
    query.write(');out center tags;');

    final response = await _dio.post<Map<String, dynamic>>(
      'https://overpass-api.de/api/interpreter',
      data: {'data': query.toString()},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final elements = response.data?['elements'];
    if (elements is! List) return [];

    final places = <_FoundPlace>[];
    final seen = <String>{};
    for (final raw in elements) {
      if (raw is! Map<String, dynamic>) continue;
      final tags = raw['tags'];
      if (tags is! Map) continue;
      final name = (tags['name'] ?? tags['name:en'] ?? tags['name:hi'] ?? tags['brand'])?.toString().trim();
      if (name == null || name.isEmpty || !seen.add(name.toLowerCase())) continue;
      final centerData = raw['center'];
      final lat = raw['lat'] ?? (centerData is Map ? centerData['lat'] : null);
      final lon = raw['lon'] ?? (centerData is Map ? centerData['lon'] : null);
      if (lat is! num || lon is! num) continue;
      places.add(
        _FoundPlace(
          name: name,
          address: _addressFromTags(tags),
          latitude: lat.toDouble(),
          longitude: lon.toDouble(),
          category: _categoryLabel(tags),
        ),
      );
    }
    places.sort((a, b) => _distanceMeters(
      center.latitude, center.longitude, a.latitude, a.longitude,
    ).compareTo(_distanceMeters(
      center.latitude, center.longitude, b.latitude, b.longitude,
    )));
    return places.take(8).toList();
  }

  Future<List<_FoundPlace>> _searchPhoton({
    required String query,
    LocationInfo? location,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://photon.komoot.io/api/',
      queryParameters: {
        'q': query,
        'limit': 8,
        'lang': 'en',
        if (location != null) 'lat': location.latitude,
        if (location != null) 'lon': location.longitude,
      },
    );
    final features = response.data?['features'];
    if (features is! List) return [];
    final places = <_FoundPlace>[];
    for (final raw in features) {
      if (raw is! Map<String, dynamic>) continue;
      final geometry = raw['geometry'];
      final coordinates = geometry is Map ? geometry['coordinates'] : null;
      final properties = raw['properties'];
      if (coordinates is! List || coordinates.length < 2 || properties is! Map) {
        continue;
      }
      final name = properties['name']?.toString().trim();
      if (name == null || name.isEmpty) continue;
      places.add(
        _FoundPlace(
          name: name,
          address: _photonAddress(properties),
          latitude: (coordinates[1] as num).toDouble(),
          longitude: (coordinates[0] as num).toDouble(),
          category: properties['type']?.toString(),
        ),
      );
    }
    return places;
  }

  PlaceSearchResult _formatPlaces(
    List<_FoundPlace> places, {
    required String query,
    required String language,
    LocationInfo? reference,
    LocationInfo? userLocation,
  }) {
    final isHindi = language.toLowerCase().startsWith('hi');
    final heading = isHindi
        ? 'इस खोज के लिए मिले स्थान'
        : 'Places found for "$query"';
    final buffer = StringBuffer('$heading (OpenStreetMap data):\n\n');
    for (var i = 0; i < places.length; i++) {
      final place = places[i];
      final distanceFrom = reference ?? userLocation;
      final distance = distanceFrom == null
          ? null
          : _distanceMeters(
              distanceFrom.latitude,
              distanceFrom.longitude,
              place.latitude,
              place.longitude,
            );
      final mapUrl = Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': '${place.latitude},${place.longitude}',
      });
      buffer.write('${i + 1}. **${place.name}**');
      if (place.category != null && place.category!.isNotEmpty) {
        buffer.write(' · ${place.category}');
      }
      buffer.writeln();
      if (place.address != null && place.address!.isNotEmpty) {
        buffer.writeln('   ${place.address}');
      }
      if (distance != null) {
        buffer.writeln('   ${_formatDistance(distance)} ${isHindi ? 'दूर' : 'away'}');
      }
      buffer.writeln('   [${isHindi ? 'मानचित्र में खोलें' : 'Open in Maps'}]($mapUrl)\n');
    }
    buffer.write(isHindi
        ? 'स्थान [OpenStreetMap योगदानकर्ताओं](https://www.openstreetmap.org/copyright) के डेटा से मिले हैं; रेटिंग, खुलने का समय और उपलब्धता की पुष्टि सीधे करें।'
        : 'Data © [OpenStreetMap contributors](https://www.openstreetmap.org/copyright). Confirm ratings, opening hours, and availability directly.');
    final response = buffer.toString();
    return PlaceSearchResult(response: response, groundingContext: response);
  }

  _PlaceCategory? _categoryFor(String query) {
    final text = query.toLowerCase();
    bool has(List<String> words) => words.any(text.contains);
    if (has([
      'hotel', 'hotels', 'lodging', 'dharamshala', 'guest house', 'hostel', 'motel',
      'stay', 'accommodation', 'होटल', 'धर्मशाला', 'अतिथि गृह', 'लॉज', 'मोटल',
    ])) {
      return const _PlaceCategory('hotels', [
        _TagFilter('tourism', 'hotel|guest_house|hostel|motel'),
      ]);
    }
    if (has([
      'restaurant', 'cafe', 'coffee', 'food', 'eat', 'poha', 'khana',
      'रेस्टोरेंट', 'कैफे', 'खाना',
    ])) {
      return const _PlaceCategory('food', [
        _TagFilter('amenity', 'restaurant|cafe|fast_food|food_court'),
      ]);
    }
    if (has([
      'hospital', 'clinic', 'doctor', 'pharmacy', 'chemist', 'aspatal', 'dawai',
      'अस्पताल', 'क्लिनिक', 'डॉक्टर', 'फार्मेसी', 'दवा',
    ])) {
      return const _PlaceCategory('healthcare', [
        _TagFilter('amenity', 'hospital|clinic|doctors|pharmacy'),
      ]);
    }
    if (has(['temple', 'mandir', 'worship', 'मंदिर'])) {
      return const _PlaceCategory('temples', [
        _TagFilter('amenity', 'place_of_worship'),
      ]);
    }
    if (has(['atm'])) return const _PlaceCategory('ATMs', [_TagFilter('amenity', 'atm')]);
    if (has(['bank'])) return const _PlaceCategory('banks', [_TagFilter('amenity', 'bank')]);
    if (has(['petrol pump', 'gas station', 'fuel'])) {
      return const _PlaceCategory('fuel stations', [_TagFilter('amenity', 'fuel')]);
    }
    if (has(['parking'])) return const _PlaceCategory('parking', [_TagFilter('amenity', 'parking')]);
    if (has(['museum'])) return const _PlaceCategory('museums', [_TagFilter('tourism', 'museum')]);
    if (has(['shop', 'supermarket', 'grocery', 'bookstore'])) {
      return const _PlaceCategory('shops', [
        _TagFilter('shop', 'supermarket|convenience|books|general'),
      ]);
    }
    return null;
  }

  String? _locationAnchor(String query) {
    final text = query.toLowerCase().trim();
    final hindiMatch = RegExp(
      r'^(.+?)\s+(?:के पास|के नज़दीक|के नजदीक|के निकट|के आसपास|आसपास)\s+.+$',
    ).firstMatch(text);
    if (hindiMatch != null) return hindiMatch.group(1)?.trim();
    final match = RegExp(r'\b(?:near|around|close to|in|at)\s+(.+)$')
        .firstMatch(text);
    if (match == null) return null;
    var anchor = match.group(1)!.trim();
    anchor = anchor.replaceFirst(
      RegExp(r'^(me|here|my (current )?location|near me)\b\s*'),
      '',
    );
    if (anchor.isEmpty) return null;
    anchor = anchor.replaceFirst(RegExp(r'\b(please|for me|right now)\b.*$'), '').trim();
    return anchor.isEmpty ? null : anchor;
  }

  String _cleanSearchQuery(String query) => query
      .replaceAll(RegExp(r'\b(best|near me|nearby|nearest|closest|find|search|show me|please)\b', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  String? _photonAddress(dynamic properties) {
    if (properties is! Map) return null;
    return [
      properties['street'],
      properties['housenumber'],
      properties['district'],
      properties['city'] ?? properties['county'],
      properties['state'],
    ].whereType<String>().where((part) => part.trim().isNotEmpty).toSet().join(', ');
  }

  String? _addressFromTags(Map tags) {
    return [
      tags['addr:housenumber'], tags['addr:street'], tags['addr:suburb'],
      tags['addr:city'],
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(', ');
  }

  String? _categoryLabel(Map tags) =>
      (tags['tourism'] ?? tags['amenity'] ?? tags['shop'])?.toString().replaceAll('_', ' ');

  double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const radius = 6371000.0;
    final dLat = _radians(lat2 - lat1);
    final dLon = _radians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_radians(lat1)) * math.cos(_radians(lat2)) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    return radius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _radians(double degrees) => degrees * math.pi / 180;

  String _formatDistance(double meters) => meters < 1000
      ? '${meters.round()} m'
      : '${(meters / 1000).toStringAsFixed(1)} km';
}

class PlaceSearchResult {
  final String response;
  final String? groundingContext;

  const PlaceSearchResult({required this.response, this.groundingContext});

  bool get hasPlaces => groundingContext != null;
}

class _PlaceCategory {
  final String label;
  final List<_TagFilter> filters;
  const _PlaceCategory(this.label, this.filters);
}

class _TagFilter {
  final String key;
  final String value;
  const _TagFilter(this.key, this.value);
}

class _FoundPlace {
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final String? category;
  const _FoundPlace({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.category,
  });
}
