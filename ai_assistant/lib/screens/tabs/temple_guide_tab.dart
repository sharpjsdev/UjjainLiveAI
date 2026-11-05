import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../models/temple_darshan_info.dart';
import '../../services/simhastha_backend_service.dart';

class TempleGuideTab extends StatefulWidget {
  final Function(String query)? onAskAi;

  const TempleGuideTab({super.key, this.onAskAi});

  @override
  State<TempleGuideTab> createState() => TempleGuideTabState();
}

class TempleGuideTabState extends State<TempleGuideTab> with AutomaticKeepAliveClientMixin {
  int _selectedTempleIndex = 0;
  List<TempleDarshanInfo> _temples = TempleGuideData.temples;
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true; // Keep tab alive when switching

  @override
  void initState() {
    super.initState();
    _loadTemplesFromBackend();
  }

  // Public method to refresh data
  void refreshData() {
    print('[TempleGuideTab] ✅ refreshData() called! Starting backend fetch...');
    _loadTemplesFromBackend();
  }

  Future<void> _loadTemplesFromBackend() async {
    print('[TempleGuideTab] 🔄 _loadTemplesFromBackend() executing...');
    setState(() => _isLoading = true);
    final data = await SimhasthaBackendService().fetchTemples();
    if (mounted) {
      setState(() {
        _temples = data;
        _isLoading = false;
        if (_selectedTempleIndex >= _temples.length) {
          _selectedTempleIndex = 0;
        }
      });
      print('[TempleGuideTab] ✅ UI updated with ${_temples.length} temples');
    }
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    if (_temples.isEmpty) {
      return const Center(child: Text('No temple data available'));
    }
    final temple = _temples[_selectedTempleIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Temple Selector Horizontal Scroll
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _temples.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final isSelected = _selectedTempleIndex == index;
                  final t = _temples[index];
                  return ChoiceChip(
                    label: Text(
                      t.hindiName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.cardBackground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider),
                    onSelected: (_) => setState(() => _selectedTempleIndex = index),
                  );
                },
              ),
            ),
          ),

          // Detailed Temple Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Beautiful Hero Temple Card with Image Showcase
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.templeGold.withValues(alpha: 0.35), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Temple Image Showcase with Rounded Top & Scrim Overlay
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                          child: Stack(
                            children: [
                              // Temple Image / Placeholder
                              if (temple.imageUrl != null && temple.imageUrl!.isNotEmpty)
                                Image.network(
                                  temple.imageUrl!,
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 220,
                                      decoration: const BoxDecoration(
                                        gradient: AppColors.headerGradient,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                          color: AppColors.templeGold,
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(temple),
                                )
                              else
                                _buildImagePlaceholder(temple),

                              // Gradient Scrim for readable text
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.2),
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.88),
                                      ],
                                      stops: const [0.0, 0.45, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                              // Top Left Sacred Badge
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.templeGold.withValues(alpha: 0.7)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('🕉️', style: TextStyle(fontSize: 12)),
                                      SizedBox(width: 5),
                                      Text(
                                        'Sacred Shrine',
                                        style: TextStyle(
                                          color: AppColors.templeGold,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Top Right "Open for Darshan" Status Pill
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B5E20).withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.lightGreenAccent.withValues(alpha: 0.8)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                                      SizedBox(width: 5),
                                      Text(
                                        'Darshan Open',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Bottom Overlay Text on Image
                              Positioned(
                                bottom: 12,
                                left: 14,
                                right: 14,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      temple.templeName,
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                        shadows: [
                                          Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 1)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      temple.hindiName,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.templeGold,
                                        shadows: [
                                          Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Card Body Details
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Deity Tag & Quick Highlight
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      temple.deity,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Significance Quote / Description
                              Text(
                                temple.significance,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Timing Badge Row
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time_filled_rounded, color: AppColors.primary, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        temple.timing,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Action Buttons Row: Portal & Ask AI
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _openUrl(temple.bookingWebsite),
                                      icon: const Icon(Icons.language, size: 16),
                                      label: const Text('Portal & E-Pass', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: const BorderSide(color: AppColors.primary),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        widget.onAskAi?.call('Give complete darshan timings, aarti, and rules for ${temple.templeName}');
                                      },
                                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                                      label: const Text('Ask AI Guide', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 1. Aarti Schedule Section
                  _buildSectionCard(
                    title: 'Sacred Aarti Schedule (दैनिक आरती समय सारणी)',
                    icon: Icons.notifications_active_rounded,
                    child: Column(
                      children: temple.aartis.map((aarti) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      aarti.hindiName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.wb_sunny_rounded, size: 14, color: AppColors.accent),
                                  const SizedBox(width: 4),
                                  Text(
                                    aarti.timingSummer,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                aarti.description,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Entry Gates & Routes
                  _buildSectionCard(
                    title: 'Entry Gates & Darshan Routes (प्रवेश द्वार एवं मार्ग)',
                    icon: Icons.meeting_room_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Entry Gates & Access:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        ...temple.entryGates.map((gate) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('🚪 ', style: TextStyle(fontSize: 13)),
                                  Expanded(
                                    child: Text(gate, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(height: 18),
                        const Text(
                          'Queue Flow & Routes:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        ...temple.darshanRoutes.map((route) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('➡️ ', style: TextStyle(fontSize: 13)),
                                  Expanded(
                                    child: Text(route, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Fast-Track VIP & Online Booking
                  _buildSectionCard(
                    title: 'Sheegra / VIP Darshan & Booking',
                    icon: Icons.confirmation_number_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          temple.vipFastTrackRules,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _openUrl(temple.bookingWebsite),
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('Open Official Temple Booking Portal', style: TextStyle(fontSize: 12.5)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. Dress Code & Sacred Prasad
                  _buildSectionCard(
                    title: 'Dress Code & Mahaprasad Rules',
                    icon: Icons.check_circle_outline_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '👔 Sanctum Dress Code:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          temple.dressCode,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '🍯 Prasad Information:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          temple.prasadDetails,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Ask AI Floating Action
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.onAskAi?.call('Explain Bhasma Aarti booking and darshan procedure for ${temple.templeName}');
                      },
                      icon: const Icon(Icons.auto_awesome, size: 16),
                      label: Text('Ask AI Margdarshak about ${temple.hindiName}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(TempleDarshanInfo temple) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🕉️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              temple.hindiName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          child,
        ],
      ),
    );
  }
}

