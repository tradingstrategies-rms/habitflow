import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'package:habitflow/features/challenges/presentation/screens/challenges_dashboard_screen.dart';
import 'package:habitflow/features/subscription/application/providers/subscription_providers.dart';
import 'package:habitflow/features/subscription/application/services/premium_service.dart';
import 'package:habitflow/features/subscription/domain/entities/subscription.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('free users see the premium challenges gate', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          premiumServiceProvider.overrideWithValue(
            PremiumService(Subscription.free()),
          ),
        ],
        child: const MaterialApp(home: ChallengesDashboardScreen()),
      ),
    );

    await tester.pump();

    expect(find.text('Premium Challenges'), findsOneWidget);
    expect(find.text('View Premium Plans'), findsOneWidget);
  });
}
