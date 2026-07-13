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
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.onTap,
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
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticsLabel ?? label,
      textField: true,
      enabled: enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: HFTypography.weightSemiBold,
                color: enabled 
                    ? theme.colorScheme.onSurface.withAlpha(HFOpacity.alpha60)
                    : theme.colorScheme.onSurface.withAlpha(HFOpacity.alpha40),
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
            enabled: enabled,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            onTap: onTap,
            maxLines: maxLines,
            maxLength: maxLength,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: enabled ? null : theme.colorScheme.onSurface.withAlpha(HFOpacity.alpha40),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              errorText: errorText,
              counterText: '', // Hide default counter if maxLength is used
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
