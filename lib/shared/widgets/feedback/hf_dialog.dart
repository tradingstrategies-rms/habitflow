import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_radius.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/shared/widgets/foundation/hf_button.dart';

/// [HFDialog] is a standardized modal dialog.
/// 
/// ### Example Usage:
/// ```dart
/// HFDialog.show(
///   context,
///   title: 'Delete Habit',
///   content: 'Are you sure you want to delete this habit?',
///   onConfirm: () => print('Deleted'),
/// )
/// ```
class HFDialog extends StatelessWidget {
  /// Creates an [HFDialog].
  const HFDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
  });

  /// The title of the dialog.
  final String title;

  /// The main content or message of the dialog.
  final String content;

  /// Label for the confirmation button. Defaults to 'Confirm'.
  final String confirmLabel;

  /// Label for the cancellation button. Defaults to 'Cancel'.
  final String cancelLabel;

  /// Callback when the confirmation button is pressed.
  final VoidCallback? onConfirm;

  /// Callback when the cancellation button is pressed.
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HFRadius.dialog),
      ),
      title: Text(
        title,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        content,
        style: theme.textTheme.bodyLarge,
      ),
      actionsPadding: const EdgeInsets.all(HFSpacing.m),
      actions: [
        Row(
          children: [
            Expanded(
              child: HFButton(
                label: cancelLabel,
                onPressed: onCancel ?? () => Navigator.of(context).pop(),
                variant: HFButtonVariant.secondary,
              ),
            ),
            const SizedBox(width: HFSpacing.m),
            Expanded(
              child: HFButton(
                label: confirmLabel,
                onPressed: onConfirm,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Static helper to display the dialog.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String content,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    VoidCallback? onConfirm,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => HFDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
      ),
    );
  }
}
