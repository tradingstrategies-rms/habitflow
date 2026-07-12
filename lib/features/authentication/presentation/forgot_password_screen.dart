import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_header.dart';
import 'widgets/hf_auth_card.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Placeholder for loading state
    const bool isLoading = false;

    return HFLoadingOverlay(
      isLoading: isLoading,
      child: AuthScaffold(
        appBar: HFTopAppBar(
          title: '',
          leading: HFIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            const AuthHeader(
              title: 'Forgot Password?',
              subtitle: 'No worries, it happens. Enter your email and we\'ll send you a link to reset your password.',
              icon: Icons.lock_reset_rounded,
            ),
            const SizedBox(height: 32),
            HFAuthCard(
              child: Column(
                children: [
                  const HFTextField(
                    label: 'Email Address',
                    hintText: 'name@example.com',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofocus: true,
                  ),
                  const SizedBox(height: 24),
                  HFButton(
                    label: 'Reset Password',
                    onPressed: () {
                      // TODO: Perform reset
                    },
                    icon: Icons.send_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to login'),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Having trouble?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Contact support
                  },
                  child: const Text('Contact Support'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
