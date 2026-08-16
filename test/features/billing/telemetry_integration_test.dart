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
import 'package:habitflow/features/billing/application/providers/billing_providers.dart';
import 'package:habitflow/features/billing/application/providers/telemetry_providers.dart';
import 'package:habitflow/features/billing/domain/entities/billing_product.dart';
import 'package:habitflow/features/billing/domain/entities/purchase_result.dart';
import 'package:habitflow/features/billing/domain/entities/premium_event_type.dart';
import 'package:habitflow/features/billing/domain/entities/premium_telemetry_event.dart';
import 'package:habitflow/features/billing/domain/entities/premium_conversion_metrics.dart';
import 'package:habitflow/features/billing/domain/repositories/billing_service.dart';
import 'package:habitflow/features/billing/domain/repositories/premium_telemetry_service.dart';
import 'package:habitflow/features/subscription/presentation/screens/subscription_screen.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';

class MockRef extends Mock implements Ref {}
class MockBillingService extends Mock implements BillingService {}
class MockTelemetryService extends Mock implements PremiumTelemetryService {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

class FakeActiveProfileNotifier extends ActiveProfileNotifier {
  FakeActiveProfileNotifier(FamilyProfile? initial) : super(MockRef()) {
    state = initial;
  }
}

void main() {
  late MockBillingService mockBillingService;
  late MockTelemetryService mockTelemetryService;
  late MockSharedPreferences mockPrefs;

  setUpAll(() {
    registerFallbackValue(MockRef());
    registerFallbackValue(const PurchaseResult(status: PurchaseStatus.success));
    registerFallbackValue(PremiumTelemetryEvent(
      type: PremiumEventType.subscriptionScreenViewed,
      timestamp: DateTime.now(),
    ));
  });

  setUp(() {
    mockBillingService = MockBillingService();
    mockTelemetryService = MockTelemetryService();
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.getStringList(any())).thenReturn([]);
    when(() => mockPrefs.setStringList(any(), any())).thenAnswer((_) async => true);
    when(() => mockTelemetryService.recordEvent(any())).thenAnswer((_) async => {});
    when(() => mockTelemetryService.getMetrics()).thenAnswer((_) async => PremiumConversionMetrics.empty());
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

  final mockProduct = const BillingProduct(
    id: 'hf_premium_monthly',
    name: 'Premium',
    description: 'Desc',
    price: 4.99,
    currencyCode: 'USD',
    formattedPrice: '\$4.99/mo',
  );

  testWidgets('SubscriptionScreen records view event', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          premiumTelemetryServiceProvider.overrideWithValue(mockTelemetryService),
          subscriptionStreamProvider.overrideWith((ref) => Stream.value(Subscription.free())),
          premiumServiceProvider.overrideWithValue(PremiumService(Subscription.free())),
          activeProfileProvider.overrideWith((ref) => FakeActiveProfileNotifier(adultProfile)),
          availableProductsProvider.overrideWith((ref) => Future.value([mockProduct])),
        ],
        child: const MaterialApp(home: SubscriptionScreen()),
      ),
    );

    await tester.pumpAndSettle();

    verify(() => mockTelemetryService.recordEvent(any(that: predicate((e) => (e as PremiumTelemetryEvent).type == PremiumEventType.subscriptionScreenViewed)))).called(1);
  });

  testWidgets('Purchase records started and succeeded events', (tester) async {
    when(() => mockBillingService.getProducts()).thenAnswer((_) async => [mockProduct]);
    when(() => mockBillingService.purchase(any()))
        .thenAnswer((_) async => const PurchaseResult(status: PurchaseStatus.success));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          billingServiceProvider.overrideWithValue(mockBillingService),
          premiumTelemetryServiceProvider.overrideWithValue(mockTelemetryService),
          subscriptionStreamProvider.overrideWith((ref) => Stream.value(Subscription.free())),
          premiumServiceProvider.overrideWithValue(PremiumService(Subscription.free())),
          activeProfileProvider.overrideWith((ref) => FakeActiveProfileNotifier(adultProfile)),
          availableProductsProvider.overrideWith((ref) => Future.value([mockProduct])),
        ],
        child: const MaterialApp(home: SubscriptionScreen()),
      ),
    );

    await tester.pumpAndSettle();

    final upgradeButton = find.text('Upgrade for \$4.99/mo');
    await tester.ensureVisible(upgradeButton);
    await tester.tap(upgradeButton);
    await tester.pumpAndSettle();

    verify(() => mockTelemetryService.recordEvent(any(that: predicate((e) => (e as PremiumTelemetryEvent).type == PremiumEventType.upgradeStarted)))).called(1);
    verify(() => mockTelemetryService.recordEvent(any(that: predicate((e) => (e as PremiumTelemetryEvent).type == PremiumEventType.purchaseSucceeded)))).called(1);
    verify(() => mockTelemetryService.recordEvent(any(that: predicate((e) => (e as PremiumTelemetryEvent).type == PremiumEventType.premiumActivated)))).called(1);
  });
}
