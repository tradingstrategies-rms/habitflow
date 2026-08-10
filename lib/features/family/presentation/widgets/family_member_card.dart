import 'package:flutter/material.dart';
import '../../domain/entities/family_profile.dart';
import '../../domain/enums/profile_type.dart';
import '../../domain/enums/family_role.dart';
import 'member_avatar.dart';

class FamilyMemberCard extends StatelessWidget {
  final FamilyProfile profile;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const FamilyMemberCard({
    super.key,
    required this.profile,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdult = profile.profileType == ProfileType.adult;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(128)),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              MemberAvatar(
                avatarUrl: profile.avatarUrl,
                profileType: profile.profileType,
                radius: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _RoleBadge(role: profile.role),
                        if (profile.role == FamilyRole.owner) ...[
                          const SizedBox(width: 8),
                          Text(
                            'Account Owner',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              _LevelBadge(
                level: _getPlaceholderLevel(profile.id),
                isAdult: isAdult,
              ),
              if (profile.role != FamilyRole.owner) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showOptions(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                if (onEdit != null) onEdit!();
              },
            ),
            if (profile.role != FamilyRole.owner)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Profile', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  if (onDelete != null) onDelete!();
                },
              ),
          ],
        ),
      ),
    );
  }

  // Temporary helper to match the design levels
  int _getPlaceholderLevel(String id) {
    if (id == 'owner-1') return 42;
    final hash = id.hashCode.abs();
    return (hash % 50) + 10;
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  final bool isAdult;

  const _LevelBadge({
    required this.level,
    required this.isAdult,
  });

  @override
  Widget build(BuildContext context) {
    final color = isAdult ? const Color(0xFFE8F5E9) : const Color(0xFFE0F2F1);
    final onColor = isAdult ? const Color(0xFF2E7D32) : const Color(0xFF00897B);
    final icon = isAdult ? Icons.eco_outlined : Icons.forest_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: onColor),
          const SizedBox(width: 4),
          Text(
            'LVL $level',
            style: TextStyle(
              color: onColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final FamilyRole role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color backgroundColor;
    Color textColor;

    switch (role) {
      case FamilyRole.owner:
        backgroundColor = theme.colorScheme.primaryContainer;
        textColor = theme.colorScheme.onPrimaryContainer;
        break;
      case FamilyRole.parent:
        backgroundColor = theme.colorScheme.secondaryContainer;
        textColor = theme.colorScheme.onSecondaryContainer;
        break;
      case FamilyRole.adultMember:
        backgroundColor = theme.colorScheme.tertiaryContainer;
        textColor = theme.colorScheme.onTertiaryContainer;
        break;
      case FamilyRole.child:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role.displayName.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
