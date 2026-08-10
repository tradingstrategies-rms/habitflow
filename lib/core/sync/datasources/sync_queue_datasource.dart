import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sync_operation.dart';

abstract class SyncQueueDataSource {
  Future<List<SyncOperation>> getQueue(String userId);
  Future<void> addToQueue(String userId, SyncOperation operation);
  Future<void> removeFromQueue(String userId, String operationId);
  Future<void> updateOperation(String userId, SyncOperation operation);
}

class SyncQueueDataSourceImpl implements SyncQueueDataSource {
  final SharedPreferences _prefs;
  final Map<String, List<SyncOperation>> _cache = {};

  SyncQueueDataSourceImpl(this._prefs);

  String _getQueueKey(String userId) => 'sync_queue_$userId';

  @override
  Future<List<SyncOperation>> getQueue(String userId) async {
    if (_cache.containsKey(userId)) {
      return List.from(_cache[userId]!);
    }

    final jsonString = _prefs.getString(_getQueueKey(userId));
    if (jsonString == null) {
      _cache[userId] = [];
      return [];
    }
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      final queue = jsonList.map((j) => SyncOperation.fromJson(j)).toList();
      _cache[userId] = queue;
      return List.from(queue);
    } catch (_) {
      _cache[userId] = [];
      return [];
    }
  }

  @override
  Future<void> addToQueue(String userId, SyncOperation operation) async {
    final queue = await getQueue(userId);
    queue.add(operation);
    _cache[userId] = queue;
    await _saveQueue(userId, queue);
  }

  @override
  Future<void> removeFromQueue(String userId, String operationId) async {
    final queue = await getQueue(userId);
    queue.removeWhere((o) => o.id == operationId);
    _cache[userId] = queue;
    await _saveQueue(userId, queue);
  }

  @override
  Future<void> updateOperation(String userId, SyncOperation operation) async {
    final queue = await getQueue(userId);
    final index = queue.indexWhere((o) => o.id == operation.id);
    if (index != -1) {
      queue[index] = operation;
      _cache[userId] = queue;
      await _saveQueue(userId, queue);
    }
  }

  Future<void> _saveQueue(String userId, List<SyncOperation> queue) async {
    final jsonList = queue.map((o) => o.toJson()).toList();
    await _prefs.setString(_getQueueKey(userId), json.encode(jsonList));
  }
}
