import 'package:flutter/material.dart';

/// [HFBottomNavigation] is the primary navigation shell for HabitFlow.
/// 
/// It implements the Material 3 Navigation Bar pattern.
/// 
/// ### Example Usage:
/// ```dart
/// HFBottomNavigation(
///   currentIndex: 0,
///   onDestinationSelected: (index) => setState(() => _index = index),
/// )
/// ```
class HFBottomNavigation extends StatelessWidget {
  /// Creates an [HFBottomNavigation].
  const HFBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  /// The index of the currently selected navigation item.
  final int currentIndex;

  /// Callback when a navigation item is selected.
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.check_circle_outline_rounded),
          selectedIcon: Icon(Icons.check_circle_rounded),
          label: 'Habits',
        ),
        NavigationDestination(
          icon: Icon(Icons.emoji_events_outlined),
          selectedIcon: Icon(Icons.emoji_events_rounded),
          label: 'Rewards',
        ),
        NavigationDestination(
          icon: Icon(Icons.family_restroom_outlined),
          selectedIcon: Icon(Icons.family_restroom_rounded),
          label: 'Family',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
