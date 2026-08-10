import 'dart:async';
import '../../domain/entities/habit_completion.dart';
import '../../domain/repositories/habit_completion_repository.dart';
import '../datasources/local_habit_datasource.dart';
import '../models/habit_completion_model.dart';

class LocalHabitCompletionRepository implements HabitCompletionRepository {
  final LocalHabitDataSource _dataSource;
  final _completionController = StreamController<List<HabitCompletion>>.broadcast();

  LocalHabitCompletionRepository(this._dataSource);

  @override
  Future<void> saveCompletion(HabitCompletion completion) async {
    final completions = await _dataSource.loadCompletions();
    completions.add(HabitCompletionModel.fromEntity(completion));
    await _dataSource.saveCompletions(completions);
    _notifyChanges(completion.habitId);
  }

  @override
  Future<void> removeCompletion(String habitId, DateTime date, {String? profileId}) async {
    final completions = await _dataSource.loadCompletions();
    completions.removeWhere((c) {
      final cDate = DateTime.parse(c.completionDate);
      return c.habitId == habitId &&
          (profileId == null || c.profileId == profileId) &&
          cDate.year == date.year &&
          cDate.month == date.month &&
          cDate.day == date.day;
    });
    await _dataSource.saveCompletions(completions);
    _notifyChanges(habitId);
  }

  @override
  Future<HabitCompletion?> getTodayCompletion(String habitId, {String? profileId}) async {
    final completions = await getCompletionsForHabit(habitId, profileId: profileId);
    final today = DateTime.now();
    for (final completion in completions) {
      if (completion.completionDate.year == today.year &&
          completion.completionDate.month == today.month &&
          completion.completionDate.day == today.day) {
        return completion;
      }
    }
    return null;
  }

  @override
  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId, {String? profileId}) async {
    final completions = await getAllCompletions();
    return completions.where((c) => 
      c.habitId == habitId && (profileId == null || c.profileId == profileId)
    ).toList();
  }

  @override
  Future<List<HabitCompletion>> getAllCompletions() async {
    final models = await _dataSource.loadCompletions();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<List<HabitCompletion>> watchCompletions(String habitId, {String? profileId}) {
    _notifyChanges(habitId);
    return _completionController.stream.map(
      (list) => list.where((c) => 
        c.habitId == habitId && (profileId == null || c.profileId == profileId)
      ).toList(),
    );
  }

  @override
  Stream<List<HabitCompletion>> watchAllCompletions() {
    _notifyChanges('');
    return _completionController.stream;
  }

  Future<void> _notifyChanges(String habitId) async {
    final completions = await getAllCompletions();
    _completionController.add(completions);
  }

  void dispose() {
    _completionController.close();
  }
}
