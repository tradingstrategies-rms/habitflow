import '../../domain/entities/habit_consistency_score.dart';
import '../../domain/entities/habit_insight.dart';
import '../../domain/entities/habit_recommendation.dart';
import '../../domain/repositories/intelligence_repository.dart';

class IntelligenceRepositoryImpl implements IntelligenceRepository {
  @override
  Future<HabitConsistencyScore?> getConsistencyScore(String habitId) async {
    return null;
  }

  @override
  Future<List<HabitInsight>> getInsights(String habitId) async {
    return const [];
  }

  @override
  Future<List<HabitRecommendation>> getRecommendations(String habitId) async {
    return const [];
  }

  @override
  Future<void> saveConsistencyScore(HabitConsistencyScore score) async {
    // Implementation will be added in future sprints
  }

  @override
  Future<void> saveInsight(HabitInsight insight) async {
    // Implementation will be added in future sprints
  }

  @override
  Future<void> saveRecommendation(HabitRecommendation recommendation) async {
    // Implementation will be added in future sprints
  }
}
