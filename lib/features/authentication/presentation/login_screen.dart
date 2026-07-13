import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/utils/validators.dart';
import 'package:habitflow/features/authentication/application/auth_controller.dart';
import 'package:habitflow/features/authentication/domain/auth_failures.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_header.dart';
import 'widgets/hf_social_login_button.dart';
import 'widgets/hf_password_field.dart';
import 'widgets/hf_auth_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _emailError = Validators.validateEmail(_emailController.text);
      _passwordError = Validators.validatePassword(_passwordController.text);
    });

    if (_emailError == null && _passwordError == null) {
      await ref.read(authControllerProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    // Listen for errors
    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          final message = error is AuthFailure ? error.message : error.toString();
          HFFeedback.showSnackBar(context, message, isError: true);
        },
      );
    });

    return HFLoadingOverlay(
      isLoading: authState.isLoading,
      child: AuthScaffold(
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              const AuthHeader(
                title: 'HabitFlow',
                subtitle: 'Your journey to organic growth and personal vitality starts here.',
              ),
              const SizedBox(height: 32),
              HFAuthCard(
                child: Column(
                  children: [
                    HFTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hintText: 'name@example.com',
                      prefixIcon: const Icon(Icons.mail_outline_rounded),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      errorText: _emailError,
                      enabled: !authState.isLoading,
                      onChanged: (_) => setState(() => _emailError = null),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        HFPasswordField(
                          controller: _passwordController,
                          textInputAction: TextInputAction.done,
                          errorText: _passwordError,
                          enabled: !authState.isLoading,
                          onChanged: (_) => setState(() => _passwordError = null),
                          onSubmitted: (_) => _login(),
                        ),
                        TextButton(
                          onPressed: authState.isLoading 
                              ? null 
                              : () => context.pushNamed(RouteNames.forgotPassword),
                          child: const Text('Forgot Password?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    HFButton(
                      label: 'Login',
                      onPressed: _login,
                      isLoading: authState.isLoading,
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
                    onPressed: authState.isLoading 
                        ? null 
                        : () => ref.read(authControllerProvider.notifier).loginWithGoogle(),
                  ),
                  const SizedBox(height: 12),
                  HFSocialLoginButton(
                    label: 'Continue with Apple',
                    icon: Icons.apple_rounded,
                    onPressed: authState.isLoading 
                        ? null 
                        : () => ref.read(authControllerProvider.notifier).loginWithApple(),
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
                    onPressed: authState.isLoading 
                        ? null 
                        : () => context.pushNamed(RouteNames.register),
                    child: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
