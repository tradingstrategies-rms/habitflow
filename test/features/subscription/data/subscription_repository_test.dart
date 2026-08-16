import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitflow/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:habitflow/features/subscription/data/datasources/subscription_local_datasource.dart';
import 'package:habitflow/features/subscription/domain/entities/subscription.dart';
import 'package:habitflow/features/subscription/domain/enums/subscription_status.dart';

void main() {
  late SubscriptionRepositoryImpl repository;
  late SubscriptionLocalDatasource datasource;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    datasource = SubscriptionLocalDatasourceImpl(prefs);
    repository = SubscriptionRepositoryImpl(datasource);
  });

  group('SubscriptionRepositoryImpl', () {
    test('getSubscription should return free subscription initially', () async {
      final sub = await repository.getSubscription();
      expect(sub.status, SubscriptionStatus.free);
    });

    test('setSubscription should persist and broadcast changes', () async {
      const premium = Subscription(
        id: 'premium_1',
        status: SubscriptionStatus.premium,
        entitlements: ['all'],
      );

      final stream = repository.watchSubscription();
      
      await repository.setSubscription(premium);
      
      final sub = await repository.getSubscription();
      expect(sub, equals(premium));
      
      expect(await stream.first, equals(premium));
    });

    test('resetSubscription should clear data', () async {
      const premium = Subscription(
        id: 'premium_1',
        status: SubscriptionStatus.premium,
      );
      await repository.setSubscription(premium);
      
      await repository.resetSubscription();
      
      final sub = await repository.getSubscription();
      expect(sub.status, SubscriptionStatus.free);
    });
  });
}
