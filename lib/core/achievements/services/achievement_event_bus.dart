import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../events/goal_completed_event.dart';

/// [AchievementEventBus] handles the publishing and subscription of achievement-related events.
/// It also manages the persistence of acknowledged achievements to prevent duplicate celebrations.
class AchievementEventBus {
  final SharedPreferences _prefs;
  final _eventController = StreamController<GoalCompletedEvent>.broadcast();

  static const String _storageKey = 'habitflow_achievements_v1';

  AchievementEventBus(this._prefs);

  /// Stream of [GoalCompletedEvent] for UI consumption.
  Stream<GoalCompletedEvent> get onGoalCompleted => _eventController.stream;

  /// Publishes a [GoalCompletedEvent] if it hasn't been acknowledged yet.
  Future<void> publishGoalCompleted(GoalCompletedEvent event) async {
    if (await isAcknowledged(event.goalId)) {
      return;
    }
    _eventController.add(event);
  }

  /// Marks a goal achievement as acknowledged.
  Future<void> acknowledge(String goalId) async {
    final Map<String, String> acknowledged = await _loadAcknowledged();
    acknowledged[goalId] = DateTime.now().toIso8601String();
    await _prefs.setString(_storageKey, json.encode(acknowledged));
  }

  /// Checks if a goal achievement has already been acknowledged.
  Future<bool> isAcknowledged(String goalId) async {
    final acknowledged = await _loadAcknowledged();
    return acknowledged.containsKey(goalId);
  }

  Future<Map<String, String>> _loadAcknowledged() async {
    final String? jsonString = _prefs.getString(_storageKey);
    if (jsonString == null) return {};
    try {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }

  void dispose() {
    _eventController.close();
  }
}
