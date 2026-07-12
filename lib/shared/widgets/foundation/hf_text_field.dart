import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_typography.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';

/// [HFTextField] is the standard text input component for HabitFlow.
/// 
/// It integrates with the Material 3 [InputDecorationTheme] defined in the theme.
/// 
/// ### Example Usage:
/// ```dart
/// HFTextField(
///   label: 'Email Address',
///   hintText: 'user@example.com',
///   keyboardType: TextInputType.emailAddress,
/// )
/// ```
class HFTextField extends StatelessWidget {
  /// Creates an [HFTextField].
  const HFTextField({
    super.key,
    this.controller,
    this.hintText,
    this.label,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.semanticsLabel,
  });

  /// The controller for the text being edited.
  final TextEditingController? controller;

  /// Text that hints what can be entered into the text field.
  final String? hintText;

  /// Optional label displayed above the text field.
  final String? label;

  /// Text that appears below the text field if there is an error.
  final String? errorText;

  /// Whether to hide the text being edited (e.g., for passwords).
  final bool obscureText;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// An icon that appears before the editable part of the text field.
  final Widget? prefixIcon;

  /// An icon that appears after the editable part of the text field.
  final Widget? suffixIcon;

  /// Callback when the text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when the user submits the text (e.g., by pressing 'Enter').
  final ValueChanged<String>? onSubmitted;
  
  /// Optional accessibility label for the input.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticsLabel ?? label,
      textField: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: HFTypography.weightSemiBold,
                color: theme.colorScheme.onSurface.withAlpha(HFOpacity.alpha60),
              ),
            ),
            const SizedBox(height: HFSpacing.s),
          ],
          TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hintText,
              errorText: errorText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
            ),
          ),
        ],
      ),
    );
  }
}
