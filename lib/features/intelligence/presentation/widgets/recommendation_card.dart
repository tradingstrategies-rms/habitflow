import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_radius.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_recommendation.dart';

class RecommendationCard extends StatelessWidget {
  final HabitRecommendation recommendation;
  final VoidCallback? onActionPressed;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Dark green aesthetic as per instructions
    const backgroundColor = Color(0xFF065F46); // Dark Emerald/Green
    const onBackgroundColor = Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(HFSpacing.l),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(HFRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(HFSpacing.s),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(HFSpacing.s),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: HFSpacing.m),
              Expanded(
                child: Text(
                  'RECOMMENDATION',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: onBackgroundColor.withAlpha(180),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: HFSpacing.m),
          Text(
            recommendation.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: onBackgroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: HFSpacing.s),
          Text(
            recommendation.summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: onBackgroundColor.withAlpha(230),
            ),
          ),
          const SizedBox(height: HFSpacing.l),
          Container(
            padding: const EdgeInsets.all(HFSpacing.m),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(HFSpacing.m),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suggested Action',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: onBackgroundColor.withAlpha(150),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: HFSpacing.xs),
                Text(
                  recommendation.suggestedAction,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onBackgroundColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onActionPressed != null) ...[
            const SizedBox(height: HFSpacing.l),
            ElevatedButton(
              onPressed: onActionPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: backgroundColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(HFRadius.button),
                ),
              ),
              child: const Text('Try it Now'),
            ),
          ],
        ],
      ),
    );
  }
}
