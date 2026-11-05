// OpenStreetMap Live Map Tab
// Real interactive map with zoom, pan, markers, and routing

import 'dart:ui' as ui;
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

  String _selectedCategory = 'all';
  String _searchQuery = '';
  MapMarkerData? _selectedMarker;
  LatLng? _userLocation;
  bool _isLoadingLocation = false;
  List<LatLng>? _routePoints;
  double? _routeDistance;

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
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    _getUserLocation();
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
        // If user is near Ujjain, center on user, otherwise center on Mahakaleshwar
        if (_mapService.isWithinUjjainBounds(_userLocation!)) {
          _mapController.move(_userLocation!, 14.0);
        }
      }
    } catch (e) {
      print('Error getting location: $e');
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
      _routePoints = null;
      _routeDistance = null;
    });
    _mapController.move(marker.position, 16.0);
  }

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

      // Fit map to show both user location and selected marker
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
        print('Error launching maps: $e');
      }
    } else {
      // If no user location, just open the destination
      final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${destination.latitude},${destination.longitude}');
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        print('Error launching maps: $e');
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

          // OpenStreetMap
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
                      ],
                    ),

                    // Attribution Layer (required for OpenStreetMap)
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
              border: Border.all(color: AppColors.divider),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search temples, ghats, facilities...',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                prefixIcon: Icon(Icons.search, size: 20, color: AppColors.primary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
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
                    _routePoints = null; // Clear route on category change
                  }),
                );
              },
            ),
          ),
        ],
      ),
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
          border: Border.all(color: AppColors.divider),
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
            const Icon(Icons.location_on, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${_filteredMarkers.length} locations • Tap marker for details',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
                        ) +
                            ' away',
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

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
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
