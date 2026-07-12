import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/shared/widgets/foundation/hf_card.dart';

/// [HFSearchBar] is a standardized search input component.
/// 
/// ### Example Usage:
/// ```dart
/// HFSearchBar(
///   onChanged: (query) => print(query),
///   hintText: 'Search habits...',
/// )
/// ```
class HFSearchBar extends StatelessWidget {
  /// Creates an [HFSearchBar].
  const HFSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
  });

  /// Hint text to display when the search bar is empty.
  final String hintText;

  /// Callback when the search text changes.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return HFCard(
      padding: EdgeInsets.zero,
      elevation: 1,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: HFSpacing.m,
          ),
        ),
      ),
    );
  }
}
