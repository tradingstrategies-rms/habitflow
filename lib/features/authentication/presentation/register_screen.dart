import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/utils/validators.dart';
import 'package:habitflow/features/authentication/application/auth_controller.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/hf_social_login_button.dart';
import 'widgets/hf_password_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _nameError = Validators.validateName(_nameController.text);
      _emailError = Validators.validateEmail(_emailController.text);
      _passwordError = Validators.validatePassword(_passwordController.text);
      _confirmPasswordError = Validators.validateConfirmPassword(
        _confirmPasswordController.text,
        _passwordController.text,
      );
    });

    if (_nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null) {
      await ref.read(authControllerProvider.notifier).register(
            _emailController.text,
            _passwordController.text,
          );
      // Note: In real app, we might save the name to Firestore after registration.
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
            HFTextField(
              controller: _nameController,
              label: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              textInputAction: TextInputAction.next,
              errorText: _nameError,
              onChanged: (_) => setState(() => _nameError = null),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            HFTextField(
              controller: _emailController,
              label: 'Email Address',
              hintText: 'email@example.com',
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              errorText: _emailError,
              onChanged: (_) => setState(() => _emailError = null),
            ),
            const SizedBox(height: 16),
            HFPasswordField(
              controller: _passwordController,
              textInputAction: TextInputAction.next,
              errorText: _passwordError,
              onChanged: (_) => setState(() => _passwordError = null),
            ),
            const SizedBox(height: 16),
            HFPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hintText: 'Re-enter password',
              textInputAction: TextInputAction.done,
              errorText: _confirmPasswordError,
              onChanged: (_) => setState(() => _confirmPasswordError = null),
              onSubmitted: (_) => _register(),
            ),
            const SizedBox(height: 32),
            HFButton(
              label: 'Create Account',
              onPressed: _register,
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
              onPressed: () => ref.read(authControllerProvider.notifier).loginWithGoogle(),
            ),
            const SizedBox(height: 12),
            HFSocialLoginButton(
              label: 'Register with Apple',
              icon: Icons.apple_rounded,
              onPressed: () => ref.read(authControllerProvider.notifier).loginWithApple(),
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
                  onPressed: () => context.pop(),
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
