import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';
import 'package:habitflow/shared/widgets/foundation/hf_card.dart';

/// [HFQuoteCard] displays a motivational quote.
/// 
/// ### Example Usage:
/// ```dart
/// HFQuoteCard(
///   quote: 'The journey of a thousand miles begins with a single step.',
///   author: 'Lao Tzu',
/// )
/// ```
class HFQuoteCard extends StatelessWidget {
  /// Creates an [HFQuoteCard].
  const HFQuoteCard({
    super.key,
    required this.quote,
    required this.author,
  });

  /// The text of the quote.
  final String quote;

  /// The author of the quote.
  final String author;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HFCard(
      color: theme.colorScheme.primary.withAlpha(HFOpacity.alpha05),
      child: Column(
        children: [
          Icon(Icons.format_quote_rounded, color: theme.colorScheme.primary, size: 32),
          const SizedBox(height: HFSpacing.s),
          Text(
            quote,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: HFSpacing.m),
          Text(
            '- $author',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
