import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/app/habit_flow_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitflow/core/theme/theme_controller.dart';

import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/core/services/auth/auth_service.dart';
import 'package:habitflow/core/services/database/database_service.dart';
import 'package:habitflow/features/authentication/data/auth_providers.dart';
import 'package:habitflow/features/profile/data/profile_providers.dart';

void main() {
  testWidgets('App navigation and branding smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authServiceProvider.overrideWithValue(NoOpAuthService()),
          databaseServiceProvider.overrideWithValue(NoOpDatabaseService()),
        ],
        child: const HabitFlowApp(),
      ),
    );

    // With the new router, initial location is /splash
    await tester.pump(); // Start building
    await tester.pump(const Duration(seconds: 3)); // Wait for splash timer (2s) + routing

    // Verify app name in splash or dashboard (depending on redirect)
    expect(find.text('HabitFlow'), findsWidgets);
  });
}
