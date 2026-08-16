import 'package:flutter/material.dart';
import '../../domain/entities/habit_reminder.dart';

/// [ReminderPreviewCard] displays a summary of the current reminder configuration.
class ReminderPreviewCard extends StatelessWidget {
  /// Whether the reminder is enabled.
  final bool enabled;

  /// The reminder time.
  final TimeOfDay time;

  /// The repeat type.
  final ReminderRepeatType repeatType;

  /// Selected weekdays.
  final List<int> weekdays;

  /// Notification title.
  final String title;

  /// Notification body.
  final String body;

  /// Creates a [ReminderPreviewCard].
  const ReminderPreviewCard({
    super.key,
    required this.enabled,
    required this.time,
    required this.repeatType,
    required this.weekdays,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = enabled ? theme.colorScheme.primary : theme.colorScheme.outline;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withAlpha(77),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: color.withAlpha(128)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  enabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                  color: color,
                ),
                const SizedBox(width: 12),
                Text(
                  'Preview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Spacer(),
                if (enabled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              context,
              Icons.schedule_rounded,
              'Trigger Time',
              time.format(context),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              Icons.event_repeat_rounded,
              'Frequency',
              _getRepeatText(),
            ),
            const Divider(height: 32),
            Text(
              title.isEmpty ? 'Time for your habit' : title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              body.isEmpty ? 'Stay consistent and keep your streak alive.' : body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _getRepeatText() {
    switch (repeatType) {
      case ReminderRepeatType.daily:
        return 'Every Day';
      case ReminderRepeatType.once:
        return 'Once';
      case ReminderRepeatType.selectedWeekdays:
        if (weekdays.isEmpty) return 'No days selected';
        if (weekdays.length == 7) return 'Every Day';
        const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return weekdays.map((d) => dayNames[d - 1]).join(', ');
    }
  }
}
