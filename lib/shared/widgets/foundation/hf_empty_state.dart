import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';
import 'package:habitflow/shared/widgets/foundation/hf_button.dart';

/// [HFEmptyState] is displayed when a screen or list has no content.
/// 
/// ### Example Usage:
/// ```dart
/// HFEmptyState(
///   title: 'No Habits Yet',
///   message: 'Start your journey by adding your first habit.',
///   icon: Icons.add_task,
///   actionLabel: 'Add Habit',
///   onActionPressed: () => print('Add'),
/// )
/// ```
class HFEmptyState extends StatelessWidget {
  /// Creates an [HFEmptyState].
  const HFEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onActionPressed,
    this.semanticsLabel,
  });

  /// The main heading for the empty state.
  final String title;

  /// The supporting message or description.
  final String message;

  /// Optional icon to display above the text.
  final IconData? icon;

  /// Optional label for a call-to-action button.
  final String? actionLabel;

  /// Callback when the action button is pressed.
  final VoidCallback? onActionPressed;
  
  /// Optional accessibility label for the empty state.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticsLabel ?? title,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(HFSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 64,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: HFSpacing.l),
              ],
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: HFSpacing.s),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(HFOpacity.alpha60),
                ),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onActionPressed != null) ...[
                const SizedBox(height: HFSpacing.xl),
                HFButton(
                  label: actionLabel!,
                  onPressed: onActionPressed!,
                  fullWidth: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
