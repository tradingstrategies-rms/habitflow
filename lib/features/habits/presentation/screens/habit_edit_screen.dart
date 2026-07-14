import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/habits/domain/models/habit.dart';
import 'package:habitflow/features/habits/domain/models/habit_category.dart';
import 'package:habitflow/features/habits/domain/models/habit_difficulty.dart';
import 'package:habitflow/features/habits/domain/models/habit_frequency.dart';
import 'package:habitflow/features/habits/domain/models/habit_id.dart';
import 'package:habitflow/features/habits/domain/models/habit_color.dart';
import 'package:habitflow/features/habits/domain/models/habit_icon.dart';
import 'package:habitflow/features/habits/domain/models/habit_reminder.dart';
import 'package:habitflow/features/habits/domain/models/habit_schedule.dart';
import 'package:habitflow/features/habits/application/habit_controller.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_color_picker.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_icon_picker.dart';
import 'package:habitflow/core/extensions/string_extensions.dart';

class HabitEditScreen extends ConsumerStatefulWidget {
  const HabitEditScreen({super.key, this.habit});
  final Habit? habit;

  @override
  ConsumerState<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends ConsumerState<HabitEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  
  late HabitCategory _category;
  late HabitDifficulty _difficulty;
  late HabitFrequency _frequency;
  late HabitColor _color;
  late HabitIcon _icon;
  bool _isArchived = false;
  bool _isReminderEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit?.title ?? '');
    _descController = TextEditingController(text: widget.habit?.description ?? '');
    _category = widget.habit?.category ?? HabitCategory.other;
    _difficulty = widget.habit?.difficulty ?? HabitDifficulty.easy;
    _frequency = widget.habit?.frequency ?? HabitFrequency.daily;
    _color = widget.habit?.color ?? const HabitColor(0xFF86A789);
    _icon = widget.habit?.icon ?? const HabitIcon('✨');
    _isReminderEnabled = widget.habit?.reminders?.isNotEmpty ?? false;
    _isArchived = widget.habit?.isArchived ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(habitControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.habit == null ? 'Create Habit' : 'Edit Habit')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              maxLength: 50,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLength: 200,
              maxLines: 3,
            ),
            DropdownButtonFormField<HabitCategory>(
              items: HabitCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toTitleCase()))).toList(),
              onChanged: (v) => setState(() => _category = v!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            DropdownButtonFormField<HabitDifficulty>(
              items: HabitDifficulty.values.map((d) => DropdownMenuItem(value: d, child: Text(d.name.toTitleCase()))).toList(),
              onChanged: (v) => setState(() => _difficulty = v!),
              decoration: const InputDecoration(labelText: 'Difficulty'),
            ),
            DropdownButtonFormField<HabitFrequency>(
              items: HabitFrequency.values.map((f) => DropdownMenuItem(value: f, child: Text(f.name.toTitleCase()))).toList(),
              onChanged: (v) => setState(() => _frequency = v!),
              decoration: const InputDecoration(labelText: 'Frequency'),
            ),
            const SizedBox(height: 16),
            const Text('Color'),
            HabitColorPicker(selectedColor: _color, onColorChanged: (c) => setState(() => _color = c)),
            const SizedBox(height: 16),
            const Text('Icon'),
            HabitIconPicker(selectedIcon: _icon, onIconChanged: (i) => setState(() => _icon = i)),
            SwitchListTile(
              title: const Text('Reminder'),
              value: _isReminderEnabled,
              onChanged: (v) => setState(() => _isReminderEnabled = v),
            ),
            SwitchListTile(
              title: const Text('Archive'),
              value: _isArchived,
              onChanged: (v) => setState(() => _isArchived = v),
            ),
            ElevatedButton(
              onPressed: state.isLoading ? null : _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final List<HabitReminder>? reminders = _isReminderEnabled 
      ? [HabitReminder(id: DateTime.now().toString(), enabled: true, time: DateTime.now())]
      : null;

    final habit = Habit(
      id: widget.habit?.id ?? HabitId(DateTime.now().millisecondsSinceEpoch.toString()),
      title: _nameController.text.trim(),
      description: _descController.text.trim(),
      frequency: _frequency,
      category: _category,
      difficulty: _difficulty,
      color: _color,
      icon: _icon,
      schedule: const HabitSchedule(daysOfWeek: [1, 2, 3, 4, 5, 6, 7]),
      reminders: reminders,
      isArchived: _isArchived,
    );

    await ref.read(habitControllerProvider.notifier).saveHabit(habit, widget.habit != null);
    if (mounted) Navigator.of(context).pop();
  }
}
