import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reward_item_model.dart';
import '../models/reward_redemption_model.dart';

abstract class RewardStoreLocalDatasource {
  Future<List<RewardItemModel>> getItems();
  Future<void> saveItem(RewardItemModel item);
  Future<List<RewardRedemptionModel>> getRedemptions();
  Future<void> saveRedemption(RewardRedemptionModel redemption);
}

class RewardStoreLocalDatasourceImpl implements RewardStoreLocalDatasource {
  final SharedPreferences _prefs;
  static const String _itemsKey = 'reward_store_items';
  static const String _redemptionsKey = 'reward_store_redemptions';

  RewardStoreLocalDatasourceImpl(this._prefs);

  @override
  Future<List<RewardItemModel>> getItems() async {
    final jsonString = _prefs.getString(_itemsKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((j) => RewardItemModel.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveItem(RewardItemModel item) async {
    final items = await getItems();
    final index = items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      items[index] = item;
    } else {
      items.add(item);
    }
    await _saveAllItems(items);
  }

  @override
  Future<List<RewardRedemptionModel>> getRedemptions() async {
    final jsonString = _prefs.getString(_redemptionsKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((j) => RewardRedemptionModel.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveRedemption(RewardRedemptionModel redemption) async {
    final redemptions = await getRedemptions();
    final index = redemptions.indexWhere((r) => r.id == redemption.id);
    if (index != -1) {
      redemptions[index] = redemption;
    } else {
      redemptions.add(redemption);
    }
    await _saveAllRedemptions(redemptions);
  }

  Future<void> _saveAllItems(List<RewardItemModel> items) async {
    final jsonList = items.map((i) => i.toJson()).toList();
    await _prefs.setString(_itemsKey, json.encode(jsonList));
  }

  Future<void> _saveAllRedemptions(List<RewardRedemptionModel> redemptions) async {
    final jsonList = redemptions.map((r) => r.toJson()).toList();
    await _prefs.setString(_redemptionsKey, json.encode(jsonList));
  }
}
