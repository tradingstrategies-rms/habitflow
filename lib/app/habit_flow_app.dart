import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/hf_theme.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'package:habitflow/core/constants/app_constants.dart';
import 'package:habitflow/core/router/app_router.dart';

/// The root widget of the HabitFlow application.
class HabitFlowApp extends ConsumerWidget {
  const HabitFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
