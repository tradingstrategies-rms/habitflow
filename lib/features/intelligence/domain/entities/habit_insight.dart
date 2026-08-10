import 'habit_pattern.dart';

enum InsightCategory {
  positive,
  warning,
  achievement,
  consistency,
  trend,
  timing,
  recovery,
  streak,
  general,
}

enum InsightSeverity {
  low,
  medium,
  high,
}

class HabitInsight {
  final String id;
  final String habitId;
  final InsightCategory category;
  final InsightSeverity severity;
  final String title;
  final String summary;
  final String explanation;
  final List<HabitPattern> supportingPatterns;
  final DateTime generatedAt;

  const HabitInsight({
    required this.id,
    required this.habitId,
    required this.category,
    required this.severity,
    required this.title,
    required this.summary,
    required this.explanation,
    required this.supportingPatterns,
    required this.generatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitInsight &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          habitId == other.habitId &&
          category == other.category &&
          severity == other.severity &&
          title == other.title &&
          summary == other.summary &&
          explanation == other.explanation &&
          generatedAt == other.generatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      habitId.hashCode ^
      category.hashCode ^
      severity.hashCode ^
      title.hashCode ^
      summary.hashCode ^
      explanation.hashCode ^
      generatedAt.hashCode;
}
