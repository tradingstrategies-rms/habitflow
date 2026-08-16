import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/router/route_paths.dart';
import 'package:habitflow/core/achievements/providers/achievement_providers.dart';
import 'package:habitflow/features/goals/application/providers/goal_providers.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_completion_dialog.dart';
import 'package:habitflow/features/authentication/data/auth_providers.dart';
import 'package:habitflow/features/profile/data/profile_providers.dart';
import 'package:habitflow/features/splash/presentation/splash_providers.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

import 'package:habitflow/features/intelligence/presentation/screens/intelligence_dashboard_screen.dart';
import 'package:habitflow/features/family/presentation/screens/create_family_circle_screen.dart';
import 'package:habitflow/features/family/presentation/screens/family_profiles_screen.dart';
import 'package:habitflow/features/family/presentation/screens/profile_selector_screen.dart';
import 'package:habitflow/features/family/presentation/screens/parent_pin_screen.dart';
import 'package:habitflow/features/family/presentation/screens/setup_pin_screen.dart';
import 'package:habitflow/features/family/presentation/screens/child_dashboard_screen.dart';
import 'package:habitflow/features/rewards/presentation/screens/rewards_dashboard_screen.dart';
import 'package:habitflow/features/rewards/presentation/screens/kids_rewards_dashboard_screen.dart';
import 'package:habitflow/features/rewards/presentation/screens/reward_history_screen.dart';
import 'package:habitflow/features/rewards/presentation/screens/reward_detail_screen.dart';
import 'package:habitflow/features/rewards/presentation/screens/reward_level_progress_screen.dart';
import 'package:habitflow/features/challenges/presentation/screens/challenges_dashboard_screen.dart';
import 'package:habitflow/features/challenges/presentation/screens/challenge_detail_screen.dart';
import 'package:habitflow/features/challenges/presentation/screens/completed_challenges_screen.dart';
import 'package:habitflow/features/leaderboards/presentation/screens/leaderboard_screen.dart';
import 'package:habitflow/features/reward_store/presentation/screens/reward_store_screen.dart';
import 'package:habitflow/features/reward_store/presentation/screens/reward_store_detail_screen.dart';
import 'package:habitflow/features/reward_store/presentation/screens/redemption_history_screen.dart';
import 'package:habitflow/features/reward_store/domain/entities/reward_item.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge_progress.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_transaction.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_type.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_source.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/presentation/screens/parent_approval_screen.dart';
import 'package:habitflow/features/family/presentation/screens/family_dashboard_screen.dart';
import 'package:habitflow/features/family/presentation/screens/family_settings_screen.dart';
import 'package:habitflow/features/family/presentation/screens/shared_habits_screen.dart';
import 'package:habitflow/features/family/presentation/screens/shared_habit_details_screen.dart';
import 'package:habitflow/features/family/presentation/screens/family_activity_feed_screen.dart';
import 'package:habitflow/features/family/presentation/screens/family_achievements_screen.dart';
import 'package:habitflow/features/family/domain/entities/shared_habit.dart';
import 'package:habitflow/features/settings/presentation/country_selection_screen.dart';

import 'package:habitflow/features/family/presentation/screens/family_invitation_details_screen.dart';

// Modular Routes
import 'routes/splash_routes.dart';
import 'routes/auth_routes.dart';
import 'routes/profile_routes.dart';
import 'routes/habit_routes.dart';
import 'routes/goal_routes.dart';

// Feature Screens
import 'package:habitflow/features/dashboard/presentation/dashboard_screen.dart';
import 'package:habitflow/features/habits/presentation/screens/habits_screen.dart';
import 'package:habitflow/features/goals/presentation/screens/goals_screen.dart';
import 'package:habitflow/features/analytics/presentation/analytics_screen.dart';
import 'package:habitflow/features/settings/presentation/settings_screen.dart';
import 'package:habitflow/features/subscription/presentation/screens/subscription_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Routes accessible without authentication.
final _authRoutes = [
  RoutePaths.welcome,
  RoutePaths.login,
  RoutePaths.register,
  RoutePaths.forgotPassword,
  RoutePaths.emailVerification,
];

/// Refreshes router when auth/profile/splash state changes.
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(userProfileProvider, (_, __) => notifyListeners());
    ref.listen(splashMinTimeReachedProvider, (_, __) => notifyListeners());
  }
}

