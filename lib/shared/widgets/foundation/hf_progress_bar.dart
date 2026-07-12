import 'package:flutter/material.dart';

/// [HFProgressBar] is a rounded progress indicator.
/// 
/// ### Example Usage:
/// ```dart
/// HFProgressBar(
///   progress: 0.75,
///   height: 12,
///   color: Colors.emerald,
/// )
/// ```
class HFProgressBar extends StatelessWidget {
  /// Creates an [HFProgressBar].
  const HFProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
    this.color,
    this.backgroundColor,
    this.semanticsLabel,
  });

  /// The progress value between 0.0 and 1.0.
  final double progress;

  /// The height of the progress bar. Defaults to 8.0.
  final double height;

  /// The color of the progress indicator. Defaults to [ColorScheme.primary].
  final Color? color;

  /// The background color of the bar. Defaults to [ColorScheme.surfaceContainerHighest].
  final Color? backgroundColor;
  
  /// Optional accessibility label for the progress bar.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticsLabel ?? 'Progress bar',
      value: '${(progress * 100).toInt()}%',
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: color ?? theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
      ),
    );
  }
}
