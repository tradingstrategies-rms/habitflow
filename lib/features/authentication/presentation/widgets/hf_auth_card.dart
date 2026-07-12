import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

/// [HFAuthCard] is a reusable glass-style container for authentication forms.
class HFAuthCard extends StatelessWidget {
  const HFAuthCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return HFCard(
      elevation: 2,
      padding: padding,
      // Glass effect using surface color with low alpha if theme allows,
      // but strictly adhering to our HFDS established previously.
      child: child,
    );
  }
}
