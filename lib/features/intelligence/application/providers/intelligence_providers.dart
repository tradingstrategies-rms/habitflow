import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import '../../domain/repositories/intelligence_repository.dart';
import '../../domain/services/intelligence_analyzer.dart';
import '../../domain/services/consistency_score_calculator.dart';
import '../../domain/services/pattern_detection_service.dart';
import '../../domain/services/insight_generation_service.dart';
import '../../domain/services/recommendation_generation_service.dart';
import '../../data/repositories/intelligence_repository_impl.dart';
import '../../data/services/intelligence_analyzer_impl.dart';
import '../../domain/entities/habit_pattern.dart';
import '../../domain/entities/habit_consistency_score.dart';
import '../../domain/entities/habit_insight.dart';
import '../../domain/entities/habit_recommendation.dart';

final consistencyScoreCalculatorProvider = Provider<ConsistencyScoreCalculator>((ref) {
  return ConsistencyScoreCalculator();
});

final patternDetectionServiceProvider = Provider<PatternDetectionService>((ref) {
  return PatternDetectionService();
});

final insightGenerationServiceProvider = Provider<InsightGenerationService>((ref) {
  return InsightGenerationService();
});

final recommendationGenerationServiceProvider = Provider<RecommendationGenerationService>((ref) {
  return RecommendationGenerationService();
});

final intelligenceRepositoryProvider = Provider<IntelligenceRepository>((ref) {
  return IntelligenceRepositoryImpl();
});

final intelligenceAnalyzerProvider = Provider<IntelligenceAnalyzer>((ref) {
  final calculator = ref.watch(consistencyScoreCalculatorProvider);
  final streakService = ref.watch(habitStreakServiceProvider);
  final patternDetector = ref.watch(patternDetectionServiceProvider);
  final insightGenerator = ref.watch(insightGenerationServiceProvider);
  final recommendationGenerator = ref.watch(recommendationGenerationServiceProvider);
  
  return IntelligenceAnalyzerImpl(
    calculator,
    streakService,
    patternDetector,
    insightGenerator,
    recommendationGenerator,
  );
});

class IntelligenceSummary {
  final HabitConsistencyScore consistencyScore;
  final List<HabitPattern> patterns;
  final List<HabitInsight> insights;
  final HabitRecommendation topRecommendation;

  const IntelligenceSummary({
    required this.consistencyScore,
    required this.patterns,
    required this.insights,
    required this.topRecommendation,
  });
}

final intelligenceSummaryProvider = FutureProvider<IntelligenceSummary?>((ref) async {
  final habits = ref.watch(activeHabitsProvider).value ?? [];
  final completions = ref.watch(allHabitCompletionsProvider).value ?? [];
  final analyzer = ref.watch(intelligenceAnalyzerProvider);

  if (habits.isEmpty) {
    return null;
  }

  // Aggregate analysis results for all habits
  List<HabitInsight> allInsights = [];
  List<HabitRecommendation> allRecommendations = [];
  List<HabitPattern> allPatterns = [];
  
  // We'll take the first habit's consistency score as a proxy for 'overall'
  // Or implement a more robust aggregator in a future sprint
  HabitConsistencyScore? overallScore;

  for (final habit in habits) {
    final habitCompletions = completions.where((c) => c.habitId == habit.id).toList();
    final result = await analyzer.analyzeHabit(habit: habit, history: habitCompletions);
    
    allInsights.addAll(result.insights);
    allRecommendations.addAll(result.recommendations);
    allPatterns.addAll(result.patterns);
    
    overallScore ??= result.score;
  }

  if (overallScore == null) return null;

  return IntelligenceSummary(
    consistencyScore: overallScore,
    patterns: allPatterns.take(5).toList(),
    insights: allInsights.take(5).toList(),
    topRecommendation: allRecommendations.isNotEmpty 
        ? allRecommendations.first 
        : HabitRecommendation(
            id: 'system-default',
            habitId: 'system',
            type: RecommendationType.general,
            priority: RecommendationPriority.low,
            title: 'Keep going!',
            summary: 'Your habit journey is just beginning.',
            reason: 'Insufficient history.',
            suggestedAction: 'Stay consistent to unlock more insights.',
            supportingInsights: [],
            generatedAt: DateTime.now(),
          ),
  );
});
