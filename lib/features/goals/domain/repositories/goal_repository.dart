import '../entities/goal.dart';

/// Repository interface for Goal operations.
abstract class GoalRepository {
  /// Fetches all goals from the data source.
  Future<List<Goal>> getGoals();

  /// Fetches a single goal by its [id].
  Future<Goal?> getGoalById(String id);

  /// Saves a new goal to the data source.
  Future<void> saveGoal(Goal goal);

  /// Updates an existing goal in the data source.
  Future<void> updateGoal(Goal goal);

  /// Deletes a goal by its [id].
  Future<void> deleteGoal(String id);

  /// Moves a goal to the archive by its [id].
  Future<void> archiveGoal(String id);

  /// Restores an archived goal by its [id].
  Future<void> restoreGoal(String id);
}
