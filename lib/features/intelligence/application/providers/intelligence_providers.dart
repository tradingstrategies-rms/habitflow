import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import 'package:habitflow/features/analytics/application/providers/analytics_providers.dart';
import 'package:habitflow/features/analytics/domain/entities/family_productivity_score.dart';
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

class IntelligenceDashboardSummary {
  final HabitInsight? priorityInsight;
  final List<HabitInsight> otherInsights;
  final List<HabitInsight> positiveInsights;
  final HabitRecommendation? topRecommendation;
  final FamilyProductivityScore? familyScore;
  final HabitConsistencyScore? overallConsistency;

  const IntelligenceDashboardSummary({
    this.priorityInsight,
    this.otherInsights = const [],
    this.positiveInsights = const [],
    this.topRecommendation,
    this.familyScore,
    this.overallConsistency,
  });
}

final intelligenceDashboardProvider = FutureProvider<IntelligenceDashboardSummary?>((ref) async {
  final habits = ref.watch(activeHabitsProvider).value ?? [];
  final completions = ref.watch(allHabitCompletionsProvider).value ?? [];
  final analyzer = ref.watch(intelligenceAnalyzerProvider);
  final familyScoreAsync = ref.watch(familyProductivityScoreProvider(const Duration(days: 30)));

  if (habits.isEmpty) {
    return null;
  }

  List<HabitInsight> allInsights = [];
  List<HabitRecommendation> allRecommendations = [];
  HabitConsistencyScore? firstScore;

  for (final habit in habits) {
    final habitCompletions = completions.where((c) => c.habitId == habit.id).toList();
    final result = await analyzer.analyzeHabit(habit: habit, history: habitCompletions);
    
    allInsights.addAll(result.insights);
    allRecommendations.addAll(result.recommendations);
    firstScore ??= result.score;
  }

  // Prioritize insights
  // 1. High severity (Fading, etc.)
  // 2. Medium severity
  // 3. Positive observations
  
  final priorityInsights = allInsights.where((i) => i.severity == InsightSeverity.high).toList();
  final otherInsights = allInsights.where((i) => i.severity == InsightSeverity.medium).toList();
  final positiveInsights = allInsights.where((i) => 
    i.category == InsightCategory.positive || 
    i.category == InsightCategory.achievement ||
    i.category == InsightCategory.streak
  ).toList();

  // Top recommendation from the highest priority insight
  HabitRecommendation? topRec;
  if (priorityInsights.isNotEmpty) {
    topRec = allRecommendations.firstWhere(
      (r) => r.supportingInsights.any((i) => i.id == priorityInsights.first.id),
      orElse: () => allRecommendations.first,
    );
  } else if (allRecommendations.isNotEmpty) {
    topRec = allRecommendations.first;
  }

  return IntelligenceDashboardSummary(
    priorityInsight: priorityInsights.isNotEmpty ? priorityInsights.first : (otherInsights.isNotEmpty ? otherInsights.first : null),
    otherInsights: otherInsights.length > 1 ? otherInsights.sublist(1) : [],
    positiveInsights: positiveInsights,
    topRecommendation: topRec,
    familyScore: familyScoreAsync.value,
    overallConsistency: firstScore,
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

final habitIntelligenceProvider = FutureProvider.family<IntelligenceAnalysisResult, (String, Duration)>((ref, arg) async {
  final habitId = arg.$1;
  final duration = arg.$2;
  
  final habit = await ref.watch(habitByIdProvider(habitId).future);
  if (habit == null) throw Exception('Habit not found');

  final completions = ref.watch(allHabitCompletionsProvider).value ?? [];
  final habitCompletions = completions.where((c) => c.habitId == habitId).toList();
  
  final now = DateTime.now();
  final end = DateTime(now.year, now.month, now.day);
  final start = end.subtract(duration);
  
  final metrics = ref.watch(habitAnalyticsProvider((habitId, start, end)));
  final trend = ref.watch(habitAnalyticsTrendProvider((habitId, duration)));
  
  final analyzer = ref.watch(intelligenceAnalyzerProvider);
  
  return analyzer.analyzeHabit(
    habit: habit,
    history: habitCompletions,
    metrics: metrics,
    trend: trend,
  );
});

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
  HabitConsistencyScore? overallScore;

  for (final habit in habits) {
    final habitCompletions = completions.where((c) => c.habitId == habit.id).toList();
    
    // For summary, we can use a default 30-day window if needed, or just let analyzer calculate its own.
    // To be consistent with 9.1.3, we should probably fetch metrics too, but for global summary 
    // maybe we stick to raw history for now or use 30d.
    final result = await analyzer.analyzeHabit(
      habit: habit, 
      history: habitCompletions,
    );
    
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
