import '../../domain/entities/goal.dart';
import '../../domain/enums/goal_scope.dart';
import '../../domain/enums/goal_type.dart';

class GoalEditState {
  final Goal? initialGoal;
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
  final bool isSaved;

  const GoalEditState({
    this.initialGoal,
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
    this.isSaved = false,
  });

  factory GoalEditState.fromGoal(Goal goal) {
    return GoalEditState(
      initialGoal: goal,
      title: goal.title,
      description: goal.description,
      habitIds: goal.habitIds,
      type: goal.type,
      scope: goal.scope,
      targetValue: goal.targetValue,
      startDate: goal.startDate,
      endDate: goal.endDate,
      colorValue: goal.colorValue,
      iconName: goal.iconName,
      isLoading: false,
    );
  }

  GoalEditState copyWith({
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
    bool? isSaved,
  }) {
    return GoalEditState(
      initialGoal: initialGoal,
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
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
