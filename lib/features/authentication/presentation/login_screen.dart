import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_header.dart';
import 'widgets/hf_social_login_button.dart';
import 'widgets/hf_password_field.dart';
import 'widgets/hf_auth_card.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Placeholder for loading state
    const bool isLoading = false;

    return HFLoadingOverlay(
      isLoading: isLoading,
      child: AuthScaffold(
        body: Column(
          children: [
            const AuthHeader(
              title: 'HabitFlow',
              subtitle: 'Your journey to organic growth and personal vitality starts here.',
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
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const HFPasswordField(
                        textInputAction: TextInputAction.done,
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to Forgot Password
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  HFButton(
                    label: 'Login',
                    onPressed: () {
                      // TODO: Perform login
                    },
                    icon: Icons.arrow_forward_rounded,
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  HFSocialLoginButton(
                    label: 'Continue with Google',
                    onPressed: () {
                      // TODO: Google Sign In
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account?',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to Register
                  },
                  child: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