final routerRefreshNotifierProvider =
    Provider((ref) => RouterRefreshNotifier(ref));

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
      ...habitRoutes,
      ...goalRoutes,

      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: RoutePaths.dashboard,
            name: RouteNames.dashboard,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: RoutePaths.habits,
            name: RouteNames.habits,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HabitsScreen()),
          ),
          GoRoute(
            path: RoutePaths.goals,
            name: RouteNames.goals,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: GoalsScreen()),
          ),
          GoRoute(
            path: RoutePaths.rewards,
            name: RouteNames.rewards,
            pageBuilder: (context, state) =>
                NoTransitionPage(child: Consumer(
                  builder: (context, ref, _) {
                    final session = ref.watch(activeProfileSessionProvider);
                    if (session == null) return const RewardsDashboardScreen();
                    
                    final familyState = ref.watch(familyProvider);
                    final profile = familyState.profiles.firstWhere(
                      (p) => p.id == session.profileId,
                      orElse: () => familyState.profiles.firstWhere((p) => true, orElse: () => throw 'No profile found'),
                    );

                    if (profile.profileType == ProfileType.child) {
                      return const KidsRewardsDashboardScreen();
                    }
                    return const RewardsDashboardScreen();
                  },
                )),
          ),
          GoRoute(
            path: RoutePaths.family,
            name: RouteNames.family,
            pageBuilder: (context, state) =>
            const NoTransitionPage(
              child: FamilyDashboardScreen(),
            ),
          ),
        ],
      ),

      GoRoute(
        path: RoutePaths.intelligence,
        name: RouteNames.intelligence,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const IntelligenceDashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.familyApprovals,
        name: RouteNames.familyApprovals,
        builder: (context, state) => const ParentApprovalScreen(),
      ),
      GoRoute(
        path: RoutePaths.familyCreate,
        name: RouteNames.familyCreate,
        builder: (context, state) => const CreateFamilyCircleScreen(),
      ),
      GoRoute(
        path: RoutePaths.familyMembers,
        name: RouteNames.familyMembers,
        builder: (context, state) => const FamilyProfilesScreen(),
      ),
      GoRoute(
        path: RoutePaths.familyProfileSelector,
        name: RouteNames.familyProfileSelector,
        builder: (context, state) => const ProfileSelectorScreen(),
      ),
      GoRoute(
        path: RoutePaths.familyPin,
        name: RouteNames.familyPin,
        builder: (context, state) {
          final profile = state.extra;

          if (profile is! FamilyProfile) {
            return const Scaffold(
              body: Center(
                child: Text('Invalid profile'),
              ),
            );
          }

          return ParentPinScreen(profile: profile);
        },
      ),
      GoRoute(
        path: RoutePaths.familyPinSetup,
        name: RouteNames.familyPinSetup,
        builder: (context, state) => const SetupPinScreen(),
      ),
      GoRoute(
        path: RoutePaths.familySettings,
        name: RouteNames.familySettings,
        builder: (context, state) => const FamilySettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.countrySelection,
        name: RouteNames.countrySelection,
        builder: (context, state) => const CountrySelectionScreen(),
      ),
      GoRoute(
        path: RoutePaths.familyChild,
        name: RouteNames.familyChild,
        builder: (context, state) => const ChildDashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.levelProgress,
        name: RouteNames.levelProgress,
        builder: (context, state) => const RewardLevelProgressScreen(),
      ),
      GoRoute(
        path: RoutePaths.rewardHistory,
        name: RouteNames.rewardHistory,
        builder: (context, state) => const RewardHistoryScreen(),
      ),
      GoRoute(
        path: RoutePaths.rewardDetail,
        name: RouteNames.rewardDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is RewardTransaction) {
            return RewardDetailScreen(transaction: extra);
          }
          // Fallback / Placeholder if navigation happened without extra
          return RewardDetailScreen(
            transaction: RewardTransaction(
              id: 'error',
              profileId: '',
              amount: 0,
              type: RewardType.points,
              source: RewardSource.manualAdjustment,
              description: 'Transaction not found',
              createdAt: DateTime.now(),
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.challengesDashboard,
        name: RouteNames.challengesDashboard,
        builder: (context, state) => const ChallengesDashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.challengeDetail,
        name: RouteNames.challengeDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra != null && 
              extra['challenge'] is Challenge && 
              extra['progress'] is ChallengeProgress) {
            return ChallengeDetailScreen(
              challenge: extra['challenge'] as Challenge,
              progress: extra['progress'] as ChallengeProgress,
            );
          }
          return const Scaffold(body: Center(child: Text('Invalid challenge data')));
        },
      ),
      GoRoute(
        path: RoutePaths.completedChallenges,
        name: RouteNames.completedChallenges,
        builder: (context, state) => const CompletedChallengesScreen(),
      ),
      GoRoute(
        path: RoutePaths.leaderboard,
        name: RouteNames.leaderboard,
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.rewardStore,
        name: RouteNames.rewardStore,
        builder: (context, state) => const RewardStoreScreen(),
      ),
      GoRoute(
        path: RoutePaths.rewardStoreDetail,
        name: RouteNames.rewardStoreDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is RewardItem) {
            return RewardStoreDetailScreen(item: extra);
          }
          return const Scaffold(body: Center(child: Text('Invalid reward item')));
        },
      ),
      GoRoute(
        path: RoutePaths.redemptionHistory,
        name: RouteNames.redemptionHistory,
        builder: (context, state) {
          final profileId = state.pathParameters['profileId'] ?? '';
          return RedemptionHistoryScreen(profileId: profileId);
        },
      ),
      GoRoute(
        path: RoutePaths.familyActivity,
        name: RouteNames.familyActivity,
        builder: (context, state) => const FamilyActivityFeedScreen(),
      ),
      GoRoute(
        path: RoutePaths.familyAchievements,
        name: RouteNames.familyAchievements,
        builder: (context, state) => const FamilyAchievementsScreen(),
      ),
      GoRoute(
        path: RoutePaths.familySharedHabits,
        name: RouteNames.familySharedHabits,
        builder: (context, state) => const SharedHabitsScreen(),
      ),
      GoRoute(
        path: RoutePaths.familySharedHabitDetails,
        name: RouteNames.familySharedHabitDetails,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is SharedHabit) {
            return SharedHabitDetailsScreen(sharedHabit: extra);
          }
          return const Scaffold(body: Center(child: Text('Invalid shared habit')));
        },
      ),

      GoRoute(
        path: RoutePaths.familyInvite,
        name: RouteNames.familyInvite,
        builder: (context, state) {
          final token = state.pathParameters['token'] ?? '';
          return FamilyInvitationDetailsScreen(token: token);
        },
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
      GoRoute(
        path: RoutePaths.subscription,
        name: RouteNames.subscription,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SubscriptionScreen(),
      ),
    ],


    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final profileState = ref.read(userProfileProvider);
      final isSplashTimeReached =
          ref.read(splashMinTimeReachedProvider);

      final bool onSplash =
          state.uri.path == RoutePaths.splash;


      // 1. Splash handling
      if (onSplash) {
        if (!isSplashTimeReached || authState.isLoading) {
          return null;
        }
      }


      final bool isAuthenticated =
          authState.value != null;

      final bool isAuthRoute =
          _authRoutes.contains(state.uri.path);



      // 2. Unauthenticated users
      if (!isAuthenticated) {

        if (!isAuthRoute && !onSplash) {
          return RoutePaths.welcome;
        }

        if (onSplash &&
            isSplashTimeReached &&
            !authState.isLoading) {
          return RoutePaths.welcome;
        }

        return null;
      }



      // 3. Authenticated users

      // Wait for profile loading
      if (profileState.isLoading) {
        return null;
      }


      final bool hasProfile =
          profileState.value != null;


      // IMPORTANT:
      // AvatarSelection is NOT considered onboarding anymore.
      // It is also used from Edit Profile flow.
      final bool isCreatingProfile =
          state.uri.path == RoutePaths.createProfile;

      final bool isAvatarSelection =
          state.uri.path == RoutePaths.avatarSelection;



      // 4. User has no profile
      // Force profile creation flow
      if (!hasProfile) {

        if (!isCreatingProfile &&
            !isAvatarSelection) {
          return RoutePaths.createProfile;
        }

        return null;
      }



      // 5. Existing user
      // Do not redirect AvatarSelection.
      // It is a valid profile editing route.
      if (isAuthRoute ||
          isCreatingProfile ||
          onSplash) {
        return RoutePaths.dashboard;
      }


      return null;
    },
  );
});


