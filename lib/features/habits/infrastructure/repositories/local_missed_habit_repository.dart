import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/missed_habit_event.dart';
import '../../domain/repositories/missed_habit_repository.dart';
import '../models/missed_habit_event_model.dart';

/// [LocalMissedHabitRepository] implements [MissedHabitRepository] using SharedPreferences.
class LocalMissedHabitRepository implements MissedHabitRepository {
  final SharedPreferences _prefs;
  static const String _storageKey = 'habitflow_missed_events_v1';

  LocalMissedHabitRepository(this._prefs);

  @override
  Future<void> saveEvent(MissedHabitEvent event) async {
    final events = await getEvents();
    // Prevent duplicates for the same habit at the same scheduled time
    final index = events.indexWhere((e) => 
      e.habitId == event.habitId && 
      e.scheduledTime == event.scheduledTime
    );

    if (index != -1) {
      events[index] = event;
    } else {
      events.add(event);
    }

    await _saveAll(events);
  }

  @override
  Future<List<MissedHabitEvent>> getEvents() async {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((item) => MissedHabitEventModel.fromJson(item as Map<String, dynamic>).toEntity())
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<MissedHabitEvent>> getEventsForHabit(String habitId) async {
    final events = await getEvents();
    return events.where((e) => e.habitId == habitId).toList();
  }

  @override
  Future<void> acknowledgeEvent(String habitId, DateTime scheduledTime) async {
    final events = await getEvents();
    final index = events.indexWhere((e) => 
      e.habitId == habitId && 
      e.scheduledTime == scheduledTime
    );

    if (index != -1) {
      events[index] = events[index].copyWith(acknowledged: true);
      await _saveAll(events);
    }
  }

  @override
  Future<void> deleteEvent(String habitId, DateTime scheduledTime) async {
    final events = await getEvents();
    events.removeWhere((e) => 
      e.habitId == habitId && 
      e.scheduledTime == scheduledTime
    );
    await _saveAll(events);
  }

  Future<void> _saveAll(List<MissedHabitEvent> events) async {
    final jsonString = json.encode(
      events.map((e) => MissedHabitEventModel.fromEntity(e).toJson()).toList(),
    );
    await _prefs.setString(_storageKey, jsonString);
  }
}
