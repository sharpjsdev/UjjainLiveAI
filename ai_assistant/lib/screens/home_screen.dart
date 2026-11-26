import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'chat_screen.dart';
import 'tabs/osm_live_map_tab.dart';
import 'tabs/temple_guide_tab.dart';
import 'tabs/calendar_events_tab.dart';
import 'tabs/accommodation_transport_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<Widget> _tabs;
  
  // Keys to access tab states
  final GlobalKey<TempleGuideTabState> _templeTabKey = GlobalKey<TempleGuideTabState>();
  final GlobalKey<CalendarEventsTabState> _eventsTabKey = GlobalKey<CalendarEventsTabState>();
  final GlobalKey<AccommodationTransportTabState> _staysTabKey = GlobalKey<AccommodationTransportTabState>();

  @override
  void initState() {
    super.initState();
    _tabs = [
      OSMLiveMapTab(onAskAi: _openChatWithPrompt),
      TempleGuideTab(key: _templeTabKey, onAskAi: _openChatWithPrompt),
      CalendarEventsTab(key: _eventsTabKey, onAskAi: _openChatWithPrompt),
      AccommodationTransportTab(key: _staysTabKey, onAskAi: _openChatWithPrompt),
    ];
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
    
    // Always refresh data when switching to these tabs
    print('[HomeScreen] 🔄 Tab changed to index $index');
    
    // Use post-frame callback to ensure the widget is built before calling refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshTab(index);
    });
  }

  void _refreshTab(int index) {
    switch (index) {
      case 1: // Temple Guide
        print('[HomeScreen] 🔄 Attempting to refresh Temple Guide tab...');
        if (_templeTabKey.currentState != null) {
          print('[HomeScreen] ✅ Temple tab state found, calling refreshData()');
          _templeTabKey.currentState!.refreshData();
        } else {
          print('[HomeScreen] ⚠️ Temple tab state is NULL, cannot refresh');
        }
        break;
      case 2: // Events
        print('[HomeScreen] 🔄 Attempting to refresh Events tab...');
        if (_eventsTabKey.currentState != null) {
          print('[HomeScreen] ✅ Events tab state found, calling refreshData()');
          _eventsTabKey.currentState!.refreshData();
        } else {
          print('[HomeScreen] ⚠️ Events tab state is NULL, cannot refresh');
        }
        break;
      case 3: // Stays & Transit
        print('[HomeScreen] 🔄 Attempting to refresh Stays & Transit tab...');
        if (_staysTabKey.currentState != null) {
          print('[HomeScreen] ✅ Stays tab state found, calling refreshData()');
          _staysTabKey.currentState!.refreshData();
        } else {
          print('[HomeScreen] ⚠️ Stays tab state is NULL, cannot refresh');
        }
        break;
      default:
        print('[HomeScreen] ℹ️ Tab $index does not require refresh (Live Map)');
    }
  }

  void _openChatWithPrompt(String prompt) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(initialMessage: prompt),
      ),
    );
  }

  void _openChatInterface() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ChatScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
          ),
        ),
        elevation: 2,
        titleSpacing: 4,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.templeGold, width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/simhastha_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text('ॐ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ujjain Live',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _getTitleForTab(_currentIndex),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.forum_rounded, color: Colors.white),
            tooltip: 'Open Ujjain Live Chat',
            onPressed: _openChatInterface,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(
                color: AppColors.divider.withValues(alpha: 0.6),
                width: 0.8,
              ),
            ),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 66,
              indicatorColor: AppColors.primary.withValues(alpha: 0.16),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final isSelected = states.contains(WidgetState.selected);
                return TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  letterSpacing: -0.2,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabChanged,
              backgroundColor: Colors.transparent,
              elevation: 0,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map_rounded, color: AppColors.primary),
                  label: 'Live Map',
                ),
                NavigationDestination(
                  icon: Icon(Icons.temple_hindu_outlined),
                  selectedIcon: Icon(Icons.temple_hindu_rounded, color: AppColors.primary),
                  label: 'Temples',
                ),
                NavigationDestination(
                  icon: Icon(Icons.event_outlined),
                  selectedIcon: Icon(Icons.event_available_rounded, color: AppColors.primary),
                  label: 'Events',
                ),
                NavigationDestination(
                  icon: Icon(Icons.hotel_outlined),
                  selectedIcon: Icon(Icons.hotel_rounded, color: AppColors.primary),
                  label: 'Stays',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openChatInterface,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 5,
        tooltip: 'Ask Ujjain Live AI',
        child: const Icon(Icons.chat_bubble_rounded),
      ),
    );
  }

  String _getTitleForTab(int index) {
    switch (index) {
      case 0:
        return 'Interactive Facility & Pilgrim Map';
      case 1:
        return 'Aarti, Darshan Routes & Entry Gates';
      case 2:
        return 'Events & Auspicious Dates';
      case 3:
        return 'Dharamshalas, Hotels & Transport';
      default:
        return 'Simhastha Margdarshak';
    }
  }
}
