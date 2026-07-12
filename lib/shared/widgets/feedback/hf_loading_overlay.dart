import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';
import 'package:habitflow/shared/widgets/foundation/hf_loading_indicator.dart';

/// [HFLoadingOverlay] blocks user interaction with a loading spinner.
/// 
/// ### Example Usage:
/// ```dart
/// HFLoadingOverlay(
///   isLoading: _isSaving,
///   child: MyScreenContent(),
/// )
/// ```
class HFLoadingOverlay extends StatelessWidget {
  /// Creates an [HFLoadingOverlay].
  const HFLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  /// Whether to show the loading overlay.
  final bool isLoading;

  /// The widget to display beneath the overlay.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withAlpha(HFOpacity.alpha40),
            child: const HFLoadingIndicator(size: 48),
          ),
      ],
    );
  }
}
