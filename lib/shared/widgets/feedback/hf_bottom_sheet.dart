import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_radius.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';

/// [HFBottomSheet] is a standardized bottom sheet component.
/// 
/// ### Example Usage:
/// ```dart
/// HFBottomSheet.show(
///   context,
///   title: 'Habit Details',
///   child: Text('More information about the habit...'),
/// )
/// ```
class HFBottomSheet extends StatelessWidget {
  /// Creates an [HFBottomSheet].
  const HFBottomSheet({
    super.key,
    required this.title,
    required this.child,
  });

  /// The title displayed at the top of the sheet.
  final String title;

  /// The widget content to display inside the sheet.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HFSpacing.l,
        vertical: HFSpacing.l,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(HFRadius.dialog),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withAlpha(HFOpacity.alpha20),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: HFSpacing.l),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: HFSpacing.l),
          Flexible(child: child),
        ],
      ),
    );
  }

  /// Static helper to display the bottom sheet.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HFBottomSheet(title: title, child: child),
    );
  }
}
