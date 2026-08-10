import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitflow/features/settings/presentation/settings_screen.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'package:habitflow/features/settings/domain/country_constants.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.getInt(any())).thenReturn(null);
  });

  testWidgets('SettingsScreen displays theme and country options', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    expect(find.text('Theme Mode'), findsOneWidget);
    expect(find.text('Country'), findsOneWidget);
    
    // Default country should be displayed
    final defaultCountry = CountryConstants.countries.first;
    expect(find.textContaining(defaultCountry.name), findsOneWidget);
  });
}
