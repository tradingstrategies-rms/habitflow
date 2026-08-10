import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/core/achievements/events/goal_completed_event.dart';
import 'package:habitflow/features/goals/application/services/goal_completion_service.dart';
import 'package:habitflow/features/goals/application/controllers/goal_controller.dart';
import 'package:habitflow/core/achievements/services/achievement_event_bus.dart';
import 'package:habitflow/features/goals/domain/entities/goal.dart';
import 'package:habitflow/core/progress/models/progress_summary.dart';
import 'package:habitflow/features/goals/domain/enums/goal_scope.dart';
import 'package:habitflow/features/goals/domain/enums/goal_status.dart';
import 'package:habitflow/features/goals/domain/enums/goal_type.dart';

class MockGoalController extends Mock implements GoalController {}
class MockAchievementEventBus extends Mock implements AchievementEventBus {}

void main() {
  late GoalCompletionService service;
  late MockGoalController mockController;
  late MockAchievementEventBus mockEventBus;

  setUpAll(() {
    registerFallbackValue(Goal(
      id: '', title: '', description: '', habitIds: [], 
      type: GoalType.binary, scope: GoalScope.daily, status: GoalStatus.active, 
      targetValue: 0, createdAt: DateTime.now(), startDate: DateTime.now(), 
      endDate: DateTime.now(), colorValue: 0, iconName: ''
    ));
    registerFallbackValue(GoalCompletedEvent(
      goalId: '', goalTitle: '', completedAt: DateTime.now(), 
      targetValue: 0, achievementMessage: ''
    ));
  });

  setUp(() {
    mockController = MockGoalController();
    mockEventBus = MockAchievementEventBus();
    service = GoalCompletionService(mockController, mockEventBus);
  });

  group('GoalCompletionService', () {
    test('should update status and publish event when goal is completed', () async {
      final goal = Goal(
        id: 'g1',
        title: 'Test',
        description: '',
        habitIds: [],
        type: GoalType.completionCount,
        scope: GoalScope.daily,
        status: GoalStatus.active,
        targetValue: 10,
        createdAt: DateTime.now(),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        colorValue: 0,
        iconName: '',
      );

      const progress = ProgressSummary(
        completedValue: 10,
        targetValue: 10,
        percentage: 100,
        remaining: 0,
        isCompleted: true,
      );

      when(() => mockController.updateGoal(any())).thenAnswer((_) async {});
      when(() => mockEventBus.publishGoalCompleted(any())).thenAnswer((_) async {});

      await service.checkAndRecordCompletion(goal, progress);

      verify(() => mockController.updateGoal(any())).called(1);
      verify(() => mockEventBus.publishGoalCompleted(any())).called(1);
    });

    test('should not update status if already completed', () async {
       final goal = Goal(
        id: 'g1',
        title: 'Test',
        description: '',
        habitIds: [],
        type: GoalType.completionCount,
        scope: GoalScope.daily,
        status: GoalStatus.completed,
        targetValue: 10,
        createdAt: DateTime.now(),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        colorValue: 0,
        iconName: '',
      );

      const progress = ProgressSummary(
        completedValue: 10,
        targetValue: 10,
        percentage: 100,
        remaining: 0,
        isCompleted: true,
      );

      await service.checkAndRecordCompletion(goal, progress);

      verifyNever(() => mockController.updateGoal(any()));
    });
  });
}
