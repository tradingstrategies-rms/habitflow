import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported theme modes in HabitFlow.
enum HFThemeMode {
  light,
  dark,
  kids,
  system;

  String get name => toString().split('.').last;
}

/// Provider for [SharedPreferences].
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this in main.dart');
});

/// [ThemeController] manages the application's theme state and persistence.
class ThemeController extends StateNotifier<HFThemeMode> {
  ThemeController(this._prefs) : super(_loadTheme(_prefs));

  final SharedPreferences _prefs;
  static const String _themeKey = 'hf_theme_mode';

  static HFThemeMode _loadTheme(SharedPreferences prefs) {
    final themeName = prefs.getString(_themeKey);
    if (themeName == null) return HFThemeMode.system;
    return HFThemeMode.values.firstWhere(
      (e) => e.name == themeName,
      orElse: () => HFThemeMode.system,
    );
  }

  void setThemeMode(HFThemeMode mode) {
    state = mode;
    _prefs.setString(_themeKey, mode.name);
  }

  ThemeMode get themeMode {
    switch (state) {
      case HFThemeMode.light:
        return ThemeMode.light;
      case HFThemeMode.dark:
        return ThemeMode.dark;
      case HFThemeMode.system:
        return ThemeMode.system;
      case HFThemeMode.kids:
        return ThemeMode.light; // Kids theme is a specialized light theme
    }
  }
}

/// Provider for the [ThemeController].
final themeControllerProvider = StateNotifierProvider<ThemeController, HFThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeController(prefs);
});
