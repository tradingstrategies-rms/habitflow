import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/family/domain/entities/parent_approval.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/enums/family_role.dart';
import 'package:habitflow/features/family/presentation/widgets/member_avatar.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import '../../../../core/utils/date_time_utils.dart';

class ApprovalCard extends ConsumerWidget {
  final ParentApproval approval;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ApprovalCard({
    super.key,
    required this.approval,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habitAsync = ref.watch(habitByIdProvider(approval.habitId));
    final profiles = ref.watch(familyProvider).profiles;
    final childProfile = profiles.firstWhere(
      (p) => p.id == approval.childProfileId,
      orElse: () => FamilyProfile(
        id: approval.childProfileId,
        familyId: '',
        displayName: approval.childName,
        profileType: ProfileType.child,
        role: FamilyRole.child,
        requiresPin: false,
        createdAt: DateTime.now(),
      ),
    );

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            MemberAvatar(
              avatarUrl: childProfile.avatarUrl,
              profileType: ProfileType.child,
              radius: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  habitAsync.when(
                    data: (habit) => Text(
                      habit?.title ?? 'Unknown Habit',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    loading: () => const Text('Loading...'),
                    error: (_, __) => Text('Habit ID: ${approval.habitId}'),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        approval.childName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${ref.watch(dateTimeUtilsProvider).formatTime(approval.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  if (approval.note != null && approval.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      approval.note!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.close_rounded, color: Colors.red),
                  onPressed: onReject,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withAlpha(20),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: const Icon(Icons.check_rounded, color: Colors.green),
                  onPressed: onApprove,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.withAlpha(20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
