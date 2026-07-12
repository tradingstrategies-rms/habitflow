import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';

/// [HFDivider] is a standardized divider for logical separation in layouts.
/// 
/// ### Example Usage:
/// ```dart
/// HFDivider(height: 32)
/// ```
class HFDivider extends StatelessWidget {
  /// Creates an [HFDivider].
  const HFDivider({
    super.key,
    this.height = HFSpacing.l,
    this.thickness = 1.0,
    this.color,
  });

  /// The total height of the divider space. Defaults to [HFSpacing.l] (24dp).
  final double height;

  /// The thickness of the divider line. Defaults to 1.0.
  final double thickness;

  /// Optional color for the divider line.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: thickness,
      color: color ?? Theme.of(context).colorScheme.outline.withAlpha(HFOpacity.alpha20),
    );
  }
}
