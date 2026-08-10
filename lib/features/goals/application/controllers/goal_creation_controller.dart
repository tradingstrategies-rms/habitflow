import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/goal.dart';
import '../../domain/enums/goal_scope.dart';
import '../../domain/enums/goal_status.dart';
import '../../domain/enums/goal_type.dart';
import '../state/goal_creation_state.dart';
import 'goal_controller.dart';

class GoalCreationController extends StateNotifier<GoalCreationState> {
  final GoalController _goalController;

  GoalCreationController(this._goalController) : super(GoalCreationState.initial());

  void updateTitle(String title) => state = state.copyWith(title: title);
  void updateDescription(String desc) => state = state.copyWith(description: desc);
  void updateType(GoalType type) => state = state.copyWith(type: type);
  void updateScope(GoalScope scope) => state = state.copyWith(scope: scope);
  void updateTarget(double target) => state = state.copyWith(targetValue: target);
  void updateHabits(List<String> habitIds) => state = state.copyWith(habitIds: habitIds);
  void updateDates(DateTime start, DateTime end) => state = state.copyWith(startDate: start, endDate: end);
  void updateAppearance(int color, String icon) => state = state.copyWith(colorValue: color, iconName: icon);

  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);
  void previousStep() => state = state.copyWith(currentStep: state.currentStep - 1);
  void setStep(int step) => state = state.copyWith(currentStep: step);

  Future<bool> create() async {
    if (state.title.isEmpty) {
      state = state.copyWith(errorMessage: 'Title is required');
      return false;
    }
    if (state.habitIds.isEmpty) {
      state = state.copyWith(errorMessage: 'Select at least one habit');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final goal = Goal(
      id: const Uuid().v4(),
      title: state.title,
      description: state.description,
      habitIds: state.habitIds,
      type: state.type,
      scope: state.scope,
      status: GoalStatus.active,
      targetValue: state.targetValue,
      createdAt: DateTime.now(),
      startDate: state.startDate,
      endDate: state.endDate,
      colorValue: state.colorValue,
      iconName: state.iconName,
    );

    try {
      await _goalController.createGoal(goal);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}
