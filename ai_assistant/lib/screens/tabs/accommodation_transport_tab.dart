import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../models/simhastha_place.dart';
import '../../services/simhastha_backend_service.dart';

class AccommodationTransportTab extends StatefulWidget {
  final Function(String query)? onAskAi;

  const AccommodationTransportTab({super.key, this.onAskAi});

  @override
  State<AccommodationTransportTab> createState() => AccommodationTransportTabState();
}

class AccommodationTransportTabState extends State<AccommodationTransportTab> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  String _selectedSubcategory = 'all';
  String _selectedTransportFilter = 'all';
  List<SimhasthaPlace> _places = SimhasthaPlacesData.allPlaces;
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true; // Keep tab alive when switching

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPlacesFromBackend();
  }

  // Public method to refresh data
  void refreshData() {
    print('[AccommodationTransportTab] ✅ refreshData() called! Starting backend fetch...');
    _loadPlacesFromBackend();
  }

  Future<void> _loadPlacesFromBackend() async {
    print('[AccommodationTransportTab] 🔄 _loadPlacesFromBackend() executing...');
    setState(() => _isLoading = true);
    final data = await SimhasthaBackendService().fetchStaysAndTransit();
    if (mounted) {
      setState(() {
        _places = data;
        _isLoading = false;
      });
      print('[AccommodationTransportTab] ✅ UI updated with ${_places.length} places');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openInGoogleMaps(double lat, double lon) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            tabs: const [
              Tab(icon: Icon(Icons.hotel_rounded, size: 18), text: 'Stays & Dharamshalas'),
              Tab(icon: Icon(Icons.directions_transit_rounded, size: 18), text: 'Transport & Parking'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAccommodationView(),
          _buildTransportView(),
        ],
      ),
    );
  }

  Widget _buildAccommodationView() {
    final places = _places.where((p) {
      final isAccom = p.category == 'hotel' || p.category == 'dharamshala' || p.category == 'tent';
      if (!isAccom) return false;
      if (_selectedSubcategory == 'all') return true;
      return p.category == _selectedSubcategory;
    }).toList();

    return Column(
      children: [
        // Sub-filter Pills (Horizontally scrollable with smooth bounce)
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSubChip('All Stays', 'all'),
                const SizedBox(width: 8),
                _buildSubChip('🏢 Dharamshalas', 'dharamshala'),
                const SizedBox(width: 8),
                _buildSubChip('🏨 Hotels', 'hotel'),
                const SizedBox(width: 8),
                _buildSubChip('⛺ Tent Cities', 'tent'),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 96),
            physics: const BouncingScrollPhysics(),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return _buildStayCard(place);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransportView() {
    final places = _places.where((p) {
      if (p.category != 'transport' && p.category != 'parking') return false;
      if (_selectedTransportFilter == 'all') return true;
      if (_selectedTransportFilter == 'parking') return p.category == 'parking';
      if (_selectedTransportFilter == 'train') {
        return p.category == 'transport' && (p.icon.contains('🚆') || p.name.toLowerCase().contains('station') || p.name.toLowerCase().contains('junction'));
      }
      if (_selectedTransportFilter == 'bus') {
        return p.category == 'transport' && (p.icon.contains('🚌') || p.name.toLowerCase().contains('bus'));
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Sub-filter Pills for Transport (Horizontally scrollable)
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTransportChip('All Transit', 'all'),
                const SizedBox(width: 8),
                _buildTransportChip('🚆 Railway Stations', 'train'),
                const SizedBox(width: 8),
                _buildTransportChip('🚌 Bus Stands', 'bus'),
                const SizedBox(width: 8),
                _buildTransportChip('🅿️ Parking Areas', 'parking'),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 96),
            physics: const BouncingScrollPhysics(),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return _buildTransitCard(place);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransportChip(String label, String value) {
    final isSelected = _selectedTransportFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedTransportFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSubChip(String label, String value) {
    final isSelected = _selectedSubcategory == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedSubcategory = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildStayCard(SimhasthaPlace place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
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
                      Text(
                        place.area,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 13, color: AppColors.accent),
                      const SizedBox(width: 3),
                      Text(
                        '${place.rating}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              place.description,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
            ),
            if (place.pricing != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.payments_rounded, size: 14, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text(
                      'Tariff: ${place.pricing}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.success),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (place.contact != null) ...[
                  OutlinedButton.icon(
                    onPressed: () => _callPhone(place.contact!),
                    icon: const Icon(Icons.call, size: 15, color: AppColors.primary),
                    label: const Text('Call Desk', style: TextStyle(fontSize: 11.5, color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                ElevatedButton.icon(
                  onPressed: () => _openInGoogleMaps(place.lat, place.lon),
                  icon: const Icon(Icons.navigation, size: 15),
                  label: const Text('Directions', style: TextStyle(fontSize: 11.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransitCard(SimhasthaPlace place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
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
                      Text(
                        place.area,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
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
            if (place.pricing != null) ...[
              const SizedBox(height: 4),
              Text('💰 Rates: ${place.pricing}', style: const TextStyle(fontSize: 11.5, color: AppColors.success, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    widget.onAskAi?.call('How do I travel to or park at ${place.name} in Ujjain?');
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 15),
                  label: const Text('Ask Transit AI', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  onPressed: () => _openInGoogleMaps(place.lat, place.lon),
                  icon: const Icon(Icons.directions, size: 15),
                  label: const Text('Navigate', style: TextStyle(fontSize: 11.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

