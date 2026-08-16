import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/enums/family_role.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_provider.dart';
import 'package:habitflow/features/subscription/application/providers/subscription_providers.dart';
import 'package:habitflow/features/subscription/application/services/premium_service.dart';
import 'package:habitflow/features/subscription/domain/entities/subscription.dart';
import 'package:habitflow/features/subscription/domain/enums/subscription_status.dart';
import 'package:habitflow/features/subscription/presentation/screens/subscription_screen.dart';
import 'package:habitflow/features/billing/domain/entities/premium_event_type.dart';
import 'package:habitflow/features/billing/domain/entities/premium_telemetry_event.dart';
import 'package:habitflow/features/billing/application/providers/billing_providers.dart';
import 'package:habitflow/features/billing/domain/entities/billing_product.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';

class MockRef extends Mock implements Ref {}

class FakeActiveProfileNotifier extends ActiveProfileNotifier {
  FakeActiveProfileNotifier(FamilyProfile? initial) : super(MockRef()) {
    state = initial;
  }
}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  
  setUpAll(() {
    registerFallbackValue(MockRef());
    registerFallbackValue(PremiumTelemetryEvent(
      type: PremiumEventType.subscriptionScreenViewed,
      timestamp: DateTime.now(),
    ));
  });

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.getStringList(any())).thenReturn([]);
    when(() => mockPrefs.setStringList(any(), any())).thenAnswer((_) async => true);
  });

  final adultProfile = FamilyProfile(
    id: 'p1',
    familyId: 'f1',
    displayName: 'Adult',
    profileType: ProfileType.adult,
    role: FamilyRole.owner,
    requiresPin: false,
    createdAt: DateTime.now(),
  );

  const mockProduct = BillingProduct(
    id: 'hf_premium_monthly',
    name: 'Premium',
    description: 'Desc',
    price: 4.99,
    currencyCode: 'USD',
    formattedPrice: '\$4.99/mo',
  );

  group('Subscription Hardening', () {
    testWidgets('Expired Premium shows Upgrade CTA', (tester) async {
      final expiredSubscription = Subscription(
        id: 'expired',
        status: SubscriptionStatus.expired,
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            subscriptionStreamProvider.overrideWith((ref) => Stream.value(expiredSubscription)),
            premiumServiceProvider.overrideWithValue(PremiumService(expiredSubscription)),
            activeProfileProvider.overrideWith((ref) => FakeActiveProfileNotifier(adultProfile)),
            availableProductsProvider.overrideWith((ref) => Future.value([mockProduct])),
          ],
          child: const MaterialApp(home: SubscriptionScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Expired'), findsOneWidget);
      expect(find.textContaining('Upgrade for'), findsOneWidget);
    });

    testWidgets('Cancelled Premium shows Upgrade CTA', (tester) async {
      final cancelledSubscription = Subscription(
        id: 'cancelled',
        status: SubscriptionStatus.cancelled,
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            subscriptionStreamProvider.overrideWith((ref) => Stream.value(cancelledSubscription)),
            premiumServiceProvider.overrideWithValue(PremiumService(cancelledSubscription)),
            activeProfileProvider.overrideWith((ref) => FakeActiveProfileNotifier(adultProfile)),
            availableProductsProvider.overrideWith((ref) => Future.value([mockProduct])),
          ],
          child: const MaterialApp(home: SubscriptionScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Active (Cancelled)'), findsOneWidget);
      expect(find.textContaining('Upgrade for'), findsOneWidget);
    });

    testWidgets('State updates reactively when stream emits new value', (tester) async {
      final controller = StreamController<Subscription>();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            subscriptionStreamProvider.overrideWith((ref) => controller.stream),
            activeProfileProvider.overrideWith((ref) => FakeActiveProfileNotifier(adultProfile)),
            availableProductsProvider.overrideWith((ref) => Future.value([mockProduct])),
          ],
          child: const MaterialApp(home: SubscriptionScreen()),
        ),
      );

      // Emit Free
      controller.add(Subscription.free());
      await tester.pump(); // Start stream
      await tester.pumpAndSettle();
      expect(find.text('HabitFlow Free'), findsOneWidget);

      // Emit Premium
      final premiumSubscription = Subscription(
        id: 'premium',
        status: SubscriptionStatus.premium,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
      controller.add(premiumSubscription);
      await tester.pump(); // Get new value
      await tester.pumpAndSettle();
      
      expect(find.text('HabitFlow Premium'), findsOneWidget);
      
      await controller.close();
    });
  });
}
