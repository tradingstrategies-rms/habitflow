import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_local_datasource.dart';
import '../models/goal_model.dart';

/// Implementation of [GoalRepository] that handles persistence via [GoalLocalDataSource].
class GoalRepositoryImpl implements GoalRepository {
  final GoalLocalDataSource _localDataSource;

  GoalRepositoryImpl(this._localDataSource);

  @override
  Future<List<Goal>> getGoals() async {
    final List<GoalModel> models = await _localDataSource.readGoals();
    return models.map((model) => model.toDomain()).toList();
  }

  @override
  Future<Goal?> getGoalById(String id) async {
    final List<GoalModel> models = await _localDataSource.readGoals();
    for (final model in models) {
      if (model.id == id) {
        return model.toDomain();
      }
    }
    return null;
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    final List<GoalModel> models = await _localDataSource.readGoals();
    models.add(GoalModel.fromDomain(goal));
    await _localDataSource.writeGoals(models);
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    final List<GoalModel> models = await _localDataSource.readGoals();
    final int index = models.indexWhere((m) => m.id == goal.id);
    if (index != -1) {
      models[index] = GoalModel.fromDomain(goal);
      await _localDataSource.writeGoals(models);
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _localDataSource.deleteGoal(id);
  }

  @override
  Future<void> archiveGoal(String id) async {
    await _localDataSource.archiveGoal(id);
  }

  @override
  Future<void> restoreGoal(String id) async {
    await _localDataSource.restoreGoal(id);
  }
}
