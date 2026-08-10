import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../domain/country.dart';
import '../domain/country_constants.dart';
import 'package:habitflow/core/theme/theme_controller.dart';

class SettingsState {
  final Country selectedCountry;

  SettingsState({required this.selectedCountry});

  SettingsState copyWith({Country? selectedCountry}) {
    return SettingsState(
      selectedCountry: selectedCountry ?? this.selectedCountry,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;
  static const String _countryKey = 'settings_country';

  SettingsNotifier(this._prefs)
      : super(SettingsState(
          selectedCountry: CountryConstants.countries.first,
        )) {
    _loadSettings();
  }

  void _loadSettings() {
    final countryJson = _prefs.getString(_countryKey);
    if (countryJson != null) {
      try {
        final country = Country.fromJson(json.decode(countryJson));
        state = state.copyWith(selectedCountry: country);
        _updateTimezone(country.timezone);
      } catch (_) {
        _updateTimezone(state.selectedCountry.timezone);
      }
    } else {
      _updateTimezone(state.selectedCountry.timezone);
    }
  }

  Future<void> setCountry(Country country) async {
    state = state.copyWith(selectedCountry: country);
    await _prefs.setString(_countryKey, json.encode(country.toJson()));
    _updateTimezone(country.timezone);
  }

  void _updateTimezone(String timezoneName) {
    try {
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      // Fallback if timezone not found
      tz.setLocalLocation(tz.UTC);
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
