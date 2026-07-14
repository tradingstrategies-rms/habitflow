import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/router/route_paths.dart';
import 'package:habitflow/features/authentication/data/auth_providers.dart';
import 'package:habitflow/features/authentication/application/auth_controller.dart';
import 'package:habitflow/features/profile/data/profile_providers.dart';
import 'package:habitflow/features/splash/presentation/splash_providers.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

// Modular Routes
import 'routes/splash_routes.dart';
import 'routes/auth_routes.dart';
import 'routes/profile_routes.dart';

// Feature Screens
import 'package:habitflow/features/dashboard/presentation/dashboard_screen.dart';
import 'package:habitflow/features/habits/presentation/habits_screen.dart';
import 'package:habitflow/features/goals/presentation/goals_screen.dart';
import 'package:habitflow/features/rewards/presentation/rewards_screen.dart';
import 'package:habitflow/features/family/presentation/family_screen.dart';
import 'package:habitflow/features/analytics/presentation/analytics_screen.dart';
import 'package:habitflow/features/settings/presentation/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// A list of routes that are accessible without authentication.
final _authRoutes = [
  RoutePaths.welcome,
  RoutePaths.login,
  RoutePaths.register,
  RoutePaths.forgotPassword,
  RoutePaths.emailVerification,
];

/// [RouterRefreshNotifier] listens to authentication and profile changes
/// to trigger GoRouter redirects without recreating the GoRouter instance.
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(userProfileProvider, (_, __) => notifyListeners());
    ref.listen(splashMinTimeReachedProvider, (_, __) => notifyListeners());
  }
}

final routerRefreshNotifierProvider = Provider((ref) => RouterRefreshNotifier(ref));

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    refreshListenable: refreshNotifier,
    debugLogDiagnostics: true,
    routes: [
      ...splashRoutes,
      ...authRoutes,
      ...profileRoutes,
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: RoutePaths.dashboard,
            name: RouteNames.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: RoutePaths.habits,
            name: RouteNames.habits,
            pageBuilder: (context, state) => const NoTransitionPage(child: HabitsScreen()),
          ),
          GoRoute(
            path: RoutePaths.goals,
            name: RouteNames.goals,
            pageBuilder: (context, state) => const NoTransitionPage(child: GoalsScreen()),
          ),
          GoRoute(
            path: RoutePaths.rewards,
            name: RouteNames.rewards,
            pageBuilder: (context, state) => const NoTransitionPage(child: RewardsScreen()),
          ),
          GoRoute(
            path: RoutePaths.family,
            name: RouteNames.family,
            pageBuilder: (context, state) => const NoTransitionPage(child: FamilyScreen()),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.analytics,
        name: RouteNames.analytics,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final profileState = ref.read(userProfileProvider);
      final isSplashTimeReached = ref.read(splashMinTimeReachedProvider);

      final bool onSplash = state.uri.path == RoutePaths.splash;

      // 1. If we are on Splash, wait for minimum branding time AND initial auth load
      if (onSplash) {
        if (!isSplashTimeReached || authState.isLoading) {
          return null;
        }
      }

      final bool isAuthenticated = authState.value != null;
      final bool isAuthRoute = _authRoutes.contains(state.uri.path);

      // 2. Handle Unauthenticated Users
      if (!isAuthenticated) {
        // If not authenticated and trying to access a private route, redirect to Welcome
        if (!isAuthRoute && !onSplash) {
          return RoutePaths.welcome;
        }
        
        // If we just finished splash and not authenticated -> Welcome
        if (onSplash && isSplashTimeReached && !authState.isLoading) {
          return RoutePaths.welcome;
        }
        
        return null; // Stay on welcome/login/register
      }

      // 3. Handle Authenticated Users
      
      // If we are still loading profile, wait (e.g. if we just logged in)
      if (profileState.isLoading) {
        return null;
      }

      final bool hasProfile = profileState.value != null;
      final bool isCreatingProfile = state.uri.path == RoutePaths.createProfile || 
                                   state.uri.path == RoutePaths.avatarSelection;

      // Force profile completion if missing
      if (!hasProfile) {
        if (!isCreatingProfile) {
          return RoutePaths.createProfile;
        }
        return null; // Already on profile creation
      }

      // If user has profile but is on an auth or onboarding route, send to Dashboard
      if (isAuthRoute || isCreatingProfile || onSplash) {
        return RoutePaths.dashboard;
      }

      return null;
    },
  );
});

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  int _getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith(RoutePaths.habits)) return 1;
    if (location.startsWith(RoutePaths.goals)) return 2;
    if (location.startsWith(RoutePaths.rewards)) return 3;
    if (location.startsWith(RoutePaths.family)) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed(RouteNames.dashboard);
        break;
      case 1:
        context.goNamed(RouteNames.habits);
        break;
      case 2:
        context.goNamed(RouteNames.goals);
        break;
      case 3:
        context.goNamed(RouteNames.rewards);
        break;
      case 4:
        context.goNamed(RouteNames.family);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: HFTopAppBar(
        title: 'HabitFlow',
        actions: [
          HFIconButton(
            icon: Icons.logout_rounded,
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
          HFIconButton(
            icon: Icons.person_outline_rounded,
            onPressed: () => context.goNamed(RouteNames.editProfile),
          ),
          HFIconButton(
            icon: Icons.settings_outlined,
            onPressed: () => context.pushNamed(RouteNames.settings),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: HFBottomNavigation(
        currentIndex: _getCurrentIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
      ),
    );
  }
}
