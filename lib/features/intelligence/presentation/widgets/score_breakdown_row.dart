import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';

class ScoreBreakdownRow extends StatelessWidget {
  final String label;
  final double score;
  final IconData icon;

  const ScoreBreakdownRow({
    super.key,
    required this.label,
    required this.score,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: HFSpacing.s),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(HFSpacing.s),
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: HFSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${score.toInt()}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: HFSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: colorScheme.primary.withAlpha(30),
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
