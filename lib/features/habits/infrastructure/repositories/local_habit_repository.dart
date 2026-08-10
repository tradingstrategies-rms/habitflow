import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/local_habit_datasource.dart';
import '../models/habit_model.dart';

class LocalHabitRepository implements HabitRepository {
  final LocalHabitDataSource _dataSource;
  final _habitController = StreamController<List<Habit>>.broadcast();

  LocalHabitRepository(this._dataSource) {
    debugPrint("Repository created: ${identityHashCode(this)}");
  }

  Future<void> _notifyChanges() async {
    final habits = await getAllHabits();
    debugPrint("LocalHabitRepository: watchHabits stream emitting ${habits.length} habits");
    _habitController.add(habits);
  }

  @override
  Future<void> createHabit(Habit habit) async {
    debugPrint("createHabit repository: ${identityHashCode(this)}");
    debugPrint("LocalHabitRepository: Repository called");
    debugPrint("LocalHabitRepository: Habit received: ${habit.title}");
    await _dataSource.addHabit(HabitModel.fromEntity(habit));
    await _notifyChanges();
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    await _dataSource.updateHabit(HabitModel.fromEntity(habit));
    await _notifyChanges();
  }

  @override
  Future<void> deleteHabit(String id) async {
    await _dataSource.deleteHabit(id);
    await _notifyChanges();
  }

  @override
  Future<void> archiveHabit(String id) async {
    final habit = await getHabitById(id);
    if (habit != null) {
      final archivedHabit = Habit(
        id: habit.id,
        userId: habit.userId,
        title: habit.title,
        description: habit.description,
        category: habit.category,
        icon: habit.icon,
        color: habit.color,
        priority: habit.priority,
        frequency: habit.frequency,
        targetValue: habit.targetValue,
        currentValue: habit.currentValue,
        unit: habit.unit,
        isArchived: true,
        isActive: habit.isActive,
        createdAt: habit.createdAt,
        updatedAt: DateTime.now(),
      );
      await updateHabit(archivedHabit);
    }
  }

  @override
  Future<void> restoreHabit(String id) async {
    final habit = await getHabitById(id);
    if (habit != null) {
      final restoredHabit = Habit(
        id: habit.id,
        userId: habit.userId,
        title: habit.title,
        description: habit.description,
        category: habit.category,
        icon: habit.icon,
        color: habit.color,
        priority: habit.priority,
        frequency: habit.frequency,
        targetValue: habit.targetValue,
        currentValue: habit.currentValue,
        unit: habit.unit,
        isArchived: false,
        isActive: habit.isActive,
        createdAt: habit.createdAt,
        updatedAt: DateTime.now(),
      );
      await updateHabit(restoredHabit);
    }
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    final models = await _dataSource.loadHabits();
    final model = models.cast<HabitModel?>().firstWhere((h) => h?.id == id, orElse: () => null);
    return model?.toEntity();
  }

  @override
  Future<List<Habit>> getAllHabits() async {
    final models = await _dataSource.loadHabits();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Habit>> getActiveHabits() async {
    final habits = await getAllHabits();
    return habits.where((h) => !h.isArchived && h.isActive).toList();
  }

  @override
  Future<List<Habit>> getArchivedHabits() async {
    final habits = await getAllHabits();
    return habits.where((h) => h.isArchived).toList();
  }

  @override
  Future<List<Habit>> getTodayHabits() async {
    final habits = await getActiveHabits();
    return habits; // TODO: Filter by frequency
  }

  @override
  Stream<List<Habit>> watchHabits() {
    debugPrint("watchHabits repository: ${identityHashCode(this)}");
    debugPrint("LocalHabitRepository: watchHabits stream connected");
    // Ensure the stream emits the current state immediately upon subscription
    getAllHabits().then((habits) {
      if (!_habitController.isClosed) {
        _habitController.add(habits);
      }
    });
    return _habitController.stream;
  }

  void dispose() {
    _habitController.close();
  }
}
