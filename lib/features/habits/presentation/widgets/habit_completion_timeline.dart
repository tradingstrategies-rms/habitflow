import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit_completion.dart';
import '../../../../core/utils/date_time_utils.dart';

class HabitCompletionTimeline extends ConsumerWidget {
  final List<HabitCompletion> completions;

  const HabitCompletionTimeline({
    super.key,
    required this.completions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateTimeUtils = ref.watch(dateTimeUtilsProvider);
    
    final sorted = List<HabitCompletion>.from(completions)
      ..sort((a, b) => b.completionDate.compareTo(a.completionDate));

    if (sorted.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text('History', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        ...sorted.take(5).map((completion) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                dateTimeUtils.formatDate(completion.completionDate),
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              Text(
                'Completed',
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
