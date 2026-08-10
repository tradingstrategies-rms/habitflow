import '../../domain/entities/goal.dart';
import '../../domain/enums/goal_scope.dart';
import '../../domain/enums/goal_status.dart';
import '../../domain/enums/goal_type.dart';

/// Data model for the [Goal] entity, providing JSON serialization.
class GoalModel {
  final String id;
  final String title;
  final String description;
  final List<String> habitIds;
  final String type;
  final String scope;
  final String status;
  final double targetValue;
  final String createdAt;
  final String startDate;
  final String endDate;
  final int colorValue;
  final String iconName;

  const GoalModel({
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

  /// Creates a [GoalModel] from a JSON map.
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      habitIds: List<String>.from(json['habitIds'] as Iterable),
      type: json['type'] as String,
      scope: json['scope'] as String,
      status: json['status'] as String,
      targetValue: (json['targetValue'] as num).toDouble(),
      createdAt: json['createdAt'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      colorValue: json['colorValue'] as int,
      iconName: json['iconName'] as String,
    );
  }

  /// Converts the [GoalModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'habitIds': habitIds,
      'type': type,
      'scope': scope,
      'status': status,
      'targetValue': targetValue,
      'createdAt': createdAt,
      'startDate': startDate,
      'endDate': endDate,
      'colorValue': colorValue,
      'iconName': iconName,
    };
  }

  /// Creates a [GoalModel] from a Domain [Goal] entity.
  factory GoalModel.fromDomain(Goal goal) {
    return GoalModel(
      id: goal.id,
      title: goal.title,
      description: goal.description,
      habitIds: goal.habitIds,
      type: goal.type.name,
      scope: goal.scope.name,
      status: goal.status.name,
      targetValue: goal.targetValue,
      createdAt: goal.createdAt.toIso8601String(),
      startDate: goal.startDate.toIso8601String(),
      endDate: goal.endDate.toIso8601String(),
      colorValue: goal.colorValue,
      iconName: goal.iconName,
    );
  }

  /// Converts the [GoalModel] to a Domain [Goal] entity.
  Goal toDomain() {
    return Goal(
      id: id,
      title: title,
      description: description,
      habitIds: habitIds,
      type: GoalType.values.byName(type),
      scope: GoalScope.values.byName(scope),
      status: GoalStatus.values.byName(status),
      targetValue: targetValue,
      createdAt: DateTime.parse(createdAt),
      startDate: DateTime.parse(startDate),
      endDate: DateTime.parse(endDate),
      colorValue: colorValue,
      iconName: iconName,
    );
  }
}
