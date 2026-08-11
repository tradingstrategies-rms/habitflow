import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';

class AnalyticsPreviewCard extends ConsumerWidget {
  const AnalyticsPreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HFCard(
      onTap: () => context.pushNamed(RouteNames.analytics),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytics',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(HFOpacity.alpha40),
              ),
            ],
          ),
          const SizedBox(height: HFSpacing.s),
          Text(
            'Track your progress and identify patterns in your habits.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(HFOpacity.alpha60),
            ),
          ),
          const SizedBox(height: HFSpacing.m),
          Row(
            children: [
              Icon(Icons.insights_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: HFSpacing.xs),
              Text(
                'View detailed reports',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
