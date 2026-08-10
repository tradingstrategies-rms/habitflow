import 'package:flutter/material.dart';
import '../../domain/entities/habit_reminder.dart';

/// [ReminderRepeatSelector] allows choosing between daily, weekly, or once repeat types.
class ReminderRepeatSelector extends StatelessWidget {
  /// The currently selected repeat type.
  final ReminderRepeatType selectedType;

  /// Callback when the repeat type changes.
  final ValueChanged<ReminderRepeatType> onTypeChanged;

  /// Creates a [ReminderRepeatSelector].
  const ReminderRepeatSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REPEAT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<ReminderRepeatType>(
            segments: const [
              ButtonSegment(
                value: ReminderRepeatType.daily,
                label: Text('Daily'),
                icon: Icon(Icons.repeat_rounded),
              ),
              ButtonSegment(
                value: ReminderRepeatType.selectedWeekdays,
                label: Text('Weekly'),
                icon: Icon(Icons.calendar_view_week_rounded),
              ),
              ButtonSegment(
                value: ReminderRepeatType.once,
                label: Text('Once'),
                icon: Icon(Icons.event_note_rounded),
              ),
            ],
            selected: {selectedType},
            onSelectionChanged: (Set<ReminderRepeatType> newSelection) {
              onTypeChanged(newSelection.first);
            },
          ),
        ),
      ],
    );
  }
}
