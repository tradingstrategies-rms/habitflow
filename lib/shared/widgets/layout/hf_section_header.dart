import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';

/// [HFSectionHeader] is used to label sections in a dashboard or list.
/// 
/// ### Example Usage:
/// ```dart
/// HFSectionHeader(
///   title: 'Active Habits',
///   actionLabel: 'See All',
///   onActionPressed: () => print('See all tapped'),
/// )
/// ```
class HFSectionHeader extends StatelessWidget {
  /// Creates an [HFSectionHeader].
  const HFSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionPressed,
  });

  /// The title text for the section.
  final String title;

  /// Optional label for an action button (e.g., 'View All').
  final String? actionLabel;

  /// Callback when the action button is pressed.
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: HFSpacing.m),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (actionLabel != null && onActionPressed != null)
              TextButton(
                onPressed: onActionPressed,
                child: Text(actionLabel!),
              ),
          ],
        ),
      ),
    );
  }
}
