import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

/// [SplashScreen] is the initial screen displayed during app launch.
class SplashScreen extends StatelessWidget {
  /// Creates a [SplashScreen].
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Container with Stitch-inspired rounding (24dp)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(HFOpacity.alpha20),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Image.asset(
                'assets/images/branding/logo.png',
                width: 64,
                height: 64,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.eco_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Brand Title
            Text(
              'HabitFlow',
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            // Tagline
            Text(
              'Organic Growth. Personal Vitality.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 48),
            const HFLoadingIndicator(),
          ],
        ),
      ),
    );
  }
}
