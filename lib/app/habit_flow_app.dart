import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/hf_theme.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'package:habitflow/core/constants/app_constants.dart';
import 'package:habitflow/core/router/app_router.dart';
import 'package:habitflow/features/intelligence/application/services/intelligence_notification_coordinator.dart';
import 'package:habitflow/features/leaderboards/application/services/leaderboard_notification_coordinator.dart';
import 'package:habitflow/features/reward_store/application/services/reward_approval_notification_coordinator.dart';
import 'package:habitflow/features/challenges/application/services/challenge_reminder_coordinator.dart';

/// The root widget of the HabitFlow application.
class HabitFlowApp extends ConsumerWidget {
  const HabitFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize notification coordinators
    // We watch them to ensure they are active throughout the app lifecycle.
    ref.watch(intelligenceNotificationCoordinatorProvider);
    ref.watch(leaderboardNotificationCoordinatorProvider);
    ref.watch(rewardApprovalNotificationCoordinatorProvider);
    ref.watch(challengeReminderListenerProvider);

    final themeMode = ref.watch(themeControllerProvider);
    final themeController = ref.read(themeControllerProvider.notifier);
    final router = ref.watch(routerProvider);

    ThemeData theme;
    ThemeData? darkTheme;

    switch (themeMode) {
      case HFThemeMode.light:
        theme = HFTheme.light;
        break;
      case HFThemeMode.dark:
        theme = HFTheme.dark;
        break;
      case HFThemeMode.kids:
        theme = HFTheme.kids;
        break;
      case HFThemeMode.system:
        theme = HFTheme.light;
        darkTheme = HFTheme.dark;
        break;
    }

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeController.themeMode,
      routerConfig: router,
    );
  }
}
