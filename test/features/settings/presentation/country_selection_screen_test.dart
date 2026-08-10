import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitflow/features/settings/presentation/country_selection_screen.dart';
import 'package:habitflow/core/theme/theme_controller.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
  });

  testWidgets('CountrySelectionScreen displays list of countries', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
        child: const MaterialApp(
          home: CountrySelectionScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'United States');
    await tester.pump();

    expect(find.widgetWithText(ListTile, 'United States'), findsOneWidget);
  });

  testWidgets('CountrySelectionScreen filters list by search query', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
        child: const MaterialApp(
          home: CountrySelectionScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Japan');
    await tester.pump();

    expect(find.text('United States'), findsNothing);
    expect(find.widgetWithText(ListTile, 'Japan'), findsOneWidget);
  });
}