class AppShell extends ConsumerWidget {

  const AppShell({
    super.key,
    required this.child,
  });

  final Widget child;



  int _getCurrentIndex(BuildContext context) {

    final String location =
        GoRouterState.of(context).uri.path;


    if (location.startsWith(RoutePaths.habits)) {
      return 1;
    }

    if (location.startsWith(RoutePaths.goals)) {
      return 2;
    }

    if (location.startsWith(RoutePaths.rewards)) {
      return 3;
    }

    if (location.startsWith(RoutePaths.family)) {
      return 4;
    }

    return 0;
  }



  void _onItemTapped(
      int index,
      BuildContext context) {

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
  Widget build(
      BuildContext context,
      WidgetRef ref) {

    ref.listen(goalCompletionEventsProvider, (previous, next) {
      next.whenData((event) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => GoalCompletionDialog(event: event),
        );
        ref.read(achievementEventBusProvider).acknowledge(event.goalId);
      });
    });

    // Initialize Goal Completion Watcher lifecycle
    ref.listen(goalCompletionWatcherProvider, (_, __) {});

    return Scaffold(
      body: child,
      bottomNavigationBar:
          HFBottomNavigation(
            currentIndex:
                _getCurrentIndex(context),

            onDestinationSelected:
                (index) =>
                    _onItemTapped(
                        index,
                        context),
          ),
    );
  }
}
