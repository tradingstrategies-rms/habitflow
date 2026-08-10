import 'package:habitflow/features/goals/domain/entities/goal.dart';
import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/domain/entities/habit_completion.dart';
import 'package:habitflow/features/habits/application/services/habit_streak_service.dart';
import '../../domain/services/intelligence_analyzer.dart';
import '../../domain/services/consistency_score_calculator.dart';
import '../../domain/services/pattern_detection_service.dart';
import '../../domain/services/insight_generation_service.dart';
import '../../domain/services/recommendation_generation_service.dart';

class IntelligenceAnalyzerImpl implements IntelligenceAnalyzer {
  final ConsistencyScoreCalculator _calculator;
  final HabitStreakService _streakService;
  final PatternDetectionService _patternDetector;
  final InsightGenerationService _insightGenerator;
  final RecommendationGenerationService _recommendationGenerator;

  IntelligenceAnalyzerImpl(
    this._calculator,
    this._streakService,
    this._patternDetector,
    this._insightGenerator,
    this._recommendationGenerator,
  );

  @override
  Future<IntelligenceAnalysisResult> analyzeHabit({
    required Habit habit,
    required List<HabitCompletion> history,
    Goal? goal,
  }) async {
    final currentStreak = _streakService.calculateCurrentStreak(history);
    
    final score = _calculator.calculate(
      habit: habit,
      history: history,
      currentStreak: currentStreak,
    );

    final patterns = _patternDetector.detectPatterns(
      habit: habit,
      history: history,
    );

    final insights = _insightGenerator.generateInsights(
      habit: habit,
      score: score,
      patterns: patterns,
    );

    final recommendations = _recommendationGenerator.generateRecommendations(
      habit: habit,
      score: score,
      patterns: patterns,
      insights: insights,
    );

    return IntelligenceAnalysisResult(
      score: score,
      patterns: patterns,
      insights: insights,
      recommendations: recommendations,
    );
  }
}
