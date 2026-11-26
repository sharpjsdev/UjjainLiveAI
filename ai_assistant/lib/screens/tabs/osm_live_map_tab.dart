// OpenStreetMap Live Map Tab
// Real interactive map with zoom, pan, markers, search, geocoding indicator, and routing

import 'dart:async';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../models/simhastha_place.dart';
import '../../models/map_marker.dart';
import '../../services/map_service.dart';
import '../../services/location_service.dart';

class OSMLiveMapTab extends StatefulWidget {
  final Function(String query)? onAskAi;

  const OSMLiveMapTab({super.key, this.onAskAi});

  @override
  State<OSMLiveMapTab> createState() => _OSMLiveMapTabState();
}

class _OSMLiveMapTabState extends State<OSMLiveMapTab> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final MapService _mapService = MapService();
  final LocationService _locationService = LocationService();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 8),
      headers: {'User-Agent': 'SimhasthaUjjainLive/1.0'},
    ),
  );

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _debounceTimer;

  String _selectedCategory = 'all';
  String _searchQuery = '';
  MapMarkerData? _selectedMarker;
  LatLng? _userLocation;
  bool _isLoadingLocation = false;
  List<LatLng>? _routePoints;
  double? _routeDistance;

  // Search & Indication State
  LatLng? _indicatedPosition;
  String? _indicatedLabel;
  List<MapMarkerData> _searchResults = [];
  bool _showSuggestions = false;
  bool _isSearchingOnline = false;

  final Map<String, String> _categories = {
    'all': 'All Places',
    'temple': 'Temples 🕉️',
    'ghat': 'Ghats 🏺',
    'akhara': 'Akharas 🚩',
    'hospital': 'Hospitals 🏥',
    'police': 'Police 👮',
    'toilet': 'Toilets 🚻',
    'parking': 'Parking 🅿️',
    'food': 'Food 🍲',
    'transport': 'Transport 🚆',
    'hotel': 'Hotels 🏨',
    'dharamshala': 'Dharamshalas 🏢',
    'tent': 'Tents ⛺',
  };

  List<MapMarkerData> _allMarkers = [];

  List<MapMarkerData> get _filteredMarkers {
    return _allMarkers.where((marker) {
      final matchesCategory = _selectedCategory == 'all' || marker.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          marker.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          marker.hindiName.contains(_searchQuery) ||
          marker.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final isIndicated = _indicatedPosition != null &&
          marker.position.latitude == _indicatedPosition!.latitude &&
          marker.position.longitude == _indicatedPosition!.longitude;
      return (matchesCategory && matchesSearch) || isIndicated;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        // Small delay to allow tap on suggestion
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted && !_searchFocusNode.hasFocus) {
            setState(() => _showSuggestions = false);
          }
        });
      } else if (_searchResults.isNotEmpty) {
        setState(() => _showSuggestions = true);
      }
    });

    _loadMarkers();
    _getUserLocation();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _pulseController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _loadMarkers() {
    // Convert SimhasthaPlace data to MapMarkerData
    _allMarkers = SimhasthaPlacesData.allPlaces
        .map((place) => MapMarkerData.fromSimhasthaPlace(place))
        .toList();
  }

  Future<void> _getUserLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final locationInfo = await _locationService.getCurrentLocation();
      if (locationInfo != null && mounted) {
        setState(() {
          _userLocation = LatLng(locationInfo.latitude, locationInfo.longitude);
        });
        if (_mapService.isWithinUjjainBounds(_userLocation!)) {
          _mapController.move(_userLocation!, 14.0);
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _centerOnUserLocation() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 15.0);
    } else {
      _getUserLocation();
    }
  }

  void _selectMarker(MapMarkerData marker) {
    setState(() {
      _selectedMarker = marker;
      _indicatedPosition = marker.position;
      _indicatedLabel = marker.name;
      _routePoints = null;
      _routeDistance = null;
      _showSuggestions = false;
    });
    _mapController.move(marker.position, 16.0);
  }

  // --- Search Logic & Geocoding ---

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    final query = val.trim();
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSuggestions = false;
        _isSearchingOnline = false;
      });
      return;
    }

    // 1. Instant local search across curated Ujjain landmarks
    final q = query.toLowerCase();
    final localMatches = _allMarkers.where((marker) {
      return marker.name.toLowerCase().contains(q) ||
          marker.hindiName.contains(query) ||
          marker.description.toLowerCase().contains(q) ||
          marker.category.toLowerCase().contains(q);
    }).toList();

    // Sort: exact / prefix matches first
    localMatches.sort((a, b) {
      final aExact = a.name.toLowerCase().startsWith(q) || a.hindiName.startsWith(query);
      final bExact = b.name.toLowerCase().startsWith(q) || b.hindiName.startsWith(query);
      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;
      return 0;
    });

    setState(() {
      _searchResults = List.from(localMatches);
      _showSuggestions = true;
    });

    // 2. Debounced online search via Photon OSM Geocoding
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _performOnlineSearch(query);
    });
  }

  Future<void> _performOnlineSearch(String query) async {
    if (!mounted || query.trim().length < 2) return;
    setState(() => _isSearchingOnline = true);

    try {
      final searchTerm = query.toLowerCase().contains('ujjain') ? query : '$query, Ujjain';
      final response = await _dio.get(
        'https://photon.komoot.io/api/',
        queryParameters: {
          'q': searchTerm,
          'lat': 23.1827,
          'lon': 75.7682,
          'limit': 6,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final features = response.data['features'];
        if (features is List && features.isNotEmpty) {
          final List<MapMarkerData> onlineResults = [];
          for (final item in features) {
            final geometry = item['geometry'];
            final properties = item['properties'];
            if (geometry == null || properties == null) continue;

            final coords = geometry['coordinates'];
            if (coords is! List || coords.length < 2) continue;
            final lon = (coords[0] as num).toDouble();
            final lat = (coords[1] as num).toDouble();

            final name = properties['name']?.toString() ??
                properties['street']?.toString() ??
                properties['district']?.toString();
            if (name == null || name.trim().isEmpty) continue;

            // Avoid duplicate coordinates
            final isDuplicate = _searchResults.any((m) =>
                (m.position.latitude - lat).abs() < 0.0005 &&
                (m.position.longitude - lon).abs() < 0.0005);
            if (isDuplicate) continue;

            final osmValue = properties['osm_value']?.toString() ??
                properties['osm_key']?.toString() ??
                'place';
            final category = _mapOsmValueToCategory(osmValue);
            final street = properties['street']?.toString();
            final city = properties['city']?.toString() ?? 'Ujjain';
            final address = [street, city].where((s) => s != null && s.isNotEmpty).join(', ');

            onlineResults.add(
              MapMarkerData(
                id: 'osm_${properties['osm_id'] ?? DateTime.now().millisecondsSinceEpoch}',
                name: name,
                hindiName: properties['name:hi']?.toString() ?? name,
                position: LatLng(lat, lon),
                category: category,
                icon: _getCategoryIcon(category),
                description: address.isNotEmpty ? address : 'Location in Ujjain region',
              ),
            );
          }

          if (mounted && onlineResults.isNotEmpty) {
            setState(() {
              for (final r in onlineResults) {
                if (!_searchResults.any((existing) => existing.name.toLowerCase() == r.name.toLowerCase())) {
                  _searchResults.add(r);
                }
              }
            });
          }
        }
      }
    } catch (_) {
      // Offline / network failure: local results continue to be served cleanly
    } finally {
      if (mounted) {
        setState(() => _isSearchingOnline = false);
      }
    }
  }

  void _onSearchSubmitted(String val) {
    final query = val.trim();
    if (query.isEmpty) return;

    if (_searchResults.isNotEmpty) {
      _selectSearchedLocation(_searchResults.first);
    } else {
      _performImmediateSearchAndSelect(query);
    }
  }

  Future<void> _performImmediateSearchAndSelect(String query) async {
    // 1. Check local markers first
    final localMatch = _allMarkers.where((m) =>
        m.name.toLowerCase().contains(query.toLowerCase()) ||
        m.hindiName.contains(query) ||
        m.description.toLowerCase().contains(query.toLowerCase())).firstOrNull;

    if (localMatch != null) {
      _selectSearchedLocation(localMatch);
      return;
    }

    // 2. Query online
    setState(() => _isSearchingOnline = true);
    try {
      final searchTerm = query.toLowerCase().contains('ujjain') ? query : '$query, Ujjain';
      final response = await _dio.get(
        'https://photon.komoot.io/api/',
        queryParameters: {
          'q': searchTerm,
          'lat': 23.1827,
          'lon': 75.7682,
          'limit': 1,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final features = response.data['features'];
        if (features is List && features.isNotEmpty) {
          final item = features.first;
          final coords = item['geometry']?['coordinates'];
          final props = item['properties'] ?? {};
          if (coords is List && coords.length >= 2) {
            final lat = (coords[1] as num).toDouble();
            final lon = (coords[0] as num).toDouble();
            final name = props['name']?.toString() ?? query;
            final marker = MapMarkerData(
              id: 'search_${DateTime.now().millisecondsSinceEpoch}',
              name: name,
              hindiName: props['name:hi']?.toString() ?? name,
              position: LatLng(lat, lon),
              category: 'temple',
              icon: '📍',
              description: props['street']?.toString() ?? 'Ujjain',
            );
            _selectSearchedLocation(marker);
            return;
          }
        }
      }
    } catch (_) {}
    finally {
      if (mounted) setState(() => _isSearchingOnline = false);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No location found for "$query" in Ujjain'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _selectSearchedLocation(MapMarkerData marker) {
    _searchFocusNode.unfocus();
    setState(() {
      _showSuggestions = false;
      _searchController.text = marker.name;
      _indicatedPosition = marker.position;
      _indicatedLabel = marker.name;
      _selectedMarker = marker;
      _routePoints = null;
      _routeDistance = null;

      // Add to markers list if not already present
      if (!_allMarkers.any((m) => m.id == marker.id)) {
        _allMarkers.add(marker);
      }
    });

    _mapController.move(marker.position, 16.5);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchResults = [];
      _showSuggestions = false;
      _indicatedPosition = null;
      _indicatedLabel = null;
      _selectedMarker = null;
      _routePoints = null;
      _routeDistance = null;
    });
    _searchFocusNode.unfocus();
  }

  void _clearIndicator() {
    setState(() {
      _indicatedPosition = null;
      _indicatedLabel = null;
      _selectedMarker = null;
      _routePoints = null;
      _routeDistance = null;
    });
  }

  String _mapOsmValueToCategory(String osmValue) {
    final val = osmValue.toLowerCase();
    if (val.contains('place_of_worship') || val.contains('temple') || val.contains('hindu')) return 'temple';
    if (val.contains('hospital') || val.contains('clinic') || val.contains('pharmacy')) return 'hospital';
    if (val.contains('hotel') || val.contains('guest_house') || val.contains('hostel') || val.contains('lodging')) return 'hotel';
    if (val.contains('restaurant') || val.contains('cafe') || val.contains('fast_food') || val.contains('food')) return 'food';
    if (val.contains('police')) return 'police';
    if (val.contains('toilet') || val.contains('restroom')) return 'toilet';
    if (val.contains('parking')) return 'parking';
    if (val.contains('station') || val.contains('bus') || val.contains('railway')) return 'transport';
    return 'ghat';
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'temple': return '🕉️';
      case 'ghat': return '🏺';
      case 'akhara': return '🚩';
      case 'hospital': return '🏥';
      case 'police': return '👮';
      case 'toilet': return '🚻';
      case 'parking': return '🅿️';
      case 'food': return '🍲';
      case 'transport': return '🚆';
      case 'hotel': return '🏨';
      case 'dharamshala': return '🏢';
      case 'tent': return '⛺';
      default: return '📍';
    }
  }

  // --- Route & External Apps ---

  void _showRoute() {
    if (_userLocation != null && _selectedMarker != null) {
      final route = _mapService.createStraightRoute(
        _userLocation!,
        _selectedMarker!.position,
        points: 50,
      );
      final distance = _mapService.calculateDistance(
        _userLocation!,
        _selectedMarker!.position,
      );

      setState(() {
        _routePoints = route;
        _routeDistance = distance;
      });

      final bounds = LatLngBounds.fromPoints([_userLocation!, _selectedMarker!.position]);
      _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
    }
  }

  void _openInExternalApp(LatLng destination, String label) async {
    if (_userLocation != null) {
      final url = _mapService.generateGoogleMapsUrl(_userLocation!, destination);
      final uri = Uri.parse(url);
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('Error launching maps: $e');
      }
    } else {
      final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${destination.latitude},${destination.longitude}');
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('Error launching maps: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search and Filter Bar
          _buildSearchBar(),

          // OpenStreetMap with overlays
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: UjjainLocations.ujjainCenter,
                    initialZoom: 13.5,
                    minZoom: 11.0,
                    maxZoom: 18.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                    onTap: (tapPosition, point) {
                      if (_showSuggestions) {
                        setState(() => _showSuggestions = false);
                      }
                      _searchFocusNode.unfocus();
                    },
                  ),
                  children: [
                    // OpenStreetMap Tile Layer
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.ujjain.live',
                      tileBuilder: (context, widget, tile) {
                        return ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.orange.withValues(alpha: 0.05),
                            BlendMode.srcOver,
                          ),
                          child: widget,
                        );
                      },
                    ),

                    // Route polyline (if exists)
                    if (_routePoints != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints!,
                            strokeWidth: 4.0,
                            color: AppColors.primary,
                            borderStrokeWidth: 2.0,
                            borderColor: Colors.white,
                          ),
                        ],
                      ),

                    // Radar Pulse Circles for Indicated Position
                    if (_indicatedPosition != null)
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, _) {
                          return CircleLayer(
                            circles: [
                              // Outer expanding ripple
                              CircleMarker(
                                point: _indicatedPosition!,
                                radius: 25 + (_pulseAnimation.value * 35),
                                useRadiusInMeter: false,
                                color: AppColors.primary.withValues(alpha: (1.0 - _pulseAnimation.value) * 0.35),
                                borderColor: AppColors.primary.withValues(alpha: (1.0 - _pulseAnimation.value) * 0.85),
                                borderStrokeWidth: 2.0,
                              ),
                              // Inner pulse halo
                              CircleMarker(
                                point: _indicatedPosition!,
                                radius: 12 + (_pulseAnimation.value * 16),
                                useRadiusInMeter: false,
                                color: Colors.amber.withValues(alpha: (1.0 - _pulseAnimation.value) * 0.45),
                                borderColor: Colors.amber,
                                borderStrokeWidth: 1.5,
                              ),
                              // Center glowing dot
                              CircleMarker(
                                point: _indicatedPosition!,
                                radius: 8,
                                useRadiusInMeter: false,
                                color: AppColors.primary,
                                borderColor: Colors.white,
                                borderStrokeWidth: 2,
                              ),
                            ],
                          );
                        },
                      ),

                    // Marker Layer
                    MarkerLayer(
                      markers: [
                        // User location marker
                        if (_userLocation != null)
                          Marker(
                            point: _userLocation!,
                            width: 50,
                            height: 50,
                            child: GestureDetector(
                              onTap: () => _mapController.move(_userLocation!, 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.my_location, color: Colors.white, size: 24),
                              ),
                            ),
                          ),

                        // Place markers
                        ..._filteredMarkers.map((marker) {
                          final isSelected = _selectedMarker?.id == marker.id;
                          return Marker(
                            point: marker.position,
                            width: isSelected ? 50 : 40,
                            height: isSelected ? 70 : 60,
                            child: GestureDetector(
                              onTap: () => _selectMarker(marker),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: EdgeInsets.all(isSelected ? 8 : 6),
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(marker.category),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? Colors.white : AppColors.templeGold,
                                        width: isSelected ? 3 : 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.4),
                                          blurRadius: isSelected ? 10 : 6,
                                          spreadRadius: isSelected ? 2 : 1,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      marker.icon,
                                      style: TextStyle(fontSize: isSelected ? 24 : 18),
                                    ),
                                  ),
                                  // Pin pointer
                                  CustomPaint(
                                    size: const Size(10, 10),
                                    painter: _PinArrowPainter(
                                      color: _getCategoryColor(marker.category),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        // Indicated Location Badge Pin (Hovering over searched position)
                        if (_indicatedPosition != null)
                          Marker(
                            point: _indicatedPosition!,
                            width: 170,
                            height: 95,
                            alignment: Alignment.bottomCenter,
                            child: _buildIndicatedBadgeWidget(),
                          ),
                      ],
                    ),

                    // Attribution Layer
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          '© OpenStreetMap contributors',
                          onTap: () => launchUrl(
                            Uri.parse('https://www.openstreetmap.org/copyright'),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Floating controls
                _buildFloatingControls(),

                // Info banner
                _buildInfoBanner(),

                // Suggestions dropdown overlay (floating on top of map)
                if (_showSuggestions && (_searchResults.isNotEmpty || _isSearchingOnline))
                  _buildSuggestionsOverlay(),
              ],
            ),
          ),

          // Selected marker detail card
          if (_selectedMarker != null) _buildSelectedMarkerCard(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      color: AppColors.surface,
      child: Column(
        children: [
          // Search field
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _searchFocusNode.hasFocus ? AppColors.primary : AppColors.divider,
                width: _searchFocusNode.hasFocus ? 1.5 : 1.0,
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchSubmitted,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search temples, ghats, places, streets...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primary),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isSearchingOnline)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                        onPressed: _clearSearch,
                        tooltip: 'Clear search',
                      ),
                  ],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Category filters
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final key = _categories.keys.elementAt(idx);
                final isSelected = _selectedCategory == key;
                return ChoiceChip(
                  label: Text(
                    _categories[key]!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.cardBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                  onSelected: (_) => setState(() {
                    _selectedCategory = key;
                    _routePoints = null;
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsOverlay() {
    return Positioned(
      top: 8,
      left: 14,
      right: 14,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surface,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 280),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.templeGold.withValues(alpha: 0.5), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  color: AppColors.primary.withValues(alpha: 0.08),
                  child: Row(
                    children: [
                      const Icon(Icons.explore, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Places in Ujjain (${_searchResults.length})',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      if (_isSearchingOnline)
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Searching...',
                              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Suggestions list
                Flexible(
                  child: _searchResults.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _isSearchingOnline
                                ? 'Searching for locations in Ujjain...'
                                : 'No locations found. Press enter to search online.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                          itemBuilder: (context, index) {
                            final place = _searchResults[index];
                            final distance = _userLocation != null
                                ? _mapService.formatDistance(
                                    _mapService.calculateDistance(_userLocation!, place.position),
                                  )
                                : null;

                            return InkWell(
                              onTap: () => _selectSearchedLocation(place),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(place.category).withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _getCategoryColor(place.category).withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(place.icon, style: const TextStyle(fontSize: 18)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            place.name,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (place.hindiName.isNotEmpty && place.hindiName != place.name)
                                            Text(
                                              place.hindiName,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.primary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (distance != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.divider),
                                        ),
                                        child: Text(
                                          distance,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textSecondary),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatedBadgeWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7A00), Color(0xFFFF5200)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _indicatedLabel ?? 'Searched Place',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 2),
        CustomPaint(
          size: const Size(12, 8),
          painter: _PinArrowPainter(color: const Color(0xFFFF5200)),
        ),
        const SizedBox(height: 38), // Elevation offset to hover above the place marker
      ],
    );
  }

  Widget _buildFloatingControls() {
    return Positioned(
      right: 12,
      bottom: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom in
          FloatingActionButton.small(
            heroTag: 'zoom_in',
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom + 1,
              );
            },
            backgroundColor: AppColors.surface,
            child: const Icon(Icons.add, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          // Zoom out
          FloatingActionButton.small(
            heroTag: 'zoom_out',
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom - 1,
              );
            },
            backgroundColor: AppColors.surface,
            child: const Icon(Icons.remove, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          // My location
          FloatingActionButton.small(
            heroTag: 'my_location',
            onPressed: _centerOnUserLocation,
            backgroundColor: AppColors.primary,
            child: _isLoadingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.my_location, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Positioned(
      top: 12,
      left: 12,
      right: 70,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _indicatedPosition != null ? AppColors.primary : AppColors.divider,
            width: _indicatedPosition != null ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _indicatedPosition != null ? Icons.my_location : Icons.location_on,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _indicatedPosition != null
                    ? '📍 Showing: ${_indicatedLabel ?? "Selected Place"}'
                    : '${_filteredMarkers.length} locations • Search or tap any place',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_indicatedPosition != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _clearIndicator,
                child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedMarkerCard() {
    final marker = _selectedMarker!;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.templeGold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getCategoryColor(marker.category).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: _getCategoryColor(marker.category)),
                ),
                child: Center(
                  child: Text(marker.icon, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      marker.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (marker.hindiName.isNotEmpty && marker.hindiName != marker.name)
                      Text(
                        marker.hindiName,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (_userLocation != null)
                      Text(
                        _mapService.formatDistance(
                          _mapService.calculateDistance(_userLocation!, marker.position),
                        ) + ' away',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() {
                  _selectedMarker = null;
                  _indicatedPosition = null;
                  _indicatedLabel = null;
                  _routePoints = null;
                  _routeDistance = null;
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            marker.description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (marker.timing != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.secondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    marker.timing!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (_routeDistance != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.route, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distance: ${_mapService.formatDistance(_routeDistance!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '${_mapService.estimateWalkingTime(_routeDistance!)} • ${_mapService.estimateDrivingTime(_routeDistance!)}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              if (_userLocation != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showRoute,
                    icon: const Icon(Icons.route, size: 16),
                    label: Text(
                      _routePoints == null ? 'Show Route' : 'Hide Route',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openInExternalApp(marker.position, marker.name),
                  icon: const Icon(Icons.navigation, size: 16),
                  label: const Text(
                    'Navigate',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'temple':
        return const Color(0xFFD35400);
      case 'ghat':
        return const Color(0xFF2980B9);
      case 'akhara':
        return const Color(0xFFC0392B);
      case 'hospital':
        return const Color(0xFF27AE60);
      case 'police':
        return const Color(0xFF2C3E50);
      case 'toilet':
        return const Color(0xFF16A085);
      case 'parking':
        return const Color(0xFF8E44AD);
      case 'food':
        return const Color(0xFFE67E22);
      case 'transport':
        return const Color(0xFF34495E);
      case 'hotel':
      case 'dharamshala':
      case 'tent':
        return const Color(0xFFB7950B);
      default:
        return AppColors.primary;
    }
  }
}

// Pin arrow painter
class _PinArrowPainter extends CustomPainter {
  final Color color;
  _PinArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
