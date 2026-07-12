import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'widgets/auth_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Placeholder for loading state
    const bool isLoading = false;

    return HFLoadingOverlay(
      isLoading: isLoading,
      child: AuthScaffold(
        body: Column(
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
            const SizedBox(height: 48),
            
            // Headline
            Text(
              'Small Habits.\nBig Futures.',
              style: theme.textTheme.displayMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Tagline
            Text(
              'Nurture your family\'s growth through consistent daily routines and shared goals.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Bento-style preview (Simplified for MVP UI task)
            Row(
              children: [
                Expanded(
                  child: HFCard(
                    elevation: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.park_rounded, color: theme.colorScheme.primary),
                        const SizedBox(height: 8),
                        const HFProgressBar(progress: 0.75),
                        const SizedBox(height: 8),
                        Text('Family Tree', style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: HFCard(
                    elevation: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.stars_rounded, color: Colors.orange),
                        const SizedBox(height: 8),
                        Text(
                          '1,240',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text('Points', style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Action Cluster
            HFButton(
              label: 'Get Started',
              onPressed: () {
                // TODO: Navigate to Register
              },
              icon: Icons.arrow_forward_rounded,
            ),
            const SizedBox(height: 16),
            HFButton(
              label: 'Login',
              onPressed: () {
                // TODO: Navigate to Login
              },
              variant: HFButtonVariant.secondary,
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.help_outline_rounded, size: 18),
                  label: const Text('How it works'),
                ),
                const SizedBox(width: 24),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.info_outline_rounded, size: 18),
                  label: const Text('About Us'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
