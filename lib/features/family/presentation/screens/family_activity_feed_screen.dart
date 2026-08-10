import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/family/domain/entities/family_activity.dart';
import 'package:habitflow/features/family/domain/enums/family_activity_type.dart';
import 'package:habitflow/features/family/presentation/providers/family_activity_provider.dart';
import 'package:habitflow/features/family/presentation/widgets/member_avatar.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';

class FamilyActivityFeedScreen extends ConsumerWidget {
  const FamilyActivityFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(filteredFamilyActivitiesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Activity'),
      ),
      body: Column(
        children: [
          _buildFilters(ref),
          Expanded(
            child: activitiesAsync.when(
              data: (activities) {
                if (activities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        const Text('No activities found.'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(HFSpacing.m),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    return _ActivityItem(activity: activities[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(WidgetRef ref) {
    final currentFilter = ref.watch(familyActivityFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: HFSpacing.m, vertical: HFSpacing.s),
      child: Row(
        children: ActivityFilter.values.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.displayName),
              selected: currentFilter == filter,
              onSelected: (selected) {
                if (selected) {
                  ref.read(familyActivityFilterProvider.notifier).state = filter;
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final FamilyActivity activity;

  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconData = _getIconData(activity.type);
    final iconColor = _getIconColor(activity.type, theme);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(100)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activity.profileName != null)
              MemberAvatar(
                profileType: ProfileType.adult, // Placeholder, can be improved
                avatarUrl: activity.profileAvatarUrl,
                radius: 20,
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.family_restroom, color: theme.colorScheme.primary, size: 20),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(iconData, size: 14, color: iconColor),
                      const SizedBox(width: 6),
                      Text(
                        activity.type.displayName.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimestamp(activity.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activity.description,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  if (_getBadge(activity.type) != null) ...[
                    const SizedBox(height: 8),
                    _buildBadge(context, _getBadge(activity.type)!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(dt);
  }

  IconData _getIconData(FamilyActivityType type) {
    switch (type) {
      case FamilyActivityType.familyCreated: return Icons.home_work_outlined;
      case FamilyActivityType.memberJoined: return Icons.person_add_outlined;
      case FamilyActivityType.childAdded: return Icons.child_care_outlined;
      case FamilyActivityType.sharedHabitCreated: return Icons.checklist_rtl;
      case FamilyActivityType.sharedHabitAssigned: return Icons.assignment_ind_outlined;
      case FamilyActivityType.habitCompleted: return Icons.check_circle_outline;
      case FamilyActivityType.awaitingApproval: return Icons.hourglass_top;
      case FamilyActivityType.completionApproved: return Icons.verified_user_outlined;
      case FamilyActivityType.completionRejected: return Icons.cancel_outlined;
      case FamilyActivityType.streakMilestone: return Icons.trending_up;
      case FamilyActivityType.achievementUnlocked: return Icons.emoji_events_outlined;
    }
  }

  Color _getIconColor(FamilyActivityType type, ThemeData theme) {
    switch (type) {
      case FamilyActivityType.habitCompleted:
      case FamilyActivityType.completionApproved:
        return Colors.green;
      case FamilyActivityType.completionRejected:
        return theme.colorScheme.error;
      case FamilyActivityType.awaitingApproval:
        return theme.colorScheme.secondary;
      case FamilyActivityType.sharedHabitCreated:
        return Colors.orange;
      case FamilyActivityType.achievementUnlocked:
        return theme.colorScheme.tertiary;
      default:
        return theme.colorScheme.primary;
    }
  }

  String? _getBadge(FamilyActivityType type) {
    switch (type) {
      case FamilyActivityType.sharedHabitCreated:
      case FamilyActivityType.sharedHabitAssigned:
        return 'SHARED';
      case FamilyActivityType.awaitingApproval:
        return 'APPROVAL';
      case FamilyActivityType.achievementUnlocked:
        return 'ACHIEVEMENT';
      default:
        return null;
    }
  }

  Widget _buildBadge(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
