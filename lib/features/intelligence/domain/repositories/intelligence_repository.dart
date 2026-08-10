import '../entities/habit_consistency_score.dart';
import '../entities/habit_insight.dart';
import '../entities/habit_recommendation.dart';

abstract class IntelligenceRepository {
  Future<List<HabitInsight>> getInsights(String habitId);
  Future<void> saveInsight(HabitInsight insight);
  
  Future<HabitConsistencyScore?> getConsistencyScore(String habitId);
  Future<void> saveConsistencyScore(HabitConsistencyScore score);
  
  Future<List<HabitRecommendation>> getRecommendations(String habitId);
  Future<void> saveRecommendation(HabitRecommendation recommendation);
}
