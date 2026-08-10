import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_progress_indicator.dart';
import 'package:habitflow/features/goals/application/providers/goal_summary_provider.dart';
import 'package:habitflow/features/goals/application/providers/goal_providers.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class DashboardGoalSummary extends ConsumerWidget {
  const DashboardGoalSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(activeGoalSummariesProvider);

    return HFCard(
      elevation: 0,
      color: Colors.transparent,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HFSectionHeader(
            title: 'Current Goals',
          ),
          const SizedBox(height: HFSpacing.s),
          summariesAsync.when(
            data: (summaries) {
              if (summaries.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: HFSpacing.m),
                  child: Text('No active goals. Start something new!'),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: summaries.length,
                separatorBuilder: (context, index) => const SizedBox(height: HFSpacing.m),
                itemBuilder: (context, index) {
                  final summary = summaries[index];
                  return _CompactGoalCard(summary: summary);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }
}

class _CompactGoalCard extends ConsumerWidget {
  final GoalSummary summary;

  const _CompactGoalCard({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HFCard(
      semanticsLabel: 'Goal: ${summary.goal.title}',
      onTap: () {
        ref.read(goalControllerProvider.notifier).selectGoal(summary.goal);
        context.pushNamed(
          RouteNames.goalDetails,
          pathParameters: {'goalId': summary.goal.id},
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIcon(context),
              const SizedBox(width: HFSpacing.sm),
              Expanded(
                child: Text(
                  summary.goal.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Text(
                '${summary.percentage.toInt()}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: HFSpacing.s),
          GoalProgressIndicator(
            progress: summary.progress,
            strokeWidth: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Icon(
      _getIconData(summary.goal.iconName),
      color: Color(summary.goal.colorValue),
      size: 18,
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
