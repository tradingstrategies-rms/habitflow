import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';
import 'package:habitflow/shared/widgets/foundation/hf_card.dart';

/// [HFHabitTile] represents a single habit in a list view.
/// 
/// It includes a completion toggle and streak information.
/// 
/// ### Example Usage:
/// ```dart
/// HFHabitTile(
///   title: 'Exercise',
///   isCompleted: false,
///   streakCount: 5,
///   onToggle: () => print('Toggled'),
/// )
/// ```
class HFHabitTile extends StatelessWidget {
  /// Creates an [HFHabitTile].
  const HFHabitTile({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.streakCount,
    this.onToggle,
    this.onTap,
    this.color,
  });

  /// The title of the habit.
  final String title;

  /// Whether the habit is marked as completed for today.
  final bool isCompleted;

  /// The current streak count for this habit.
  final int streakCount;

  /// Callback when the completion checkbox is tapped.
  final VoidCallback? onToggle;

  /// Callback when the tile itself is tapped.
  final VoidCallback? onTap;

  /// Optional color for the habit indicator. Defaults to [ColorScheme.primary].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habitColor = color ?? theme.colorScheme.primary;

    return HFCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: HFSpacing.m,
        vertical: HFSpacing.s,
      ),
      margin: const EdgeInsets.only(bottom: HFSpacing.s),
      child: Row(
        children: [
          Semantics(
            label: isCompleted ? 'Mark as incomplete' : 'Mark as complete',
            button: true,
            child: GestureDetector(
              key: const Key('habit_tile_toggle'),
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 48, // 48dp touch target
                height: 48, // 48dp touch target
                alignment: Alignment.center,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted ? habitColor : theme.colorScheme.outline,
                      width: 2,
                    ),
                    color: isCompleted ? habitColor : Colors.transparent,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 20, color: Colors.white)
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: HFSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted 
                      ? theme.colorScheme.onSurface.withAlpha(HFOpacity.alpha40) 
                      : null,
                  ),
                ),
                Text(
                  '$streakCount day streak',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(HFOpacity.alpha60),
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'Streak count',
            value: streakCount.toString(),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: streakCount > 0 ? Colors.orange : theme.colorScheme.outline,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
