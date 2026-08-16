import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/hf_radius.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/goals/domain/entities/goal.dart';
import 'package:habitflow/features/goals/application/providers/goal_providers.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_progress_indicator.dart';
import 'package:habitflow/shared/widgets/foundation/hf_card.dart';
import 'package:habitflow/shared/widgets/foundation/hf_chip.dart';

class GoalCard extends ConsumerWidget {
  final Goal goal;
  final VoidCallback? onTap;

  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(goalProgressProvider(goal));

    return HFCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: HFSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIcon(context),
              const SizedBox(width: HFSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (goal.description.isNotEmpty)
                      Text(
                        goal.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
              ),
              HFChip(
                label: goal.scope.name.toUpperCase(),
              ),
            ],
          ),
          const SizedBox(height: HFSpacing.m),
          progressAsync.when(
            data: (progress) => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${progress.completedValue.toInt()} / ${goal.targetValue.toInt()} ${goal.type.name}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${progress.percentage.toInt()}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: HFSpacing.s),
                GoalProgressIndicator(progress: progress),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (err, stack) => const Text('Error loading progress'),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(HFSpacing.s),
      decoration: BoxDecoration(
        color: Color(goal.colorValue).withAlpha(26),
        borderRadius: BorderRadius.circular(HFRadius.chip),
      ),
      child: Icon(
        _getIconData(goal.iconName),
        color: Color(goal.colorValue),
        size: 20,
        semanticLabel: 'Goal category icon',
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'fitness_center': return Icons.fitness_center_rounded;
      case 'music_note': return Icons.music_note_rounded;
      case 'piano': return Icons.piano_rounded;
      case 'flight_takeoff': return Icons.flight_takeoff_rounded;
      case 'directions_run': return Icons.directions_run_rounded;
      case 'water_drop': return Icons.water_drop_rounded;
      case 'menu_book': return Icons.menu_book_rounded;
      case 'extension': return Icons.extension_rounded;
      case 'rocket_launch': return Icons.rocket_launch_rounded;
      case 'park': return Icons.park_rounded;
      default: return Icons.emoji_events_rounded;
    }
  }
}
