import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/goals/domain/entities/goal.dart';
import 'package:habitflow/features/goals/domain/enums/goal_scope.dart';
import 'package:habitflow/features/goals/domain/enums/goal_status.dart';
import 'package:habitflow/features/goals/domain/enums/goal_type.dart';

void main() {
  group('Goal Entity', () {
    test('should create a valid Goal instance', () {
      final now = DateTime.now();
      final goal = Goal(
        id: '1',
        title: 'Test Goal',
        description: 'Test Description',
        habitIds: ['h1'],
        type: GoalType.completionCount,
        scope: GoalScope.daily,
        status: GoalStatus.active,
        targetValue: 10,
        createdAt: now,
        startDate: now,
        endDate: now.add(const Duration(days: 1)),
        colorValue: 0xFF000000,
        iconName: 'flag',
      );

      expect(goal.id, '1');
      expect(goal.title, 'Test Goal');
      expect(goal.habitIds, contains('h1'));
    });
  });

  group('Goal Enums', () {
    test('GoalType values should exist', () {
      expect(GoalType.values, contains(GoalType.completionCount));
      expect(GoalType.values, contains(GoalType.streak));
    });

    test('GoalScope values should exist', () {
      expect(GoalScope.values, contains(GoalScope.daily));
      expect(GoalScope.values, contains(GoalScope.monthly));
    });

    test('GoalStatus values should exist', () {
      expect(GoalStatus.values, contains(GoalStatus.active));
      expect(GoalStatus.values, contains(GoalStatus.completed));
    });
  });
}
