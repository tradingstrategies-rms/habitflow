import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';

/// [AuthHeader] displays the branding and title for authentication screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.eco_rounded,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(HFSpacing.m),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withAlpha(HFOpacity.alpha20),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Image.asset(
            'assets/images/branding/logo.png',
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) => Icon(
              icon,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: HFSpacing.l),
        Text(
          title,
          style: theme.textTheme.displaySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: HFSpacing.s),
          Text(
            subtitle!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
