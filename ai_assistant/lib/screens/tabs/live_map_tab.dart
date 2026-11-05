import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../models/simhastha_place.dart';

class LiveMapTab extends StatefulWidget {
  final Function(String query)? onAskAi;

  const LiveMapTab({super.key, this.onAskAi});

  @override
  State<LiveMapTab> createState() => _LiveMapTabState();
}

class _LiveMapTabState extends State<LiveMapTab> {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  SimhasthaPlace? _selectedPlace;
  bool _isMapView = true;

  final Map<String, String> _categories = {
    'all': 'All Places',
    'temple': 'Temples 🕉️',
    'ghat': 'Ghats 🏺',
    'akhara': 'Akharas 🚩',
    'hospital': 'Hospitals 🏥',
    'police': 'Police 👮',
    'toilet': 'Toilets 🚻',
    'parking': 'Parking 🅿️',
    'food': 'Food & Annakshetra 🍲',
    'transport': 'Transport 🚆',
    'hotel': 'Hotels 🏨',
    'dharamshala': 'Dharamshalas 🏢',
    'tent': 'Tent Cities ⛺',
  };

  List<SimhasthaPlace> get _filteredPlaces {
    return SimhasthaPlacesData.allPlaces.where((place) {
      final matchesCategory = _selectedCategory == 'all' || place.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          place.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          place.hindiName.contains(_searchQuery) ||
          place.area.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          place.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openInGoogleMaps(double lat, double lon, String label) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top Search & Mode Switcher Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            color: AppColors.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: const InputDecoration(
                            hintText: 'Search temples, ghats, hospitals, parking...',
                            hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            prefixIcon: Icon(Icons.search, size: 20, color: AppColors.primary),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isMapView ? Icons.format_list_bulleted_rounded : Icons.map_rounded,
                          color: AppColors.primary,
                        ),
                        tooltip: _isMapView ? 'Show List View' : 'Show Map Canvas',
                        onPressed: () => setState(() => _isMapView = !_isMapView),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Filter Chips
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
                        onSelected: (_) => setState(() => _selectedCategory = key),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main Interactive Area
          Expanded(
            child: _isMapView ? _buildInteractiveMapCanvas() : _buildPlacesListView(),
          ),

          // Bottom Detail Drawer when a pin is selected
          if (_selectedPlace != null && _isMapView) _buildSelectedPlaceCard(_selectedPlace!),
        ],
      ),
    );
  }

  Widget _buildInteractiveMapCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Coordinate bounds for Ujjain pilgrimage hub
        const minLat = 23.140;
        const maxLat = 23.225;
        const minLon = 75.725;
        const maxLon = 75.815;

        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          children: [
            // Styled Geographic Canvas (Simulated Vector Map)
            CustomPaint(
              size: Size(width, height),
              painter: _UjjainMapVectorPainter(),
            ),

            // Interactive Pin Markers
            ..._filteredPlaces.map((place) {
              // Normalize lat/lon to canvas coordinates
              final normX = (place.lon - minLon) / (maxLon - minLon);
              // Lat is inverted on screen coordinates (higher lat = higher up = lower Y)
              final normY = 1.0 - ((place.lat - minLat) / (maxLat - minLat));

              final px = (normX * width).clamp(24.0, width - 40.0);
              final py = (normY * height).clamp(24.0, height - 50.0);

              final isSelected = _selectedPlace?.id == place.id;

              return Positioned(
                left: px - (isSelected ? 22 : 16),
                top: py - (isSelected ? 42 : 32),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPlace = place),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSelected ? 6 : 4),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(place.category),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : AppColors.templeGold,
                              width: isSelected ? 2.5 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: isSelected ? 8 : 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            place.icon,
                            style: TextStyle(fontSize: isSelected ? 20 : 15),
                          ),
                        ),
                        CustomPaint(
                          size: const Size(8, 6),
                          painter: _PinArrowPainter(color: _getCategoryColor(place.category)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Floating Navigation & Legend Overlay
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
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
                    const Icon(Icons.touch_app, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${_filteredPlaces.length} points • Tap pin for details',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectedPlaceCard(SimhasthaPlace place) {
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
                  color: _getCategoryColor(place.category).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: _getCategoryColor(place.category)),
                ),
                child: Center(
                  child: Text(place.icon, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      place.hindiName,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      place.area,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _selectedPlace = null),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            place.description,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (place.timing != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.secondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    place.timing!,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openInGoogleMaps(place.lat, place.lon, place.name),
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text('Open GPS Navigation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  widget.onAskAi?.call('Tell me complete information and tips about ${place.name} in Ujjain');
                },
                icon: const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.primary),
                label: const Text('Ask AI', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesListView() {
    if (_filteredPlaces.isEmpty) {
      return const Center(
        child: Text('No places found matching criteria', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _filteredPlaces.length,
      itemBuilder: (context, index) {
        final place = _filteredPlaces[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 1.5,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(place.category).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getCategoryColor(place.category)),
                      ),
                      child: Center(child: Text(place.icon, style: const TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            place.hindiName,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 13, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  place.area,
                                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        place.category.toUpperCase(),
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  place.description,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                ),
                if (place.timing != null) ...[
                  const SizedBox(height: 6),
                  Text('⏰ Hours: ${place.timing}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                ],
                if (place.gates != null) ...[
                  const SizedBox(height: 2),
                  Text('🚪 Gates/Entry: ${place.gates}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                ],
                if (place.pricing != null) ...[
                  const SizedBox(height: 2),
                  Text('💰 Cost: ${place.pricing}', style: const TextStyle(fontSize: 11.5, color: AppColors.success, fontWeight: FontWeight.w600)),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        widget.onAskAi?.call('Give me tips and details on ${place.name} in Ujjain');
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 15),
                      label: const Text('Ask Margdarshak', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      onPressed: () => _openInGoogleMaps(place.lat, place.lon, place.name),
                      icon: const Icon(Icons.navigation, size: 15),
                      label: const Text('Get Directions', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'temple':
        return const Color(0xFFD35400); // Saffron
      case 'ghat':
        return const Color(0xFF2980B9); // River Blue
      case 'akhara':
        return const Color(0xFFC0392B); // Sacred Red
      case 'hospital':
        return const Color(0xFF27AE60); // Medical Green
      case 'police':
        return const Color(0xFF2C3E50); // Navy Blue
      case 'toilet':
        return const Color(0xFF16A085); // Teal
      case 'parking':
        return const Color(0xFF8E44AD); // Purple
      case 'food':
        return const Color(0xFFE67E22); // Orange
      case 'transport':
        return const Color(0xFF34495E); // Slate
      case 'hotel':
      case 'dharamshala':
      case 'tent':
        return const Color(0xFFB7950B); // Gold/Ochre
      default:
        return AppColors.primary;
    }
  }
}

// Custom Painter to draw stylized Ujjain map vector terrain (Shipra river & arterial roads)
class _UjjainMapVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Terrain base background
    final basePaint = Paint()..color = const Color(0xFFF9F6F0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    // 2. Shipra River meandering through Ujjain
    final riverPaint = Paint()
      ..color = const Color(0xFF85C1E9).withValues(alpha: 0.65)
      ..strokeWidth = 22
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPath = Path();
    riverPath.moveTo(size.width * 0.72, size.height * 0.98); // South (Triveni)
    riverPath.cubicTo(
      size.width * 0.62, size.height * 0.70,
      size.width * 0.55, size.height * 0.55,
      size.width * 0.48, size.height * 0.42, // Ramghat area
    );
    riverPath.cubicTo(
      size.width * 0.42, size.height * 0.30,
      size.width * 0.52, size.height * 0.20,
      size.width * 0.60, size.height * 0.02, // North (Mangalnath/Kal Bhairav)
    );
    canvas.drawPath(riverPath, riverPaint);

    // River accent wave line
    final riverCenterPaint = Paint()
      ..color = const Color(0xFF3498DB).withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawPath(riverPath, riverCenterPaint);

    // River label
    const textSpan = TextSpan(
      text: ' पवित्र शिप्रा नदी (Holy Shipra River) ~ ~ ~ ',
      style: TextStyle(color: Color(0xFF2980B9), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    canvas.save();
    canvas.translate(size.width * 0.35, size.height * 0.45);
    canvas.rotate(-math.pi / 3.2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();

    // 3. Arterial Ring Roads & Pilgrimage Corridors
    final roadPaint = Paint()
      ..color = const Color(0xFFE0D7C8)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    // Indore Highway -> Railway -> Mahakal
    final roadPath = Path();
    roadPath.moveTo(size.width * 0.75, size.height * 0.98);
    roadPath.lineTo(size.width * 0.68, size.height * 0.58); // Station
    roadPath.lineTo(size.width * 0.40, size.height * 0.52); // Mahakal Lok
    canvas.drawPath(roadPath, roadPaint);

    // Agar Road & Ring Road
    final ringRoadPath = Path();
    ringRoadPath.moveTo(size.width * 0.15, size.height * 0.80);
    ringRoadPath.lineTo(size.width * 0.85, size.height * 0.80);
    canvas.drawPath(ringRoadPath, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PinArrowPainter extends CustomPainter {
  final Color color;
  _PinArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

