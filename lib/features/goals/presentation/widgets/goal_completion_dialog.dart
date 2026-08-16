import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:habitflow/core/achievements/events/goal_completed_event.dart';
import 'package:habitflow/core/theme/hf_radius.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/shared/widgets/foundation/hf_button.dart';
import 'package:habitflow/shared/widgets/foundation/hf_card.dart';

class GoalCompletionDialog extends StatelessWidget {
  final GoalCompletedEvent event;

  const GoalCompletionDialog({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: HFRadius.dialogBorderRadius),
      child: Padding(
        padding: const EdgeInsets.all(HFSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(HFSpacing.m),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha(77),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: HFSpacing.l),
            Text(
              'Goal Achieved!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HFSpacing.s),
            Text(
              event.goalTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HFSpacing.m),
            HFCard(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              padding: const EdgeInsets.all(HFSpacing.m),
              child: Column(
                children: [
                  Text(
                    event.achievementMessage,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: HFSpacing.s),
                  Text(
                    'Completed on ${DateFormat.yMMMMd().format(event.completedAt)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: HFSpacing.xl),
            HFButton(
              label: 'Continue Growth',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
