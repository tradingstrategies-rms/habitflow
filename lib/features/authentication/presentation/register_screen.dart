import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/hf_social_login_button.dart';
import 'widgets/hf_password_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create your account',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Join HabitFlow to start your journey of organic growth and vitality.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            const HFTextField(
              label: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person_outline_rounded),
              textInputAction: TextInputAction.next,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            const HFTextField(
              label: 'Email Address',
              hintText: 'email@example.com',
              prefixIcon: Icon(Icons.mail_outline_rounded),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            const HFPasswordField(
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),
            HFButton(
              label: 'Create Account',
              onPressed: () {
                // TODO: Perform registration
              },
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
              label: 'Register with Google',
              onPressed: () {
                // TODO: Google Sign Up
              },
            ),
            const SizedBox(height: 32),
            Text(
              'By clicking "Create Account", you agree to our Terms of Service and Privacy Policy.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to Sign In
                  },
                  child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
