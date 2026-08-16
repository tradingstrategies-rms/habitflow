import 'dart:async';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_local_datasource.dart';
import '../models/subscription_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDatasource _datasource;
  final _controller = StreamController<Subscription>.broadcast();

  SubscriptionRepositoryImpl(this._datasource);

  @override
  Future<Subscription> getSubscription() async {
    final model = await _datasource.getSubscription();
    final subscription = model ?? Subscription.free();
    _controller.add(subscription);
    return subscription;
  }

  @override
  Future<void> setSubscription(Subscription subscription) async {
    await _datasource.saveSubscription(SubscriptionModel.fromEntity(subscription));
    _controller.add(subscription);
  }

  @override
  Future<void> resetSubscription() async {
    await _datasource.clearSubscription();
    final free = Subscription.free();
    _controller.add(free);
  }

  @override
  Stream<Subscription> watchSubscription() async* {
    yield await getSubscription();
    yield* _controller.stream;
  }
}
