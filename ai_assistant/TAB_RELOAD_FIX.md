# Tab Reload Layout Error Fix - October 30, 2026

## Problem Solved
**Error**: "Cannot hit test a render box that has never been laid out" (repeating 50+ times)

**Root Cause**: 
- `IndexedStack` renders ALL tabs simultaneously in memory
- Each tab's `initState()` tried to register callbacks immediately
- Widgets weren't laid out yet, causing hit-test failures
- Callbacks were being fired during the build phase instead of after layout

## Solution Implemented
Used **`WidgetsBinding.addPostFrameCallback()` with a 100ms delay** to defer callback registration until after all tabs are fully laid out and rendered.

### Changes Made

#### 1. **home_screen.dart**
- Changed from `onReloadCallback` parameter to `onRegisterReload`
- Added `_registerReloadCallback(int tabIndex, VoidCallback callback)` method
- Modified `_onTabChanged()` to safely check if callback exists before calling

```dart
void _onTabChanged(int index) {
  setState(() => _currentIndex = index);
  
  // Trigger reload for the selected tab if callback exists
  if (_reloadCallbacks.containsKey(index)) {
    _reloadCallbacks[index]?.call();
  }
}
```

#### 2. **All Tab Files** (temple_guide_tab.dart, calendar_events_tab.dart, accommodation_transport_tab.dart)
- Updated parameter name from `onReloadCallback` to `onRegisterReload`
- Changed `initState()` to defer callback registration with 100ms delay:

```dart
@override
void initState() {
  super.initState();
  _loadEventsFromBackend();
  
  // Register reload callback with a slight delay to ensure full layout
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        widget.onRegisterReload?.call(_loadEventsFromBackend);
      }
    });
  });
}
```

This two-step timing ensures:
- First: All tabs are rendered by Flutter
- Second: 100ms delay gives time for all interactive elements to initialize
- Third: Callbacks are safely registered without any layout conflicts

## How It Works Now

1. **Tab Initialization** (happens immediately during build):
   - Tab loads data from backend
   - Callback registration is DEFERRED

2. **First Frame Complete** (post-frame callback):
   - All tabs are now laid out and rendered
   - Callbacks are safely registered with parent

3. **User Switches Tab**:
   - `_onTabChanged()` is called
   - Callback is invoked safely
   - Tab reloads data from backend

## Results

✅ No more layout errors
✅ Responsive bottom navigation menu works perfectly
✅ Each tab reloads fresh data when user switches to it
✅ Backend data continuously updates when tabs are switched

## Testing Checklist

- [x] App compiles without errors
- [x] Bottom navigation renders responsively
- [x] No "Cannot hit test render box" errors in console
- [x] Switching tabs triggers data reload (check for `[Backend] 🔄` logs)
- [x] Backend data displays correctly in each tab

## Related Files

- `lib/services/simhastha_backend_service.dart` - Backend API calls
- `lib/screens/home_screen.dart` - Tab management & routing
- Tab files with reload logic:
  - `lib/screens/tabs/temple_guide_tab.dart`
  - `lib/screens/tabs/calendar_events_tab.dart`
  - `lib/screens/tabs/accommodation_transport_tab.dart`
