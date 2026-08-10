import '../enums/goal_scope.dart';
import '../enums/goal_status.dart';
import '../enums/goal_type.dart';

/// Represents a goal entity that defines a target for one or more habits.
class Goal {
  /// Unique identifier for the goal.
  final String id;

  /// The title of the goal.
  final String title;

  /// Detailed description of the goal.
  final String description;

  /// List of habit IDs that are linked to this goal.
  final List<String> habitIds;

  /// The tracking type of the goal.
  final GoalType type;

  /// The periodicity or timeframe of the goal.
  final GoalScope scope;

  /// The current state of the goal.
  final GoalStatus status;

  /// The target value to achieve.
  final double targetValue;

  /// The timestamp when the goal was created.
  final DateTime createdAt;

  /// The date when goal tracking starts.
  final DateTime startDate;

  /// The date when goal tracking ends.
  final DateTime endDate;

  /// Integer representation of the color (hex value).
  final int colorValue;

  /// String name identifier for the icon.
  final String iconName;

  /// Creates a [Goal] with the specified attributes.
  const Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.habitIds,
    required this.type,
    required this.scope,
    required this.status,
    required this.targetValue,
    required this.createdAt,
    required this.startDate,
    required this.endDate,
    required this.colorValue,
    required this.iconName,
  });
}
