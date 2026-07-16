import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_paths.dart';
import 'package:habitflow/core/utils/validators.dart';
import 'package:habitflow/features/authentication/application/auth_controller.dart';
import 'package:habitflow/features/authentication/domain/auth_failures.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_header.dart';
import 'widgets/hf_auth_card.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    setState(() {
      _emailError = Validators.validateEmail(_emailController.text);
    });

    if (_emailError == null) {
      await ref.read(authControllerProvider.notifier).sendPasswordResetEmail(
            _emailController.text,
          );
      if (mounted && !ref.read(authControllerProvider).hasError) {
        HFFeedback.showSnackBar(context, 'Reset link sent! Check your email.');
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RoutePaths.dashboard);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

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
        appBar: HFTopAppBar(
          title: '',
          leading: HFIconButton(
            icon: Icons.arrow_back_rounded,
                        onPressed: authState.isLoading ? null : () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RoutePaths.dashboard);
              }
            },
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
                  HFTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hintText: 'name@example.com',
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    errorText: _emailError,
                    enabled: !authState.isLoading,
                    onChanged: (_) => setState(() => _emailError = null),
                    onSubmitted: (_) => _resetPassword(),
                    autofocus: true,
                  ),
                  const SizedBox(height: 24),
                  HFButton(
                    label: 'Reset Password',
                    onPressed: _resetPassword,
                    isLoading: authState.isLoading,
                    icon: Icons.send_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: authState.isLoading ? null : () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RoutePaths.dashboard);
                }
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
                  onPressed: authState.isLoading ? null : () {
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
