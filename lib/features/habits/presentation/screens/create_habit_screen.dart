import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/family/domain/entities/shared_habit.dart';
import 'package:habitflow/features/family/domain/enums/shared_habit_completion_mode.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_category.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_color.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_frequency.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_icon.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_priority.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_category_selector.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_color_selector.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_description_field.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_frequency_selector.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_icon_selector.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_name_field.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_save_button.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_target_field.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_unit_selector.dart';
import 'package:habitflow/features/family/presentation/widgets/member_avatar.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class CreateHabitScreen extends ConsumerStatefulWidget {
  final Habit? habitToEdit;
  final bool? initialIsShared;
  const CreateHabitScreen({super.key, this.habitToEdit, this.initialIsShared});

  @override
  ConsumerState<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends ConsumerState<CreateHabitScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _targetController = TextEditingController();
  String _unit = 'Minutes';
  String? _customUnit;
  
  HabitCategory _category = HabitCategory.health;
  HabitFrequency _frequency = HabitFrequency.daily;
  HabitColor _color = HabitColor.emerald;
  HabitIcon _icon = HabitIcon.water;
  HabitPriority _priority = HabitPriority.medium;

  bool _isValid = false;

  // Family Shared Habit state
  bool _isShared = false;
  List<String> _selectedMemberIds = [];
  SharedHabitCompletionMode _completionMode = SharedHabitCompletionMode.everyone;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialIsShared == true) {
      _isShared = true;
    }
    if (widget.habitToEdit != null) {
      final h = widget.habitToEdit!;
      _titleController.text = h.title;
      _descController.text = h.description ?? '';
      _category = h.category;
      _frequency = h.frequency;
      _color = h.color;
      _icon = h.icon;
      _priority = h.priority;
      _targetController.text = h.targetValue.toString();
      _unit = h.unit;
      _isValid = true;

      // Check if it's shared
      _loadSharedData();
    }
    _titleController.addListener(_validate);
  }

  Future<void> _loadSharedData() async {
    final sharedHabit = await ref.read(familyRepositoryProvider).getSharedHabitByHabitId(widget.habitToEdit!.id);
    if (sharedHabit != null) {
      setState(() {
        _isShared = true;
        _selectedMemberIds = List.from(sharedHabit.assignedMemberIds);
        _completionMode = sharedHabit.completionMode;
      });
    }
  }

  void _validate() => setState(() => _isValid = _titleController.text.isNotEmpty);

  Future<void> _saveHabit() async {
    final isEditing = widget.habitToEdit != null;
    final activeProfile = ref.read(activeProfileProvider);

    final habitId = isEditing ? widget.habitToEdit!.id : DateTime.now().millisecondsSinceEpoch.toString();

    final habit = Habit(
      id: habitId,
      userId: activeProfile?.id ?? 'user_1',
      title: _titleController.text,
      description: _descController.text,
      category: _category,
      icon: _icon,
      color: _color,
      priority: _priority,
      frequency: _frequency,
      targetValue: double.tryParse(_targetController.text) ?? 1.0,
      unit: _unit == 'Custom...' ? (_customUnit ?? '') : _unit,
      createdAt: isEditing ? widget.habitToEdit!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (isEditing) {
      await ref.read(habitControllerProvider).updateHabit(habit);
    } else {
      await ref.read(habitControllerProvider).createHabit(habit);
    }

    // Handle Sharing
    final familyNotifier = ref.read(familyProvider.notifier);
    final familyRepo = ref.read(familyRepositoryProvider);
    final existingShared = await familyRepo.getSharedHabitByHabitId(habitId);

    if (_isShared) {
      final sharedHabit = SharedHabit(
        id: existingShared?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        habitId: habitId,
        assignedMemberIds: _selectedMemberIds,
        completionMode: _completionMode,
        createdBy: activeProfile?.id ?? '',
        createdAt: existingShared?.createdAt ?? DateTime.now(),
      );

      if (existingShared != null) {
        await familyNotifier.updateSharedHabit(sharedHabit);
      } else {
        await familyNotifier.createSharedHabit(sharedHabit);
      }
    } else if (existingShared != null) {
      await familyNotifier.deleteSharedHabit(existingShared.id, habitId);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final familyState = ref.watch(familyProvider);

    return Scaffold(
      appBar: const HFTopAppBar(title: 'Create New Habit'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HabitNameField(controller: _titleController),
            const SizedBox(height: 16),
            HabitDescriptionField(controller: _descController),
            const SizedBox(height: 16),
            HabitCategorySelector(selectedCategory: _category, onSelected: (c) => setState(() => _category = c)),
            const SizedBox(height: 16),
            HabitFrequencySelector(selectedFrequency: _frequency, onSelected: (f) => setState(() => _frequency = f)),
            const SizedBox(height: 16),
            const Align(alignment: Alignment.centerLeft, child: Text('Goal', style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  HabitTargetField(controller: _targetController),
                  const SizedBox(height: 12),
                  HabitUnitSelector(
                    onUnitChanged: (u) => setState(() => _unit = u),
                    onCustomUnitChanged: (c) => setState(() => _customUnit = c),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Family Sharing Section
            _buildFamilySharingSection(familyState),
            const SizedBox(height: 16),

            const Align(alignment: Alignment.centerLeft, child: Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HabitColorSelector(selectedColor: _color, onSelected: (c) => setState(() => _color = c)),
                  const SizedBox(height: 16),
                  HabitIconSelector(selectedIcon: _icon, onSelected: (i) => setState(() => _icon = i)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HabitSaveButton(
        label: widget.habitToEdit != null ? 'Update Habit' : 'Create Habit',
        onPressed: _isValid ? _saveHabit : null,
      ),
    );
  }

  Widget _buildFamilySharingSection(FamilyState familyState) {
    final theme = Theme.of(context);
    if (familyState.circle == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Share With Family', style: TextStyle(fontWeight: FontWeight.bold)),
            Switch(
              value: _isShared,
              onChanged: (val) => setState(() => _isShared = val),
            ),
          ],
        ),
        if (_isShared) ...[
          const SizedBox(height: 8),
          const Text('Assigned Members', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: familyState.profiles.map((profile) {
                final isSelected = _selectedMemberIds.contains(profile.id);
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedMemberIds.add(profile.id);
                      } else {
                        _selectedMemberIds.remove(profile.id);
                      }
                    });
                  },
                  secondary: MemberAvatar(profileType: profile.profileType, avatarUrl: profile.avatarUrl, radius: 18),
                  title: Text(profile.displayName),
                  subtitle: Text(profile.role.displayName.toUpperCase(), style: theme.textTheme.labelSmall),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Completion Mode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          SegmentedButton<SharedHabitCompletionMode>(
            segments: SharedHabitCompletionMode.values.map((mode) {
              return ButtonSegment<SharedHabitCompletionMode>(
                value: mode,
                label: Text(mode.displayName, style: const TextStyle(fontSize: 10)),
                tooltip: mode.description,
              );
            }).toList(),
            selected: {_completionMode},
            onSelectionChanged: (newSelection) {
              setState(() => _completionMode = newSelection.first);
            },
            showSelectedIcon: false,
          ),
        ],
      ],
    );
  }
}
