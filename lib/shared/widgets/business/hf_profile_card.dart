import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';
import 'package:habitflow/shared/widgets/foundation/hf_card.dart';
import 'package:habitflow/shared/widgets/foundation/hf_avatar.dart';

/// [HFProfileCard] displays a summary of the user's profile.
/// 
/// ### Example Usage:
/// ```dart
/// HFProfileCard(
///   name: 'John Doe',
///   email: 'john@example.com',
///   onTap: () => print('Profile tapped'),
/// )
/// ```
class HFProfileCard extends StatelessWidget {
  /// Creates an [HFProfileCard].
  const HFProfileCard({
    super.key,
    required this.name,
    required this.email,
    this.imageUrl,
    this.onTap,
  });

  /// The user's full name.
  final String name;

  /// The user's email address.
  final String email;

  /// Optional URL for the profile image.
  final String? imageUrl;

  /// Optional callback when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HFCard(
      onTap: onTap,
      child: Row(
        children: [
          HFAvatar(
            imageUrl: imageUrl,
            initials: name.isNotEmpty ? name[0] : '?',
            size: 60,
          ),
          const SizedBox(width: HFSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(HFOpacity.alpha60),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline),
        ],
      ),
    );
  }
}
