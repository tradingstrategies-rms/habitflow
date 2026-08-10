import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reward_account_model.dart';
import '../models/reward_transaction_model.dart';

abstract class RewardsLocalDatasource {
  Future<RewardAccountModel?> getAccount(String profileId);
  Future<void> saveAccount(RewardAccountModel account);
  Future<List<RewardTransactionModel>> getTransactions(String profileId);
  Future<void> addTransaction(RewardTransactionModel transaction);
}

class RewardsLocalDatasourceImpl implements RewardsLocalDatasource {
  final SharedPreferences _prefs;
  static const String _accountsKey = 'rewards_accounts';
  static const String _transactionsKey = 'rewards_transactions';

  RewardsLocalDatasourceImpl(this._prefs);

  @override
  Future<RewardAccountModel?> getAccount(String profileId) async {
    final accounts = await _getAllAccounts();
    try {
      return accounts.firstWhere((a) => a.profileId == profileId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveAccount(RewardAccountModel account) async {
    final accounts = await _getAllAccounts();
    final index = accounts.indexWhere((a) => a.profileId == account.profileId);
    if (index != -1) {
      accounts[index] = account;
    } else {
      accounts.add(account);
    }
    await _saveAllAccounts(accounts);
  }

  @override
  Future<List<RewardTransactionModel>> getTransactions(String profileId) async {
    final transactions = await _getAllTransactions();
    return transactions.where((t) => t.profileId == profileId).toList();
  }

  @override
  Future<void> addTransaction(RewardTransactionModel transaction) async {
    final transactions = await _getAllTransactions();
    transactions.add(transaction);
    await _saveAllTransactions(transactions);
  }

  Future<List<RewardAccountModel>> _getAllAccounts() async {
    final jsonString = _prefs.getString(_accountsKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((j) => RewardAccountModel.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAllAccounts(List<RewardAccountModel> accounts) async {
    final jsonList = accounts.map((a) => a.toJson()).toList();
    await _prefs.setString(_accountsKey, json.encode(jsonList));
  }

  Future<List<RewardTransactionModel>> _getAllTransactions() async {
    final jsonString = _prefs.getString(_transactionsKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((j) => RewardTransactionModel.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAllTransactions(List<RewardTransactionModel> transactions) async {
    final jsonList = transactions.map((t) => t.toJson()).toList();
    await _prefs.setString(_transactionsKey, json.encode(jsonList));
  }
}
