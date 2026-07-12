import 'package:flutter/material.dart';

/// [HFAvatar] displays a profile image or user initials.
/// 
/// ### Example Usage:
/// ```dart
/// HFAvatar(
///   initials: 'JD',
///   size: 48,
///   borderColor: Colors.green,
/// )
/// ```
class HFAvatar extends StatelessWidget {
  /// Creates an [HFAvatar].
  const HFAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 40.0,
    this.borderColor,
    this.semanticsLabel,
  });

  /// The URL of the profile image.
  final String? imageUrl;

  /// Initials to show if the image is missing or fails to load.
  final String? initials;

  /// The diameter of the avatar. Defaults to 40.0.
  final double size;

  /// Optional border color for the avatar circle.
  final Color? borderColor;
  
  /// Optional accessibility label for the avatar.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticsLabel ?? 'Profile picture of ${initials ?? "user"}',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 2)
              : null,
          color: theme.colorScheme.primaryContainer,
        ),
        child: ClipOval(
          child: imageUrl != null
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildInitials(theme),
                )
              : _buildInitials(theme),
        ),
      ),
    );
  }

  Widget _buildInitials(ThemeData theme) {
    return Center(
      child: Text(
        initials?.toUpperCase() ?? '?',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
