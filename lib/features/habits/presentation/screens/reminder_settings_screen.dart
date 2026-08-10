import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../application/providers/habit_repository_provider.dart';
import '../../application/providers/reminder_providers.dart';
import '../../application/providers/reminder_scheduler_providers.dart';
import '../../domain/entities/habit_reminder.dart';
import '../widgets/reminder_preview_card.dart';
import '../widgets/reminder_repeat_selector.dart';
import '../widgets/reminder_time_picker.dart';
import '../widgets/weekdays_selector.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

/// [ReminderSettingsScreen] allows users to configure notifications for a specific habit.
class ReminderSettingsScreen extends ConsumerStatefulWidget {
  /// The ID of the habit to configure reminders for.
  final String habitId;

  /// Creates a [ReminderSettingsScreen].
  const ReminderSettingsScreen({
    super.key,
    required this.habitId,
  });

  @override
  ConsumerState<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends ConsumerState<ReminderSettingsScreen> {
  bool _enabled = true;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  ReminderRepeatType _repeatType = ReminderRepeatType.daily;
  List<int> _weekdays = [1, 2, 3, 4, 5, 6, 7];
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _isInitialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _initialize(HabitReminder? existing) {
    if (_isInitialized) return;
    if (existing != null) {
      _enabled = existing.enabled;
      _time = existing.timeOfDay;
      _repeatType = existing.repeatType;
      _weekdays = List<int>.from(existing.weekdays);
      _titleController.text = existing.notificationTitle;
      _bodyController.text = existing.notificationBody;
    }
    _isInitialized = true;
  }

  Future<void> _save() async {
    // Validation
    if (_enabled && _repeatType == ReminderRepeatType.selectedWeekdays && _weekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day for weekly reminders.')),
      );
      return;
    }

    final existingAsync = ref.read(habitReminderProvider(widget.habitId));
    final existing = existingAsync.value;

    final reminder = HabitReminder(
      id: existing?.id ?? const Uuid().v4(),
      habitId: widget.habitId,
      enabled: _enabled,
      timeOfDay: _time,
      weekdays: _weekdays,
      repeatType: _repeatType,
      notificationTitle: _titleController.text.trim(),
      notificationBody: _bodyController.text.trim(),
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(reminderRepositoryProvider).saveReminder(reminder);
    await ref.read(reminderSchedulerServiceProvider).rescheduleReminder(reminder);
    
    ref.invalidate(habitReminderProvider(widget.habitId));
    ref.invalidate(allRemindersProvider);

    if (mounted) {
      HFFeedback.showSnackBar(context, 'Reminder saved successfully');
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Reminder?'),
        content: const Text('You will no longer receive notifications for this habit.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final existingAsync = ref.read(habitReminderProvider(widget.habitId));
      final existing = existingAsync.value;
      
      if (existing != null) {
        await ref.read(reminderRepositoryProvider).deleteReminder(widget.habitId);
        await ref.read(reminderSchedulerServiceProvider).cancelReminder(existing);
        
        ref.invalidate(habitReminderProvider(widget.habitId));
        ref.invalidate(allRemindersProvider);
      }

      if (mounted) {
        HFFeedback.showSnackBar(context, 'Reminder removed');
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminderAsync = ref.watch(habitReminderProvider(widget.habitId));

    return reminderAsync.when(
      data: (existing) {
        _initialize(existing);
        final theme = Theme.of(context);

        return Scaffold(
          appBar: HFTopAppBar(
            title: 'Reminder Settings',
            actions: [
              if (existing != null)
                IconButton(
                  onPressed: _delete,
                  icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                  tooltip: 'Remove Reminder',
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReminderPreviewCard(
                  enabled: _enabled,
                  time: _time,
                  repeatType: _repeatType,
                  weekdays: _weekdays,
                  title: _titleController.text,
                  body: _bodyController.text,
                ),
                const SizedBox(height: 32),
                
                // Enable/Disable Toggle
                SwitchListTile(
                  title: const Text(
                    'ENABLE REMINDER',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12),
                  ),
                  value: _enabled,
                  onChanged: (val) => setState(() => _enabled = val),
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(height: 32),

                AnimatedOpacity(
                  opacity: _enabled ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !_enabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReminderTimePicker(
                          time: _time,
                          onTimeChanged: (val) => setState(() => _time = val),
                        ),
                        const SizedBox(height: 24),
                        ReminderRepeatSelector(
                          selectedType: _repeatType,
                          onTypeChanged: (val) => setState(() => _repeatType = val),
                        ),
                        if (_repeatType == ReminderRepeatType.selectedWeekdays) ...[
                          const SizedBox(height: 24),
                          WeekdaysSelector(
                            selectedDays: _weekdays,
                            onDaysChanged: (val) => setState(() => _weekdays = val),
                          ),
                        ],
                        const SizedBox(height: 32),
                        const Text(
                          'CUSTOMIZE MESSAGE',
                          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        HFTextField(
                          controller: _titleController,
                          label: 'Notification Title',
                          hintText: 'e.g., Drink water!',
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        HFTextField(
                          controller: _bodyController,
                          label: 'Notification Body',
                          hintText: 'e.g., Keep your streak alive.',
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: HFButton(
                label: 'Save Reminder',
                onPressed: _save,
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: HFLoadingIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
