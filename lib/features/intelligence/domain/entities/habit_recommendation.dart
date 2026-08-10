import 'habit_insight.dart';

enum RecommendationType {
  scheduleAdjustment,
  frequencyAdjustment,
  habitPairing,
  restartRoutine,
  celebration,
  maintainMomentum,
  consistencyBoost,
  timingAdjustment,
  goalAdjustment,
  general,
}

enum RecommendationPriority {
  low,
  medium,
  high,
  critical,
}

class HabitRecommendation {
  final String id;
  final String habitId;
  final RecommendationType type;
  final RecommendationPriority priority;
  final String title;
  final String summary;
  final String reason;
  final String suggestedAction;
  final List<HabitInsight> supportingInsights;
  final DateTime generatedAt;

  const HabitRecommendation({
    required this.id,
    required this.habitId,
    required this.type,
    required this.priority,
    required this.title,
    required this.summary,
    required this.reason,
    required this.suggestedAction,
    required this.supportingInsights,
    required this.generatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitRecommendation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          habitId == other.habitId &&
          type == other.type &&
          priority == other.priority &&
          title == other.title &&
          summary == other.summary &&
          reason == other.reason &&
          suggestedAction == other.suggestedAction &&
          generatedAt == other.generatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      habitId.hashCode ^
      type.hashCode ^
      priority.hashCode ^
      title.hashCode ^
      summary.hashCode ^
      reason.hashCode ^
      suggestedAction.hashCode ^
      generatedAt.hashCode;
}
