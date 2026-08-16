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
import 'package:habitflow/features/subscription/domain/enums/entitlement_type.dart';
import 'package:habitflow/features/subscription/presentation/screens/subscription_screen.dart';
import 'package:habitflow/features/subscription/presentation/widgets/premium_feature_locked_view.dart';
import 'package:habitflow/features/billing/domain/entities/premium_event_type.dart';
import 'package:habitflow/features/billing/domain/entities/premium_telemetry_event.dart';
import 'package:habitflow/features/billing/application/providers/telemetry_providers.dart';
import 'package:habitflow/features/billing/domain/entities/premium_conversion_metrics.dart';
import 'package:habitflow/features/billing/domain/repositories/premium_telemetry_service.dart';
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
    createdAt: DateTime(2024),
  );

  const mockProduct = BillingProduct(
    id: 'hf_premium_monthly',
    name: 'Premium',
    description: 'Desc',
    price: 4.99,
    currencyCode: 'USD',
    formattedPrice: '\$4.99/mo',
  );

  group('Premium Upgrade UX', () {
    testWidgets('SubscriptionScreen shows specific benefit descriptions', (tester) async {
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

      expect(find.text('Advanced Analytics'), findsOneWidget);
      expect(find.textContaining('Deep dive into your habit patterns'), findsOneWidget);
      expect(find.text('Premium Challenges'), findsOneWidget);
    });

    testWidgets('PremiumFeatureLockedView shows feature-specific entitlement description', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeProfileProvider.overrideWith((ref) => FakeActiveProfileNotifier(adultProfile)),
            premiumTelemetryServiceProvider.overrideWithValue(mockTelemetry),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PremiumFeatureLockedView(
                title: 'Locked Analytics',
                message: 'Unlock this feature',
                entitlement: EntitlementType.advancedAnalytics,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Locked Analytics'), findsOneWidget);
      expect(find.textContaining('Deep dive into your habit patterns'), findsOneWidget);
      expect(find.byIcon(Icons.insights_rounded), findsOneWidget);
    });

    testWidgets('Children see "Ask a parent" and no pricing', (tester) async {
      final childProfile = FamilyProfile(
        id: 'p2',
        familyId: 'f1',
        displayName: 'Child',
        profileType: ProfileType.child,
        role: FamilyRole.child,
        requiresPin: false,
        createdAt: DateTime.now(),
      );

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

      expect(find.textContaining('\$4.99'), findsNothing);
      expect(find.text('Ask a parent to manage subscription settings.'), findsOneWidget);
    });
  });
}
