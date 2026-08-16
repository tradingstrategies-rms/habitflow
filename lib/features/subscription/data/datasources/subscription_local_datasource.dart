import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_model.dart';

abstract class SubscriptionLocalDatasource {
  Future<SubscriptionModel?> getSubscription();
  Future<void> saveSubscription(SubscriptionModel subscription);
  Future<void> clearSubscription();
}

class SubscriptionLocalDatasourceImpl implements SubscriptionLocalDatasource {
  final SharedPreferences _prefs;
  static const _key = 'hf_subscription';

  SubscriptionLocalDatasourceImpl(this._prefs);

  @override
  Future<SubscriptionModel?> getSubscription() async {
    final jsonString = _prefs.getString(_key);
    if (jsonString == null) return null;
    return SubscriptionModel.fromJson(json.decode(jsonString));
  }

  @override
  Future<void> saveSubscription(SubscriptionModel subscription) async {
    await _prefs.setString(_key, json.encode(subscription.toJson()));
  }

  @override
  Future<void> clearSubscription() async {
    await _prefs.remove(_key);
  }
}
