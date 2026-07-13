import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';
import 'package:habitflow/features/authentication/application/auth_controller.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/otp_input.dart';
import 'widgets/hf_auth_card.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  Future<void> _resendCode() async {
    await ref.read(authControllerProvider.notifier).sendEmailVerification();
    if (mounted && !ref.read(authControllerProvider).hasError) {
      HFFeedback.showSnackBar(context, 'Verification email sent!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          HFFeedback.showSnackBar(context, error.toString(), isError: true);
        },
      );
    });

    return HFLoadingOverlay(
      isLoading: authState.isLoading,
      child: AuthScaffold(
        appBar: HFTopAppBar(
          title: 'HabitFlow',
          centerTitle: true,
          leading: HFIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => context.pop(),
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
                  OTPInput(
                    length: 4,
                    onCompleted: (code) {
                      // TODO: In Firebase, verification usually works via link, 
                      // but we implement UI for code if using a custom backend or specialized flow.
                      // For Firebase, we usually just poll the user object after they click link.
                      HFFeedback.showSnackBar(context, 'Verifying code: $code');
                    },
                  ),
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
                    onPressed: _resendCode,
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
