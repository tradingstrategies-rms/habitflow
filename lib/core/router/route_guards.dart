import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:habitflow/core/router/route_paths.dart';

/// [AuthGuard] protects routes that require a logged-in user.
class AuthGuard {
  static FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    // List of public routes that don't require authentication
    final publicRoutes = [
      RoutePaths.splash,
      RoutePaths.welcome,
      RoutePaths.login,
      RoutePaths.register,
      RoutePaths.forgotPassword,
      RoutePaths.emailVerification,
    ];

    if (publicRoutes.contains(state.uri.path)) {
      return null;
    }

    // TODO: Implement actual auth logic
    const bool isAuthenticated = false; 
    
    if (!isAuthenticated) {
      return RoutePaths.welcome;
    }
    return null; // ignore: dead_code
  }
}

/// [ParentGuard] protects routes that require parent permissions.
class ParentGuard {
  static FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    // TODO: Implement parent PIN check
    return null;
  }
}

/// [PremiumGuard] protects routes that require a premium subscription.
class PremiumGuard {
  static FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    // TODO: Implement subscription check
    return null;
  }
}
