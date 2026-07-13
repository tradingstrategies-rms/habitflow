import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_paths.dart';
import 'package:habitflow/features/authentication/data/auth_providers.dart';

/// [AuthGuard] protects routes that require a logged-in user.
class AuthGuard {
  static FutureOr<String?> redirect(BuildContext context, GoRouterState state, WidgetRef ref) {
    // List of public routes that don't require authentication
    final publicRoutes = [
      RoutePaths.splash,
      RoutePaths.welcome,
      RoutePaths.login,
      RoutePaths.register,
      RoutePaths.forgotPassword,
      RoutePaths.emailVerification,
    ];

    final authState = ref.watch(authStateProvider);
    final bool isAuthenticated = authState.value != null;

    if (publicRoutes.contains(state.uri.path)) {
      if (isAuthenticated && state.uri.path != RoutePaths.splash) {
        return RoutePaths.dashboard;
      }
      return null;
    }

    if (!isAuthenticated) {
      return RoutePaths.welcome;
    }

    return null;
  }
}
