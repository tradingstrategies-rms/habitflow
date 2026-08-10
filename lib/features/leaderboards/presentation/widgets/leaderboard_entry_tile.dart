import 'package:flutter/material.dart';
import '../../domain/entities/leaderboard_entry.dart';
import 'rank_badge.dart';
import 'package:habitflow/features/family/presentation/widgets/member_avatar.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';

class LeaderboardEntryTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const LeaderboardEntryTile({
    super.key,
    required this.entry,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? theme.colorScheme.primary.withAlpha(20)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser 
            ? Border.all(color: theme.colorScheme.primary.withAlpha(50))
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RankBadge(rank: entry.rank),
            const SizedBox(width: 12),
            MemberAvatar(
              profileType: ProfileType.adult, // Fallback if not specified in entry
              avatarUrl: entry.avatarUrl,
              radius: 18,
            ),
          ],
        ),
        title: Text(
          entry.displayName,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
            color: isCurrentUser ? theme.colorScheme.primary : null,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.score}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'XP',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
