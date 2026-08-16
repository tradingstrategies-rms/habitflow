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
import 'package:habitflow/features/billing/application/providers/telemetry_providers.dart';
import 'package:habitflow/features/billing/domain/entities/premium_conversion_metrics.dart';
import 'package:habitflow/features/billing/domain/repositories/premium_telemetry_service.dart';
import 'package:habitflow/features/subscription/presentation/screens/subscription_screen.dart';
import 'package:habitflow/features/subscription/presentation/widgets/premium_feature_locked_view.dart';
import 'package:habitflow/features/billing/application/providers/billing_providers.dart';
import 'package:habitflow/features/billing/domain/entities/premium_event_type.dart';
import 'package:habitflow/features/billing/domain/entities/premium_telemetry_event.dart';
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
class MockTelemetryService extends Mock implements PremiumTelemetryService {}

void main() {
  late MockSharedPreferences mockPrefs;
  late MockTelemetryService mockTelemetry;
  
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
    mockTelemetry = MockTelemetryService();
    when(() => mockTelemetry.recordEvent(any())).thenAnswer((_) async => {});
    when(() => mockTelemetry.getMetrics()).thenAnswer((_) async => PremiumConversionMetrics.empty());
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

  final childProfile = FamilyProfile(
    id: 'p2',
    familyId: 'f1',
    displayName: 'Child',
    profileType: ProfileType.child,
    role: FamilyRole.child,
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

  group('SubscriptionScreen', () {
    testWidgets('renders Free Plan for free users', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            premiumTelemetryServiceProvider.overrideWithValue(mockTelemetry),
            subscriptionStreamProvider.overrideWith((ref) => Stream.value(Subscription.free())),
            premiumServiceProvider.overrideWithValue(PremiumService(Subscription.free())),
            activeProfileProvider.overrideWith((ref) => FakeActiveProfileNotifier(adultProfile)),
            availableProductsProvider.overrideWith((ref) => Future.value([mockProduct])),
          ],
          child: const MaterialApp(home: SubscriptionScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('HabitFlow Free'), findsOneWidget);
      expect(find.text('Free'), findsOneWidget);
      expect(find.text('Upgrade for \$4.99/mo'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsAtLeast(1));
    });

    testWidgets('renders Premium Plan for premium users', (tester) async {
      final premiumSubscription = Subscription(
        id: 'premium',
        status: SubscriptionStatus.premium,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            premiumTelemetryServiceProvider.overrideWithValue(mockTelemetry),
            subscriptionStreamProvider.overrideWith((ref) => Stream.value(premiumSubscription)),
            premiumServiceProvider.overrideWithValue(PremiumService(premiumSubscription)),
            activeProfileProvider.overrideWith((ref) => FakeActiveProfileNotifier(adultProfile)),
            availableProductsProvider.overrideWith((ref) => Future.value([mockProduct])),
          ],
          child: const MaterialApp(home: SubscriptionScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('HabitFlow Premium'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.textContaining('Upgrade for'), findsNothing);
      expect(find.textContaining('Renews on:'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsAtLeast(1));
    });

    testWidgets('renders "Ask a parent" for child profiles', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            premiumTelemetryServiceProvider.overrideWithValue(mockTelemetry),
            subscriptionStreamProvider.overrideWith((ref) => Stream.value(Subscription.free())),
            premiumServiceProvider.overrideWithValue(PremiumService(Subscription.free())),
            activeProfileProvider.overrideWith((ref) => FakeActiveProfileNotifier(childProfile)),
            availableProductsProvider.overrideWith((ref) => Future.value([mockProduct])),
          ],
          child: const MaterialApp(home: SubscriptionScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Upgrade for \$4.99/mo'), findsNothing);
      expect(find.text('Ask a parent to manage subscription settings.'), findsOneWidget);
      expect(find.text('Restore Purchases'), findsNothing);
    });

    testWidgets('renders Expired status', (tester) async {
      const expiredSubscription = Subscription(
        id: 'premium',
        status: SubscriptionStatus.expired,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            premiumTelemetryServiceProvider.overrideWithValue(mockTelemetry),
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
      expect(find.text('Upgrade for \$4.99/mo'), findsOneWidget);
    });

    testWidgets('renders Active (Cancelled) status', (tester) async {
      const cancelledSubscription = Subscription(
        id: 'premium',
        status: SubscriptionStatus.cancelled,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            premiumTelemetryServiceProvider.overrideWithValue(mockTelemetry),
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
      expect(find.text('Upgrade for \$4.99/mo'), findsOneWidget);
    });
  });

  group('Navigation', () {
    testWidgets('PremiumFeatureLockedView has button to view plans', (tester) async {
      final adultProfile = FamilyProfile(
        id: 'p1',
        familyId: 'f1',
        displayName: 'Adult',
        profileType: ProfileType.adult,
        role: FamilyRole.owner,
        requiresPin: false,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeProfileProvider.overrideWith((ref) => FakeActiveProfileNotifier(adultProfile)),
            premiumTelemetryServiceProvider.overrideWithValue(mockTelemetry),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PremiumFeatureLockedView(
                title: 'Locked Feature',
                message: 'This is premium only',
              ),
            ),
          ),
        ),
      );

      expect(find.text('View Premium Plans'), findsOneWidget);
    });
  });
}
