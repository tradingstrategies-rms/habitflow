import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitflow/features/settings/application/settings_notifier.dart';
import 'package:habitflow/features/settings/domain/country_constants.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late SettingsNotifier notifier;
  late MockSharedPreferences mockPrefs;

  setUpAll(() {
    tz.initializeTimeZones();
  });

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    notifier = SettingsNotifier(mockPrefs);
  });

  group('SettingsNotifier', () {
    test('initial state should be the first country in constants', () {
      expect(notifier.state.selectedCountry, CountryConstants.countries.first);
    });

    test('setCountry should update state, persist and update timezone', () async {
      final country = CountryConstants.countries.firstWhere((c) => c.code == 'JP');
      await notifier.setCountry(country);
      
      expect(notifier.state.selectedCountry, country);
      expect(tz.local.name, country.timezone);
      verify(() => mockPrefs.setString('settings_country', any())).called(1);
    });

    test('should load country and timezone on initialization', () {
      final country = CountryConstants.countries.firstWhere((c) => c.code == 'GB');
      when(() => mockPrefs.getString('settings_country'))
          .thenReturn(json.encode(country.toJson()));
      
      notifier = SettingsNotifier(mockPrefs);
      
      expect(notifier.state.selectedCountry, country);
      expect(tz.local.name, country.timezone);
    });
  });
}
