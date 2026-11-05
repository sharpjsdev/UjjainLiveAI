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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      ),
    );
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
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
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
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ujjain Live',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  _getTitleForTab(_currentIndex),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabChanged,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.18),
        elevation: 4,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded, color: AppColors.primary),
            label: 'Live Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.temple_hindu_outlined),
            selectedIcon: Icon(Icons.temple_hindu_rounded, color: AppColors.primary),
            label: 'Temple Guide',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event_available_rounded, color: AppColors.primary),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.hotel_outlined),
            selectedIcon: Icon(Icons.hotel_rounded, color: AppColors.primary),
            label: 'Stays & Transit',
          ),
        ],
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
