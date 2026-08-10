import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal_model.dart';

/// Data source for local persistence of goals using [SharedPreferences].
class GoalLocalDataSource {
  final SharedPreferences _prefs;
  static const String _storageKey = 'habitflow_goals_v1';

  GoalLocalDataSource(this._prefs);

  /// Reads all goals from local storage.
  /// Returns an empty list if no goals are found or if data is corrupted.
  Future<List<GoalModel>> readGoals() async {
    final String? jsonString = _prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((item) => GoalModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Gracefully handle corrupted JSON
      return [];
    }
  }

  /// Writes the complete list of [goals] to local storage.
  Future<void> writeGoals(List<GoalModel> goals) async {
    final String jsonString = json.encode(
      goals.map((goal) => goal.toJson()).toList(),
    );
    await _prefs.setString(_storageKey, jsonString);
  }

  /// Deletes a goal by its [id].
  Future<void> deleteGoal(String id) async {
    final List<GoalModel> goals = await readGoals();
    goals.removeWhere((goal) => goal.id == id);
    await writeGoals(goals);
  }

  /// Updates the status of a goal to 'archived'.
  Future<void> archiveGoal(String id) async {
    final List<GoalModel> goals = await readGoals();
    final int index = goals.indexWhere((goal) => goal.id == id);
    if (index != -1) {
      final GoalModel goal = goals[index];
      goals[index] = GoalModel(
        id: goal.id,
        title: goal.title,
        description: goal.description,
        habitIds: goal.habitIds,
        type: goal.type,
        scope: goal.scope,
        status: 'archived',
        targetValue: goal.targetValue,
        createdAt: goal.createdAt,
        startDate: goal.startDate,
        endDate: goal.endDate,
        colorValue: goal.colorValue,
        iconName: goal.iconName,
      );
      await writeGoals(goals);
    }
  }

  /// Updates the status of a goal to 'active'.
  Future<void> restoreGoal(String id) async {
    final List<GoalModel> goals = await readGoals();
    final int index = goals.indexWhere((goal) => goal.id == id);
    if (index != -1) {
      final GoalModel goal = goals[index];
      goals[index] = GoalModel(
        id: goal.id,
        title: goal.title,
        description: goal.description,
        habitIds: goal.habitIds,
        type: goal.type,
        scope: goal.scope,
        status: 'active',
        targetValue: goal.targetValue,
        createdAt: goal.createdAt,
        startDate: goal.startDate,
        endDate: goal.endDate,
        colorValue: goal.colorValue,
        iconName: goal.iconName,
      );
      await writeGoals(goals);
    }
  }
}
