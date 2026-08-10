import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_provider.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/challenge_progress.dart';
import 'challenge_badge.dart';
import 'challenge_progress_card.dart';

class ChallengeCard extends ConsumerWidget {
  final Challenge challenge;
  final ChallengeProgress? progress;
  final VoidCallback? onTap;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeProfile = ref.watch(activeProfileProvider);
    final isKids = activeProfile?.profileType == ProfileType.child;
    final isCompleted = progress?.isCompleted ?? false;

    return Card(
      elevation: isKids ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isKids ? 32 : 24),
        side: BorderSide(
          color: isCompleted 
              ? Colors.green.withAlpha(100)
              : theme.colorScheme.outlineVariant.withAlpha(80),
          width: (isCompleted || isKids) ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isKids ? 32 : 24),
        child: Padding(
          padding: EdgeInsets.all(isKids ? 24 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isKids ? 20 : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ChallengeBadge(type: challenge.type),
                            const SizedBox(width: 8),
                            ChallengeBadge(difficulty: challenge.difficulty),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    const Icon(Icons.check_circle, color: Colors.green, size: 28)
                  else if (isKids)
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 28)
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                isKids ? _simplifyDescription(challenge.description) : challenge.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: isKids ? 14 : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              ChallengeProgressCard(
                currentValue: progress?.currentValue ?? 0,
                targetValue: challenge.targetValue,
                unit: challenge.unit,
                progressColor: isCompleted ? Colors.green : null,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '+${challenge.pointReward}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                      fontSize: isKids ? 14 : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.bolt_rounded, color: Colors.blue, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '+${challenge.xpReward} XP',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                      fontSize: isKids ? 14 : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _simplifyDescription(String description) {
    // For now just returning as is, but could have a mapping or AI simplification
    return description;
  }
}

