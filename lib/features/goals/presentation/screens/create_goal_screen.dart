import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/goals/application/providers/goal_providers.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_type_selector.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_scope_selector.dart';
import 'package:habitflow/features/goals/presentation/widgets/habit_selector.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_target_input.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_icon_picker.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_color_picker.dart';
import 'package:habitflow/shared/widgets/foundation/hf_button.dart';
import 'package:habitflow/shared/widgets/foundation/hf_text_field.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goalCreationControllerProvider);
    final notifier = ref.read(goalCreationControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sowing New Seeds'),
      ),
      body: Stepper(
        currentStep: state.currentStep,
        onStepContinue: () async {
          if (state.currentStep < 5) {
            notifier.nextStep();
          } else {
            final success = await notifier.create();
            if (success && context.mounted) {
              context.pop();
            }
          }
        },
        onStepCancel: () {
          if (state.currentStep > 0) {
            notifier.previousStep();
          } else {
            context.pop();
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: HFSpacing.l),
            child: Row(
              children: [
                Expanded(
                  child: HFButton(
                    label: state.currentStep == 5 ? 'Create Goal' : 'Next',
                    onPressed: details.onStepContinue,
                  ),
                ),
                if (state.currentStep > 0) ...[
                  const SizedBox(width: HFSpacing.m),
                  Expanded(
                    child: HFButton(
                      label: 'Back',
                      variant: HFButtonVariant.secondary,
                      onPressed: details.onStepCancel,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Goal Type'),
            content: GoalTypeSelector(
              selectedType: state.type,
              onTypeSelected: notifier.updateType,
            ),
            isActive: state.currentStep >= 0,
          ),
          Step(
            title: const Text('Timeframe'),
            content: GoalScopeSelector(
              selectedScope: state.scope,
              onScopeSelected: notifier.updateScope,
            ),
            isActive: state.currentStep >= 1,
          ),
          Step(
            title: const Text('Goal Details'),
            content: Column(
              children: [
                HFTextField(
                  controller: _titleController,
                  label: 'Goal Name',
                  onChanged: notifier.updateTitle,
                ),
                const SizedBox(height: HFSpacing.m),
                HFTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  onChanged: notifier.updateDescription,
                ),
                const SizedBox(height: HFSpacing.m),
                ListTile(
                  title: const Text('Goal Duration'),
                  subtitle: Text('${DateFormat.yMMMd().format(state.startDate)} - ${DateFormat.yMMMd().format(state.endDate)}'),
                  trailing: const Icon(Icons.calendar_today_rounded),
                  onTap: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      initialDateRange: DateTimeRange(start: state.startDate, end: state.endDate),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (range != null) {
                      notifier.updateDates(range.start, range.end);
                    }
                  },
                ),
              ],
            ),
            isActive: state.currentStep >= 2,
          ),
          Step(
            title: const Text('Linked Habits'),
            content: HabitSelector(
              selectedHabitIds: state.habitIds,
              onHabitsChanged: notifier.updateHabits,
            ),
            isActive: state.currentStep >= 3,
          ),
          Step(
            title: const Text('Target Setting'),
            content: GoalTargetInput(
              initialValue: state.targetValue,
              onTargetChanged: notifier.updateTarget,
            ),
            isActive: state.currentStep >= 4,
          ),
          Step(
            title: const Text('Appearance'),
            content: Column(
              children: [
                GoalIconPicker(
                  selectedIcon: state.iconName,
                  onIconSelected: (icon) => notifier.updateAppearance(state.colorValue, icon),
                ),
                const SizedBox(height: HFSpacing.l),
                GoalColorPicker(
                  selectedColor: state.colorValue,
                  onColorSelected: (color) => notifier.updateAppearance(color, state.iconName),
                ),
              ],
            ),
            isActive: state.currentStep >= 5,
          ),
        ],
      ),
    );
  }
}
