import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/router/route_paths.dart';
import 'package:habitflow/core/router/route_guards.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

// Screens
import 'package:habitflow/features/splash/presentation/splash_screen.dart';
import 'package:habitflow/features/authentication/presentation/login_screen.dart';
import 'package:habitflow/features/dashboard/presentation/dashboard_screen.dart';
import 'package:habitflow/features/habits/presentation/habits_screen.dart';
import 'package:habitflow/features/goals/presentation/goals_screen.dart';
import 'package:habitflow/features/rewards/presentation/rewards_screen.dart';
import 'package:habitflow/features/family/presentation/family_screen.dart';
import 'package:habitflow/features/analytics/presentation/analytics_screen.dart';
import 'package:habitflow/features/settings/presentation/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
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
    redirect: AuthGuard.redirect,
  );
});

class AppShell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HFTopAppBar(
        title: 'HabitFlow',
        actions: [
          HFIconButton(
            icon: Icons.person_outline_rounded,
            onPressed: () {
              // TODO: Navigate to Profile
            },
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
