import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/simhastha_event.dart';
import '../../services/simhastha_backend_service.dart';

class CalendarEventsTab extends StatefulWidget {
  final Function(String query)? onAskAi;

  const CalendarEventsTab({super.key, this.onAskAi});

  @override
  State<CalendarEventsTab> createState() => CalendarEventsTabState();
}

class CalendarEventsTabState extends State<CalendarEventsTab> with AutomaticKeepAliveClientMixin {
  String _selectedFilter = 'all'; // 'all', 'shahi', 'parva', 'procession'
  List<SnanEvent> _events = SimhasthaCalendarData.events;
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true; // Keep tab alive when switching

  @override
  void initState() {
    super.initState();
    _loadEventsFromBackend();
  }

  // Public method to refresh data
  void refreshData() {
    print('[CalendarEventsTab] ✅ refreshData() called! Starting backend fetch...');
    _loadEventsFromBackend();
  }

  Future<void> _loadEventsFromBackend() async {
    print('[CalendarEventsTab] 🔄 _loadEventsFromBackend() executing...');
    setState(() => _isLoading = true);
    final data = await SimhasthaBackendService().fetchEvents();
    if (mounted) {
      setState(() {
        _events = data;
        _isLoading = false;
      });
      print('[CalendarEventsTab] ✅ UI updated with ${_events.length} events');
    }
  }

  List<SnanEvent> get _filteredEvents {
    return _events.where((e) {
      if (_selectedFilter == 'all') return true;
      if (_selectedFilter == 'shahi') return e.isShahiSnan;
      if (_selectedFilter == 'parva') return e.type == 'parva_snan';
      if (_selectedFilter == 'procession') return e.type == 'procession' || e.type == 'program';
      if (_selectedFilter == 'program') return e.type == 'program';
      return true;
    }).toList();
  }

  void _showNotificationReminder(SnanEvent event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Reminder pinned for ${event.hindiTitle} (${event.date})',
                style: const TextStyle(fontSize: 12.5),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Banner for Simhastha 2028 Announcement
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.templeGold),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_available, color: AppColors.templeGold, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'सिंहस्थ महाकुंभ २०२८ पंचांग',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'April 9 – May 8, 2028',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Auspicious Snan Dates & Event Calendar',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Plan your holy dip at Ram Ghat during peak astronomical planetary alignments.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                ),
                const SizedBox(height: 12),
                // Horizontally Scrollable Filter Chips (Full-width edge-to-edge scroll)
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildFilterChip('All Events', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('👑 Shahi Snan', 'shahi'),
                      const SizedBox(width: 8),
                      _buildFilterChip('🌊 Parva Snan', 'parva'),
                      const SizedBox(width: 8),
                      _buildFilterChip('🚩 Processions', 'procession'),
                      const SizedBox(width: 8),
                      _buildFilterChip('🪔 Programs', 'program'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Events List with bottom clearance for floating AI button
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 96),
              physics: const BouncingScrollPhysics(),
              itemCount: _filteredEvents.length,
              itemBuilder: (context, index) {
                final event = _filteredEvents[index];
                return _buildEventCard(event);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.templeGold : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.templeGold : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primaryDark : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(SnanEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: event.isShahiSnan ? 3 : 1.5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: event.isShahiSnan ? AppColors.templeGold : AppColors.divider,
            width: event.isShahiSnan ? 1.8 : 0.8,
          ),
        ),
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
                    color: event.isShahiSnan
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      event.isShahiSnan ? '👑' : '🌊',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.hindiTitle,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ),
                          if (event.isShahiSnan)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'SHAHI SNAN',
                                style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        event.title,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  event.date,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const Spacer(),
                const Icon(Icons.brightness_medium_rounded, size: 14, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(
                  event.tithi,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.pin_drop_rounded, size: 15, color: AppColors.secondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.location,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event.hindiSignificance,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.35),
            ),
            const SizedBox(height: 4),
            Text(
              event.significance,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showNotificationReminder(event),
                  icon: const Icon(Icons.alarm_add_rounded, size: 15, color: AppColors.primary),
                  label: const Text('Set Reminder', style: TextStyle(fontSize: 11.5, color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    widget.onAskAi?.call('Tell me complete schedule, precautions, and muhurat for ${event.hindiTitle} during Simhastha 2028');
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 15),
                  label: const Text('Ask AI Guide', style: TextStyle(fontSize: 11.5)),
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

