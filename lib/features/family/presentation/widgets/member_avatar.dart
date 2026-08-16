import 'package:flutter/material.dart';
import '../../domain/enums/profile_type.dart';

class MemberAvatar extends StatelessWidget {
  final String? avatarUrl;
  final ProfileType profileType;
  final double radius;

  const MemberAvatar({
    super.key,
    this.avatarUrl,
    required this.profileType,
    this.radius = 32,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdult = profileType == ProfileType.adult;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.primary.withAlpha(128),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: theme.colorScheme.surfaceVariant,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Icon(
                    Icons.person,
                    size: radius,
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isAdult ? const Color(0xFF1B5E20) : const Color(0xFFFFB300),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              isAdult ? Icons.shield : Icons.star,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
