import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/shared/widgets/foundation/hf_button.dart';

class GoalFormActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String saveLabel;
  final bool isLoading;

  const GoalFormActions({
    super.key,
    required this.onCancel,
    required this.onSave,
    required this.saveLabel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: HFButton(
            label: 'Cancel',
            variant: HFButtonVariant.secondary,
            onPressed: onCancel,
            semanticsLabel: 'Cancel goal changes',
          ),
        ),
        const SizedBox(width: HFSpacing.m),
        Expanded(
          child: HFButton(
            label: saveLabel,
            onPressed: isLoading ? null : onSave,
            isLoading: isLoading,
            semanticsLabel: '$saveLabel and close',
          ),
        ),
      ],
    );
  }
}
