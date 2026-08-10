import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/enums/goal_status.dart';
import '../state/goal_state.dart';

/// [GoalController] manages the state of goals and coordinates repository operations.
class GoalController extends StateNotifier<GoalState> {
  final GoalRepository _repository;

  GoalController(this._repository) : super(const GoalState()) {
    loadGoals();
  }

  /// Loads all goals from the repository and updates the state.
  Future<void> loadGoals() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final goals = await _repository.getGoals();
      _updateGoalsState(goals);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load goals: ${e.toString()}',
      );
    }
  }

  /// Refreshes the goals list.
  Future<void> refresh() => loadGoals();

  /// Creates a new goal.
  Future<void> createGoal(Goal goal) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.saveGoal(goal);
      await loadGoals();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create goal: ${e.toString()}',
      );
    }
  }

  /// Updates an existing goal.
  Future<void> updateGoal(Goal goal) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.updateGoal(goal);
      await loadGoals();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update goal: ${e.toString()}',
      );
    }
  }

  /// Deletes a goal by its ID.
  Future<void> deleteGoal(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.deleteGoal(id);
      await loadGoals();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete goal: ${e.toString()}',
      );
    }
  }

  /// Archives a goal by its ID.
  Future<void> archiveGoal(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.archiveGoal(id);
      await loadGoals();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to archive goal: ${e.toString()}',
      );
    }
  }

  /// Restores an archived goal by its ID.
  Future<void> restoreGoal(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.restoreGoal(id);
      await loadGoals();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to restore goal: ${e.toString()}',
      );
    }
  }

  /// Sets the currently selected goal.
  void selectGoal(Goal? goal) {
    state = state.copyWith(selectedGoal: goal);
  }

  /// Helper to filter and update the state with a new list of goals.
  void _updateGoalsState(List<Goal> goals) {
    state = state.copyWith(
      goals: goals,
      activeGoals: goals.where((g) => g.status == GoalStatus.active).toList(),
      archivedGoals: goals.where((g) => g.status == GoalStatus.archived).toList(),
      completedGoals: goals.where((g) => g.status == GoalStatus.completed).toList(),
      isLoading: false,
    );
  }
}
