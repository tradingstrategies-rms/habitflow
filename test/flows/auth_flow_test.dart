import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitflow/app/habit_flow_app.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/features/authentication/data/auth_providers.dart';
import 'package:habitflow/features/profile/data/profile_providers.dart';
import 'package:habitflow/features/profile/domain/user_profile.dart';
import 'package:habitflow/features/profile/domain/family_role.dart';
import 'package:habitflow/core/services/auth/auth_service.dart';
import 'package:habitflow/core/services/database/database_service.dart';
import 'package:habitflow/features/splash/presentation/splash_providers.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget createTestWidget({required List<Override> overrides}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authServiceProvider.overrideWithValue(NoOpAuthService()),
        databaseServiceProvider.overrideWithValue(NoOpDatabaseService()),
        ...overrides,
      ],
      child: const HabitFlowApp(),
    );
  }

  testWidgets('Authenticated user with profile is redirected to Dashboard', (tester) async {
    const mockProfile = UserProfile(
      uid: 'user123',
      firstName: 'Test',
      lastName: 'User',
      displayName: 'Test User',
      country: 'US',
      language: 'en',
      timezone: 'UTC',
      familyRole: FamilyRole.parent,
    );

    await tester.pumpWidget(
      createTestWidget(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value('user123')),
          userProfileProvider.overrideWith((ref) => Stream.value(mockProfile)),
          splashMinTimeReachedProvider.overrideWith((ref) => true),
        ],
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify we are on Dashboard
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Daily Score'), findsOneWidget);
  });

  testWidgets('Unauthenticated user is redirected to Welcome', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          userProfileProvider.overrideWith((ref) => Stream.value(null)),
          splashMinTimeReachedProvider.overrideWith((ref) => true),
        ],
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify we are on Welcome screen
    expect(find.text('Small Habits.\nBig Futures.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
