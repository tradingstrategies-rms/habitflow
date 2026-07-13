import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitflow/core/theme/theme_controller.dart';

void main() {
  group('ThemeController', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('initial state is system if nothing is saved', () {
      final controller = ThemeController(prefs);
      expect(controller.state, HFThemeMode.system);
      expect(controller.themeMode, ThemeMode.system);
    });

    test('loads saved theme from preferences', () async {
      await prefs.setString('hf_theme_mode', 'dark');
      final controller = ThemeController(prefs);
      expect(controller.state, HFThemeMode.dark);
      expect(controller.themeMode, ThemeMode.dark);
    });

    test('setThemeMode updates state and persists to preferences', () {
      final controller = ThemeController(prefs);
      controller.setThemeMode(HFThemeMode.light);
      
      expect(controller.state, HFThemeMode.light);
      expect(controller.themeMode, ThemeMode.light);
      expect(prefs.getString('hf_theme_mode'), 'light');
    });

    test('kids theme returns ThemeMode.light', () {
      final controller = ThemeController(prefs);
      controller.setThemeMode(HFThemeMode.kids);
      
      expect(controller.state, HFThemeMode.kids);
      expect(controller.themeMode, ThemeMode.light);
    });
  });
}
