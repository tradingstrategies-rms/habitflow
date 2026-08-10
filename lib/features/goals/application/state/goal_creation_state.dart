import '../../domain/enums/goal_scope.dart';
import '../../domain/enums/goal_type.dart';

class GoalCreationState {
  final String title;
  final String description;
  final List<String> habitIds;
  final GoalType type;
  final GoalScope scope;
  final double targetValue;
  final DateTime startDate;
  final DateTime endDate;
  final int colorValue;
  final String iconName;
  final bool isLoading;
  final String? errorMessage;
  final int currentStep;

  const GoalCreationState({
    required this.title,
    required this.description,
    required this.habitIds,
    required this.type,
    required this.scope,
    required this.targetValue,
    required this.startDate,
    required this.endDate,
    required this.colorValue,
    required this.iconName,
    required this.isLoading,
    this.errorMessage,
    required this.currentStep,
  });

  factory GoalCreationState.initial() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return GoalCreationState(
      title: '',
      description: '',
      habitIds: const [],
      type: GoalType.completionCount,
      scope: GoalScope.daily,
      targetValue: 0,
      startDate: today,
      endDate: today.add(const Duration(days: 30)),
      colorValue: 0xFF006C49,
      iconName: 'emoji_events',
      isLoading: false,
      currentStep: 0,
    );
  }

  GoalCreationState copyWith({
    String? title,
    String? description,
    List<String>? habitIds,
    GoalType? type,
    GoalScope? scope,
    double? targetValue,
    DateTime? startDate,
    DateTime? endDate,
    int? colorValue,
    String? iconName,
    bool? isLoading,
    String? errorMessage,
    int? currentStep,
  }) {
    return GoalCreationState(
      title: title ?? this.title,
      description: description ?? this.description,
      habitIds: habitIds ?? this.habitIds,
      type: type ?? this.type,
      scope: scope ?? this.scope,
      targetValue: targetValue ?? this.targetValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}
