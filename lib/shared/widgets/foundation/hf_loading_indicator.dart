import 'package:flutter/material.dart';

/// [HFLoadingIndicator] is a centered, standardized loading spinner.
/// 
/// ### Example Usage:
/// ```dart
/// HFLoadingIndicator(size: 32)
/// ```
class HFLoadingIndicator extends StatelessWidget {
  /// Creates an [HFLoadingIndicator].
  const HFLoadingIndicator({
    super.key,
    this.size = 24.0,
    this.semanticsLabel,
  });

  /// The size of the indicator. Defaults to 24.0.
  final double size;
  
  /// Optional accessibility label for the indicator.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? 'Loading',
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}
