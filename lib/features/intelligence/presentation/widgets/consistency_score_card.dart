import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_consistency_score.dart';
import 'score_breakdown_row.dart';

class ConsistencyScoreCard extends StatefulWidget {
  final HabitConsistencyScore score;

  const ConsistencyScoreCard({
    super.key,
    required this.score,
  });

  @override
  State<ConsistencyScoreCard> createState() => _ConsistencyScoreCardState();
}

class _ConsistencyScoreCardState extends State<ConsistencyScoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.score.overallScore).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ConsistencyScoreCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score.overallScore != widget.score.overallScore) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.score.overallScore,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getScoreDescriptor(double score) {
    if (score >= 90) return 'Exceptional';
    if (score >= 80) return 'Excellent';
    if (score >= 70) return 'Great';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Developing';
    return 'Starting Out';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(HFSpacing.l),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Wellness Score',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: HFSpacing.xs),
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Text(
                            '${_animation.value.toInt()}',
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: HFSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: HFSpacing.s, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withAlpha(100),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getScoreDescriptor(_animation.value),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return CircularProgressIndicator(
                            value: _animation.value / 100,
                            strokeWidth: 10,
                            strokeCap: StrokeCap.round,
                            backgroundColor: colorScheme.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: HFSpacing.l),
            Divider(color: colorScheme.outlineVariant.withAlpha(50)),
            const SizedBox(height: HFSpacing.s),
            ScoreBreakdownRow(
              label: 'Completion',
              score: widget.score.completionScore,
              icon: Icons.check_circle_outline,
            ),
            ScoreBreakdownRow(
              label: 'Streak',
              score: widget.score.streakScore,
              icon: Icons.local_fire_department_outlined,
            ),
            ScoreBreakdownRow(
              label: 'Stability',
              score: widget.score.stabilityScore,
              icon: Icons.auto_graph_outlined,
            ),
            ScoreBreakdownRow(
              label: 'Recovery',
              score: widget.score.recoveryScore,
              icon: Icons.rebase_edit,
            ),
          ],
        ),
      ),
    );
  }
}
