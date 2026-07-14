import '../../domain/repositories/completion_repository.dart';
import '../../domain/models/habit_id.dart';
import '../../domain/models/completion/habit_completion.dart';
import '../../domain/models/completion/completion_summary.dart';
import '../../domain/models/completion/streak_calculator.dart';
import '../../../../core/services/storage/storage_service.dart';
import 'dart:convert';

class CompletionRepositoryImpl implements CompletionRepository {
  CompletionRepositoryImpl(this._storage);
  final StorageService _storage;
  static const _key = 'habit_completions';

  @override
  Future<void> markComplete(HabitId habitId, DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final completions = await _load();
    if (completions.any((c) => c.habitId.value == habitId.value && 
        c.date.year == normalizedDate.year && 
        c.date.month == normalizedDate.month && 
        c.date.day == normalizedDate.day)) return;

    completions.add(HabitCompletion(id: DateTime.now().toIso8601String(), habitId: habitId, date: normalizedDate));
    await _save(completions);
  }

  @override
  Future<void> undoCompletion(HabitId habitId, DateTime date) async {
    final completions = await _load();
    completions.removeWhere((c) => c.habitId.value == habitId.value && 
        c.date.year == date.year && 
        c.date.month == date.month && 
        c.date.day == date.day);
    await _save(completions);
  }

  @override
  Future<List<HabitCompletion>> getCompletionHistory(HabitId habitId) async {
    final completions = await _load();
    return completions.where((c) => c.habitId.value == habitId.value).toList();
  }

  @override
  Future<CompletionSummary> getCompletionSummary(HabitId habitId) async {
    final history = await getCompletionHistory(habitId);
    // Simple implementation of longest streak for MVP
    final currentStreak = StreakCalculator.calculateCurrentStreak(history, DateTime.now());
    
    return CompletionSummary(
      currentStreak: currentStreak,
      longestStreak: currentStreak, // Placeholder: need to iterate gaps to calculate
      totalCompletions: history.length,
      lastCompletionDate: history.isNotEmpty ? history.map((c) => c.date).reduce((a, b) => a.isAfter(b) ? a : b) : null,
    );
  }

  Future<List<HabitCompletion>> _load() async {
    final data = await _storage.read(_key);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((j) => HabitCompletion(id: j['id'], habitId: HabitId(j['habitId']), date: DateTime.parse(j['date']))).toList();
  }

  Future<void> _save(List<HabitCompletion> completions) async {
    final data = jsonEncode(completions.map((c) => {'id': c.id, 'habitId': c.habitId.value, 'date': c.date.toIso8601String()}).toList());
    await _storage.write(_key, data);
  }
}
