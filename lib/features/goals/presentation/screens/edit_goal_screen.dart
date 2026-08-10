import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/goals/domain/entities/goal.dart';
import 'package:habitflow/features/goals/application/providers/goal_providers.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_type_selector.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_scope_selector.dart';
import 'package:habitflow/features/goals/presentation/widgets/habit_selector.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_target_input.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_icon_picker.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_color_picker.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_form_actions.dart';
import 'package:habitflow/shared/widgets/foundation/hf_text_field.dart';

class EditGoalScreen extends ConsumerStatefulWidget {
  final Goal goal;

  const EditGoalScreen({
    super.key,
    required this.goal,
  });

  @override
  ConsumerState<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends ConsumerState<EditGoalScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal.title);
    _descriptionController = TextEditingController(text: widget.goal.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goalEditControllerProvider(widget.goal));
    final notifier = ref.read(goalEditControllerProvider(widget.goal).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Goal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(HFSpacing.ml),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HFTextField(
              controller: _titleController,
              label: 'Goal Name',
              onChanged: notifier.updateTitle,
            ),
            const SizedBox(height: HFSpacing.l),
            HFTextField(
              controller: _descriptionController,
              label: 'Description',
              onChanged: notifier.updateDescription,
            ),
            const SizedBox(height: HFSpacing.l),
            GoalTypeSelector(
              selectedType: state.type,
              onTypeSelected: notifier.updateType,
            ),
            const SizedBox(height: HFSpacing.l),
            GoalScopeSelector(
              selectedScope: state.scope,
              onScopeSelected: notifier.updateScope,
            ),
            const SizedBox(height: HFSpacing.l),
            HabitSelector(
              selectedHabitIds: state.habitIds,
              onHabitsChanged: notifier.updateHabits,
            ),
            const SizedBox(height: HFSpacing.l),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Goal Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
            const SizedBox(height: HFSpacing.l),
            GoalTargetInput(
              initialValue: state.targetValue,
              onTargetChanged: notifier.updateTarget,
            ),
            const SizedBox(height: HFSpacing.l),
            GoalIconPicker(
              selectedIcon: state.iconName,
              onIconSelected: (icon) => notifier.updateAppearance(state.colorValue, icon),
            ),
            const SizedBox(height: HFSpacing.l),
            GoalColorPicker(
              selectedColor: state.colorValue,
              onColorSelected: (color) => notifier.updateAppearance(color, state.iconName),
            ),
            const SizedBox(height: HFSpacing.xxl),
            GoalFormActions(
              onCancel: () => context.pop(),
              onSave: () async {
                final success = await notifier.save();
                if (success && context.mounted) {
                  context.pop();
                }
              },
              saveLabel: 'Save Changes',
              isLoading: state.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: const Text('This will permanently delete the goal and all its progress data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(goalControllerProvider.notifier).deleteGoal(widget.goal.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
