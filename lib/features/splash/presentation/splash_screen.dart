import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';
import 'package:habitflow/features/authentication/data/auth_providers.dart';
import 'package:habitflow/features/profile/data/profile_providers.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

import 'package:habitflow/features/splash/presentation/splash_providers.dart';

/// [SplashScreen] is the initial screen displayed during app launch.
/// 
/// It performs the initial session and profile check before routing.
class SplashScreen extends ConsumerStatefulWidget {
  /// Creates a [SplashScreen].
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    // Artificial delay to show branding (requested in Stitch design flow)
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      ref.read(splashMinTimeReachedProvider.notifier).state = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // We watch the providers here to trigger the GoRouter redirect logic
    // which depends on these providers being active.
    ref.watch(authStateProvider);
    ref.watch(userProfileProvider);

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
