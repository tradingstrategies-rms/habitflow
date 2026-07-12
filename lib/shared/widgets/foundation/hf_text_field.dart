import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_typography.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';

/// [HFTextField] is the standard text input component for HabitFlow.
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
    this.textInputAction,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.semanticsLabel,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? label;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? semanticsLabel;
  final bool autofocus;

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
            textInputAction: textInputAction,
            focusNode: focusNode,
            autofocus: autofocus,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hintText,
              errorText: errorText,
              // Force error text space reservation to avoid jumps
              helperText: errorText == null ? '' : null,
              helperStyle: const TextStyle(height: 0.8),
              errorStyle: const TextStyle(height: 0.8),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
            ),
          ),
        ],
      ),
    );
  }
}
