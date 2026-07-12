import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_radius.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';

/// [HFChip] is a compact element used for categories, filters, or tags.
/// 
/// ### Example Usage:
/// ```dart
/// HFChip(
///   label: 'Health',
///   isSelected: true,
///   onTap: () => print('Selected Health'),
/// )
/// ```
class HFChip extends StatelessWidget {
  /// Creates an [HFChip].
  const HFChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.icon,
    this.onTap,
    this.color,
    this.semanticsLabel,
  });

  /// The text label to display.
  final String label;

  /// Whether the chip is currently selected.
  final bool isSelected;

  /// Optional icon to display before the label.
  final IconData? icon;

  /// Callback when the chip is tapped.
  final VoidCallback? onTap;

  /// Optional color for the chip. Defaults to [ColorScheme.secondary].
  final Color? color;
  
  /// Optional accessibility label for the chip.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = color ?? theme.colorScheme.secondary;

    return Semantics(
      label: semanticsLabel ?? label,
      selected: isSelected,
      button: onTap != null,
      child: Material(
        color: isSelected ? baseColor : baseColor.withAlpha(HFOpacity.alpha10),
        borderRadius: BorderRadius.circular(HFRadius.chip),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(HFRadius.chip),
          child: Container(
            constraints: const BoxConstraints(minHeight: 32),
            padding: const EdgeInsets.symmetric(
              horizontal: HFSpacing.m,
              vertical: HFSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : baseColor,
                  ),
                  const SizedBox(width: HFSpacing.xs),
                ],
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected ? Colors.white : baseColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
