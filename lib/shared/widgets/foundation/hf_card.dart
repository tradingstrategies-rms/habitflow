import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_radius.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_shadows.dart';

/// [HFCard] is the foundational surface component for HabitFlow.
/// 
/// It provides a 20dp rounded surface with standardized shadows.
/// 
/// ### Example Usage:
/// ```dart
/// HFCard(
///   elevation: 1,
///   onTap: () => print('Card tapped'),
///   child: Text('Habit Content'),
/// )
/// ```
class HFCard extends StatelessWidget {
  /// Creates an [HFCard].
  const HFCard({
    super.key,
    required this.child,
    this.elevation = 1,
    this.padding = const EdgeInsets.all(HFSpacing.ml),
    this.margin,
    this.onTap,
    this.color,
    this.border,
    this.semanticsLabel,
  });

  /// The widget to display inside the card.
  final Widget child;

  /// The elevation level (0, 1, 2, or 3). Defaults to 1.
  final int elevation;

  /// The internal padding of the card. Defaults to [HFSpacing.ml] (20dp).
  final EdgeInsetsGeometry padding;

  /// The external margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Optional callback for when the card is tapped.
  final VoidCallback? onTap;

  /// Optional background color. Defaults to [ThemeData.cardTheme.color].
  final Color? color;

  /// Optional border side.
  final BorderSide? border;

  /// Optional accessibility label for the card.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    List<BoxShadow> shadows;
    switch (elevation) {
      case 2:
        shadows = HFShadows.medium;
        break;
      case 3:
        shadows = HFShadows.heavy;
        break;
      case 0:
        shadows = [];
        break;
      default:
        shadows = HFShadows.light;
    }

    return Semantics(
      label: semanticsLabel,
      container: true,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: color ?? theme.cardTheme.color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(HFRadius.card),
          border: border != null ? Border.fromBorderSide(border!) : null,
          boxShadow: shadows,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(HFRadius.card),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
