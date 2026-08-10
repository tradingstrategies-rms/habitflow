import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/goals/data/models/goal_model.dart';
import 'package:habitflow/features/goals/domain/entities/goal.dart';
import 'package:habitflow/features/goals/domain/enums/goal_scope.dart';
import 'package:habitflow/features/goals/domain/enums/goal_status.dart';
import 'package:habitflow/features/goals/domain/enums/goal_type.dart';

void main() {
  group('GoalModel', () {
    final now = DateTime.now();
    final goal = Goal(
      id: 'g1',
      title: 'Model Test',
      description: 'Desc',
      habitIds: ['h1'],
      type: GoalType.completionCount,
      scope: GoalScope.daily,
      status: GoalStatus.active,
      targetValue: 5,
      createdAt: now,
      startDate: now,
      endDate: now,
      colorValue: 0,
      iconName: '',
    );

    test('fromDomain and toDomain should be consistent', () {
      final model = GoalModel.fromDomain(goal);
      final domain = model.toDomain();

      expect(domain.id, goal.id);
      expect(domain.title, goal.title);
      expect(domain.type, goal.type);
    });

    test('fromJson and toJson should be consistent', () {
      final model = GoalModel.fromDomain(goal);
      final json = model.toJson();
      final fromJson = GoalModel.fromJson(json);

      expect(fromJson.id, model.id);
      expect(fromJson.title, model.title);
    });
  });
}
