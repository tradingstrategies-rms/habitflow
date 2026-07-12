import 'package:flutter/material.dart';

/// [HFIconButton] is a standardized icon button component.
/// 
/// ### Example Usage:
/// ```dart
/// HFIconButton(
///   icon: Icons.settings,
///   onPressed: () => print('Settings'),
///   tooltip: 'Settings',
/// )
/// ```
class HFIconButton extends StatelessWidget {
  /// Creates an [HFIconButton].
  const HFIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });

  /// The icon to display.
  final IconData icon;

  /// Callback when the button is tapped.
  final VoidCallback? onPressed;

  /// Optional text that describes the action that will occur when the button is pressed.
  final String? tooltip;

  /// Optional color for the icon. Defaults to [ColorScheme.primary].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      color: color ?? Theme.of(context).colorScheme.primary,
      constraints: const BoxConstraints(
        minWidth: 48,
        minHeight: 48,
      ),
    );
  }
}
