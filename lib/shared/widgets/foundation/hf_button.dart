import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';

/// Supported variants for [HFButton].
enum HFButtonVariant { 
  /// Filled button using primary color.
  primary, 
  /// Outlined button using primary color.
  secondary, 
  /// Text-only button.
  text, 
  /// Filled button using error color.
  danger 
}

/// [HFButton] is the primary button component for HabitFlow.
/// 
/// It follows the 16dp radius and 48dp minimum touch target rules.
/// 
/// ### Example Usage:
/// ```dart
/// HFButton(
///   label: 'Save Habit',
///   onPressed: () => print('Saved'),
///   variant: HFButtonVariant.primary,
///   icon: Icons.save,
/// )
/// ```
class HFButton extends StatelessWidget {
  /// Creates an [HFButton].
  const HFButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = HFButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.semanticsLabel,
  });

  /// The text label to display on the button.
  final String label;

  /// The callback that is called when the button is tapped.
  final VoidCallback? onPressed;

  /// The visual variant of the button. Defaults to [HFButtonVariant.primary].
  final HFButtonVariant variant;

  /// Whether to show a loading indicator instead of the label/icon.
  final bool isLoading;

  /// Optional icon to display before the label.
  final IconData? icon;

  /// Whether the button should take up all available horizontal space.
  final bool fullWidth;
  
  /// Optional accessibility label for the button.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    ButtonStyle style;
    switch (variant) {
      case HFButtonVariant.primary:
        style = ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        );
        break;
      case HFButtonVariant.secondary:
        style = OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.primary),
          foregroundColor: theme.colorScheme.primary,
        );
        break;
      case HFButtonVariant.text:
        style = TextButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
        );
        break;
      case HFButtonVariant.danger:
        style = ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
        );
        break;
    }

    style = style.copyWith(
      minimumSize: WidgetStateProperty.all(
        Size(fullWidth ? double.infinity : 0, 56),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    Widget child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2, 
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == HFButtonVariant.secondary || variant == HFButtonVariant.text
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onPrimary,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: HFSpacing.s),
              ],
              Text(label),
            ],
          );

    Widget button;
    switch (variant) {
      case HFButtonVariant.secondary:
        button = OutlinedButton(onPressed: isLoading ? null : onPressed, style: style, child: child);
        break;
      case HFButtonVariant.text:
        button = TextButton(onPressed: isLoading ? null : onPressed, style: style, child: child);
        break;
      default:
        button = ElevatedButton(onPressed: isLoading ? null : onPressed, style: style, child: child);
    }

    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      enabled: onPressed != null && !isLoading,
      child: button,
    );
  }
}
