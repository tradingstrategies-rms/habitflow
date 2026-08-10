import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/goal.dart';
import '../../domain/enums/goal_scope.dart';
import '../../domain/enums/goal_type.dart';
import '../state/goal_edit_state.dart';
import 'goal_controller.dart';

class GoalEditController extends StateNotifier<GoalEditState> {
  final GoalController _goalController;

  GoalEditController(this._goalController, Goal goal) : super(GoalEditState.fromGoal(goal));

  void updateTitle(String title) => state = state.copyWith(title: title);
  void updateDescription(String desc) => state = state.copyWith(description: desc);
  void updateType(GoalType type) => state = state.copyWith(type: type);
  void updateScope(GoalScope scope) => state = state.copyWith(scope: scope);
  void updateTarget(double target) => state = state.copyWith(targetValue: target);
  void updateHabits(List<String> habitIds) => state = state.copyWith(habitIds: habitIds);
  void updateDates(DateTime start, DateTime end) => state = state.copyWith(startDate: start, endDate: end);
  void updateAppearance(int color, String icon) => state = state.copyWith(colorValue: color, iconName: icon);

  Future<bool> save() async {
    if (state.title.isEmpty) {
      state = state.copyWith(errorMessage: 'Title is required');
      return false;
    }
    if (state.habitIds.isEmpty) {
      state = state.copyWith(errorMessage: 'Select at least one habit');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final updatedGoal = Goal(
      id: state.initialGoal!.id,
      title: state.title,
      description: state.description,
      habitIds: state.habitIds,
      type: state.type,
      scope: state.scope,
      status: state.initialGoal!.status,
      targetValue: state.targetValue,
      createdAt: state.initialGoal!.createdAt,
      startDate: state.startDate,
      endDate: state.endDate,
      colorValue: state.colorValue,
      iconName: state.iconName,
    );

    try {
      await _goalController.updateGoal(updatedGoal);
      state = state.copyWith(isLoading: false, isSaved: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}
