import '../../domain/entities/goal.dart';

/// Represents the immutable state of the Goals feature.
class GoalState {
  /// The list of all goals.
  final List<Goal> goals;

  /// The list of active goals.
  final List<Goal> activeGoals;

  /// The list of archived goals.
  final List<Goal> archivedGoals;

  /// The list of completed goals.
  final List<Goal> completedGoals;

  /// The currently selected goal (e.g., for editing or viewing details).
  final Goal? selectedGoal;

  /// Whether a background operation is in progress.
  final bool isLoading;

  /// Error message if an operation failed.
  final String? errorMessage;

  /// Creates a [GoalState].
  const GoalState({
    this.goals = const [],
    this.activeGoals = const [],
    this.archivedGoals = const [],
    this.completedGoals = const [],
    this.selectedGoal,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Creates a copy of the state with the given fields replaced.
  GoalState copyWith({
    List<Goal>? goals,
    List<Goal>? activeGoals,
    List<Goal>? archivedGoals,
    List<Goal>? completedGoals,
    Goal? selectedGoal,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GoalState(
      goals: goals ?? this.goals,
      activeGoals: activeGoals ?? this.activeGoals,
      archivedGoals: archivedGoals ?? this.archivedGoals,
      completedGoals: completedGoals ?? this.completedGoals,
      selectedGoal: selectedGoal ?? this.selectedGoal,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
