import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/otp_input.dart';
import 'widgets/hf_auth_card.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Placeholder for loading state
    const bool isLoading = false;

    return HFLoadingOverlay(
      isLoading: isLoading,
      child: AuthScaffold(
        appBar: HFTopAppBar(
          title: 'HabitFlow',
          centerTitle: true,
          leading: HFIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(HFOpacity.alpha10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.mark_email_unread_rounded,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Check your email',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                children: [
                  const TextSpan(text: 'We\'ve sent a 4-digit verification code to '),
                  TextSpan(
                    text: 'hello@user.com',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            HFAuthCard(
              child: Column(
                children: [
                  const OTPInput(length: 4),
                  const SizedBox(height: 32),
                  HFButton(
                    label: 'Verify',
                    onPressed: () {
                      // TODO: Perform verification
                    },
                    icon: Icons.check_circle_rounded,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Didn\'t receive code?',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Resend code
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Resend Code'),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Securely powered by HabitFlow Identity Services',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
