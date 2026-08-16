import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_provider.dart';

class ChallengeProgressCard extends ConsumerWidget {
  final double currentValue;
  final double targetValue;
  final String unit;
  final Color? progressColor;

  const ChallengeProgressCard({
    super.key,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeProfile = ref.watch(activeProfileProvider);
    final isKids = activeProfile?.profileType == ProfileType.child;

    final progress = (currentValue / targetValue).clamp(0.0, 1.0);
    final color = progressColor ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isKids 
                  ? '${currentValue.toInt()} of ${targetValue.toInt()} $unit' 
                  : '${currentValue.toInt()} / ${targetValue.toInt()} $unit',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isKids ? 18 : null,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: isKids ? 16 : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(isKids ? 12 : 8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: isKids ? 16 : 12,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        if (isKids && progress >= 0.8 && progress < 1.0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Almost there! You can do it!',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

