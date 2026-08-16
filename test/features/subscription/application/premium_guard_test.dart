import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/subscription/application/services/premium_guard.dart';
import 'package:habitflow/features/subscription/application/providers/subscription_providers.dart';
import 'package:habitflow/features/subscription/domain/entities/subscription.dart';
import 'package:habitflow/features/subscription/domain/enums/subscription_status.dart';
import 'package:habitflow/features/subscription/application/services/premium_service.dart';

class GuardedWidget extends ConsumerWidget with PremiumGuard {
  const GuardedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => guardFeature(context, ref),
          child: const Text('Guarded Action'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('PremiumGuard should show SnackBar when not premium', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          premiumServiceProvider.overrideWithValue(PremiumService(Subscription.free())),
        ],
        child: const MaterialApp(
          home: GuardedWidget(),
        ),
      ),
    );

    await tester.tap(find.text('Guarded Action'));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 500)); // Halfway through animation

    expect(find.text('Premium subscription required to access this feature.'), findsOneWidget);
  });

  testWidgets('PremiumGuard should NOT show SnackBar when premium', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          premiumServiceProvider.overrideWithValue(PremiumService(const Subscription(
            id: '1',
            status: SubscriptionStatus.premium,
          ))),
        ],
        child: const MaterialApp(
          home: GuardedWidget(),
        ),
      ),
    );

    await tester.tap(find.text('Guarded Action'));
    await tester.pump();

    expect(find.text('Premium subscription required to access this feature.'), findsNothing);
  });
}
