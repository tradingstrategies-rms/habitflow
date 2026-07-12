import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/router/route_paths.dart';
import 'package:habitflow/features/authentication/presentation/welcome_screen.dart';
import 'package:habitflow/features/authentication/presentation/login_screen.dart';
import 'package:habitflow/features/authentication/presentation/register_screen.dart';
import 'package:habitflow/features/authentication/presentation/forgot_password_screen.dart';
import 'package:habitflow/features/authentication/presentation/email_verification_screen.dart';

final authRoutes = [
  GoRoute(
    path: RoutePaths.welcome,
    name: RouteNames.welcome,
    builder: (context, state) => const WelcomeScreen(),
  ),
  GoRoute(
    path: RoutePaths.login,
    name: RouteNames.login,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: RoutePaths.register,
    name: RouteNames.register,
    builder: (context, state) => const RegisterScreen(),
  ),
  GoRoute(
    path: RoutePaths.forgotPassword,
    name: RouteNames.forgotPassword,
    builder: (context, state) => const ForgotPasswordScreen(),
  ),
  GoRoute(
    path: RoutePaths.emailVerification,
    name: RouteNames.emailVerification,
    builder: (context, state) => const EmailVerificationScreen(),
  ),
];
