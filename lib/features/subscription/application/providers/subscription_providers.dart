import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../data/datasources/subscription_local_datasource.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/entities/subscription.dart';
import '../services/premium_service.dart';

final subscriptionLocalDatasourceProvider = Provider<SubscriptionLocalDatasource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SubscriptionLocalDatasourceImpl(prefs);
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final datasource = ref.watch(subscriptionLocalDatasourceProvider);
  return SubscriptionRepositoryImpl(datasource);
});

final subscriptionStreamProvider = StreamProvider<Subscription>((ref) {
  return ref.watch(subscriptionRepositoryProvider).watchSubscription();
});

final premiumServiceProvider = Provider<PremiumService>((ref) {
  final subscription = ref.watch(subscriptionStreamProvider).value ?? Subscription.free();
  return PremiumService(subscription);
});
