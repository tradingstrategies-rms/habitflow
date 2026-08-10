import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit_model.dart';
import '../models/habit_completion_model.dart';

class LocalHabitDataSource {
  final SharedPreferences _prefs;
  
  static const String _storageKey = 'habitflow_habits_v1';

  LocalHabitDataSource(this._prefs);

  Future<List<HabitModel>> loadHabits() async {
    final String? jsonString = _prefs.getString(_storageKey);
    if (jsonString == null) {
      debugPrint("LocalHabitDataSource: 0 habits loaded");
      return [];
    }
    
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      final habits = jsonList.map((item) => HabitModel.fromJson(item as Map<String, dynamic>)).toList();
      debugPrint("LocalHabitDataSource: ${habits.length} habits loaded");
      return habits;
    } catch (e) {
      throw FormatException('Failed to deserialize habits: $e');
    }
  }

  Future<void> saveHabits(List<HabitModel> habits) async {
    final String jsonString = json.encode(habits.map((h) => h.toJson()).toList());
    await _prefs.setString(_storageKey, jsonString);
  }

  Future<void> addHabit(HabitModel habit) async {
    final habits = await loadHabits();
    debugPrint("LocalHabitDataSource: Existing habit count: ${habits.length}");
    habits.add(habit);
    debugPrint("LocalHabitDataSource: New habit count: ${habits.length}");
    final String jsonString = json.encode(habits.map((h) => h.toJson()).toList());
    debugPrint("LocalHabitDataSource: JSON saved: $jsonString");
    await saveHabits(habits);
  }

  Future<void> updateHabit(HabitModel habit) async {
    final habits = await loadHabits();
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      habits[index] = habit;
      await saveHabits(habits);
    }
  }

  Future<void> deleteHabit(String id) async {
    final habits = await loadHabits();
    habits.removeWhere((h) => h.id == id);
    await saveHabits(habits);
  }

  Future<void> clearHabits() async {
    await _prefs.remove(_storageKey);
    await _prefs.remove(_completionStorageKey);
  }

  // --- Completions ---

  static const String _completionStorageKey = 'habitflow_habit_completions_v1';

  Future<List<HabitCompletionModel>> loadCompletions() async {
    final String? jsonString = _prefs.getString(_completionStorageKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((item) => HabitCompletionModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> saveCompletions(List<HabitCompletionModel> completions) async {
    final String jsonString = json.encode(completions.map((c) => c.toJson()).toList());
    await _prefs.setString(_completionStorageKey, jsonString);
  }
}
