import 'package:flutter/material.dart';
import 'package:habitflow/core/progress/models/progress_summary.dart';
import 'package:habitflow/shared/widgets/foundation/hf_progress_bar.dart';

enum GoalProgressType { linear, circular }

class GoalProgressIndicator extends StatelessWidget {
  final ProgressSummary progress;
  final GoalProgressType type;
  final double? size;
  final double strokeWidth;

  const GoalProgressIndicator({
    super.key,
    required this.progress,
    this.type = GoalProgressType.linear,
    this.size,
    this.strokeWidth = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final double normalizedProgress = progress.percentage / 100.0;

    if (type == GoalProgressType.circular) {
      return Semantics(
        label: 'Goal progress',
        value: '${progress.percentage.toInt()}%',
        child: SizedBox(
          width: size ?? 64,
          height: size ?? 64,
          child: CircularProgressIndicator(
            value: normalizedProgress,
            strokeWidth: strokeWidth,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            strokeCap: StrokeCap.round,
          ),
        ),
      );
    }

    return HFProgressBar(
      progress: normalizedProgress,
      height: strokeWidth,
    );
  }
}
