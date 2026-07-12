# HabitFlow Architecture Review Package

This document contains a snapshot of the HabitFlow project's architecture, directory structure, and core configuration files as of the end of Sprint 0.

## 1. Directory Structure (lib/)

```text
Folder PATH listing
C:\USERS\U\ANDROIDSTUDIOPROJECTS\HABITFLOW\LIB
|   main.dart
|
+---app
|       habit_flow_app.dart
|       README.md
|
+---assets
|   |   README.md
|   |
|   +---animations
|   +---fonts
|   +---icons
|   +---illustrations
|   +---images
|   \---quotes
+---core
|   |   README.md
|   |
|   +---constants
|   |       app_constants.dart
|   |       life_areas.dart
|   |
|   +---errors
|   +---extensions
|   +---providers
|   |       core_providers.dart
|   |
|   +---router
|   |   |   app_router.dart
|   |   |   route_guards.dart
|   |   |   route_names.dart
|   |   |   route_paths.dart
|   |   |   transitions.dart
|   |   |
|   |   \---routes
|   |           auth_routes.dart
|   |           splash_routes.dart
|   |
|   +---services
|   |   +---analytics
|   |   |       analytics_service.dart
|   |   |
|   |   +---config
|   |   |       app_config.dart
|   |   |
|   |   +---connectivity
|   |   |       connectivity_service.dart
|   |   |
|   |   +---crash_reporting
|   |   |       crash_reporting_service.dart
|   |   |
|   |   +---environment
|   |   |       environment.dart
|   |   |
|   |   +---logger
|   |   |       hf_logger.dart
|   |   |
|   |   +---network
|   |   |       network_service.dart
|   |   |
|   |   +---notifications
|   |   |       notification_service.dart
|   |   |
|   |   +---permissions
|   |   |       permission_service.dart
|   |   |
|   |   \---storage
|   |           shared_preferences_storage.dart
|   |           storage_service.dart
|   |
|   +---theme
|   |       dark_theme.dart
|   |       hf_breakpoints.dart
|   |       hf_colors.dart
|   |       hf_durations.dart
|   |       hf_opacity.dart
|   |       hf_radius.dart
|   |       hf_shadows.dart
|   |       hf_spacing.dart
|   |       hf_theme.dart
|   |       hf_typography.dart
|   |       kids_theme.dart
|   |       light_theme.dart
|   |       theme_controller.dart
|   |       theme_extensions.dart
|   |
|   \---utils
+---features
|   |   README.md
|   |
|   +---analytics
|   |   \---presentation
|   |           analytics_screen.dart
|   |
|   +---authentication
|   |   \---presentation
|   |           login_screen.dart
|   |
|   +---dashboard
|   |   \---presentation
|   |           dashboard_screen.dart
|   |
|   +---family
|   |   \---presentation
|   |           family_screen.dart
|   |
|   +---goals
|   |   \---presentation
|   |           goals_screen.dart
|   |
|   +---habits
|   |   \---presentation
|   |           habits_screen.dart
|   |
|   +---onboarding
|   +---rewards
|   |   \---presentation
|   |           rewards_screen.dart
|   |
|   +---settings
|   |   \---presentation
|   |           settings_screen.dart
|   |
|   \---splash
|       \---presentation
|               splash_screen.dart
|
\---shared
    |   README.md
    |
    +---components
    +---models
    \---widgets
        |   widgets.dart
        |
        +---business
        |       business.dart
        |       hf_goal_card.dart
        |       hf_habit_tile.dart
        |       hf_profile_card.dart
        |       hf_quote_card.dart
        |       hf_reward_card.dart
        |       hf_stat_card.dart
        |
        +---feedback
        |       feedback.dart
        |       hf_bottom_sheet.dart
        |       hf_dialog.dart
        |       hf_feedback.dart
        |       hf_loading_overlay.dart
        |
        +---foundation
        |       foundation.dart
        |       hf_avatar.dart
        |       hf_badge.dart
        |       hf_button.dart
        |       hf_card.dart
        |       hf_chip.dart
        |       hf_divider.dart
        |       hf_empty_state.dart
        |       hf_icon_button.dart
        |       hf_loading_indicator.dart
        |       hf_progress_bar.dart
        |       hf_text_field.dart
        |
        \---layout
                hf_bottom_navigation.dart
                hf_life_area_selector.dart
                hf_search_bar.dart
                hf_section_header.dart
                hf_top_app_bar.dart
                layout.dart
```

---

## 2. Core Implementation Files

### lib/main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitflow/app/habit_flow_app.dart';
import 'package:habitflow/core/theme/theme_controller.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Run the app wrapped in a ProviderScope for Riverpod state management
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const HabitFlowApp(),
    ),
  );
}
```

### lib/app/habit_flow_app.dart
```dart
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
```

### lib/core/router/app_router.dart
```dart
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
```

### lib/core/router/route_names.dart
```dart
/// [RouteNames] defines the name for every route in the HabitFlow application.
class RouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String dashboard = 'dashboard';
  static const String habits = 'habits';
  static const String goals = 'goals';
  static const String rewards = 'rewards';
  static const String family = 'family';
  static const String analytics = 'analytics';
  static const String settings = 'settings';
}
```

### lib/core/router/route_paths.dart
```dart
/// [RoutePaths] defines the URL paths for every route in the HabitFlow application.
class RoutePaths {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/';
  static const String habits = '/habits';
  static const String goals = '/goals';
  static const String rewards = '/rewards';
  static const String family = '/family';
  static const String analytics = '/analytics';
  static const String settings = '/settings';
}
```

### lib/core/providers/core_providers.dart
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/services/logger/hf_logger.dart';
import 'package:habitflow/core/services/storage/storage_service.dart';
import 'package:habitflow/core/services/storage/shared_preferences_storage.dart';
import 'package:habitflow/core/services/analytics/analytics_service.dart';
import 'package:habitflow/core/services/crash_reporting/crash_reporting_service.dart';
import 'package:habitflow/core/services/notifications/notification_service.dart';
import 'package:habitflow/core/services/connectivity/connectivity_service.dart';
import 'package:habitflow/core/services/permissions/permission_service.dart';
import 'package:habitflow/core/services/network/network_service.dart';
import 'package:habitflow/core/services/config/app_config.dart';
import 'package:habitflow/core/services/environment/environment.dart';
import 'package:habitflow/core/theme/theme_controller.dart'; // For SharedPreferences provider

/// Provider for [HFLogger].
final loggerProvider = Provider<HFLogger>((ref) => HFLogger());

/// Provider for [StorageService].
final storageProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPreferencesStorage(prefs);
});

/// Provider for [AnalyticsService].
final analyticsProvider = Provider<AnalyticsService>((ref) => NoOpAnalyticsService());

/// Provider for [CrashReportingService].
final crashReportingProvider = Provider<CrashReportingService>((ref) => NoOpCrashReportingService());

/// Provider for [NotificationService].
final notificationProvider = Provider<NotificationService>((ref) => NoOpNotificationService());

/// Provider for [ConnectivityService].
final connectivityProvider = Provider<ConnectivityService>((ref) => NoOpConnectivityService());

/// Provider for [PermissionService].
final permissionProvider = Provider<PermissionService>((ref) => NoOpPermissionService());

/// Provider for [NetworkService].
final networkProvider = Provider<NetworkService>((ref) => NoOpNetworkService());

/// Provider for [AppConfig].
final appConfigProvider = Provider<AppConfig>((ref) {
  return const AppConfig(
    appName: 'HabitFlow',
    version: '1.0.0',
    buildNumber: '1',
    environment: Environment.development,
    apiTimeout: Duration(seconds: 30),
  );
});
```

### lib/core/theme/hf_theme.dart
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitflow/core/theme/hf_colors.dart';
import 'package:habitflow/core/theme/hf_radius.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_typography.dart';
import 'package:habitflow/core/theme/theme_extensions.dart';

/// [HFTheme] is the entry point for the HabitFlow theme system.
class HFTheme {
  static TextTheme _buildTextTheme(Color color) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: HFTypography.headingXL,
        fontWeight: HFTypography.weightBold,
        color: color,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: HFTypography.headingL,
        fontWeight: HFTypography.weightBold,
        color: color,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: HFTypography.headingM,
        fontWeight: HFTypography.weightSemiBold,
        color: color,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: HFTypography.headingS,
        fontWeight: HFTypography.weightSemiBold,
        color: color,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: HFTypography.body,
        fontWeight: HFTypography.weightRegular,
        color: color,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: HFTypography.caption,
        fontWeight: HFTypography.weightRegular,
        color: color,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: HFTypography.small,
        fontWeight: HFTypography.weightMedium,
        color: color,
      ),
    );
  }

  static const HFThemeExtension _sharedExtension = HFThemeExtension(
    lifeAreaHealth: Color(0xFFEF4444),
    lifeAreaLearning: Color(0xFF3B82F6),
    lifeAreaDiscipline: Color(0xFF6B7280),
    lifeAreaFamily: Color(0xFF10B981),
    lifeAreaFinance: Color(0xFF22C55E),
    lifeAreaFitness: Color(0xFFF97316),
    lifeAreaSpiritual: Color(0xFF8B5CF6),
    lifeAreaCreativity: Color(0xFFF59E0B),
    lifeAreaSocial: Color(0xFF14B8A6),
    xpColor: Color(0xFF6366F1),
    levelColor: Color(0xFFF59E0B),
    rewardColor: Color(0xFFFACC15),
  );

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);
  static ThemeData get kids => _buildKidsTheme();

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: HFColors.primary,
      brightness: brightness,
      primary: HFColors.primary,
      secondary: HFColors.secondary,
      surface: isDark ? HFColors.darkSurface : HFColors.surface,
      error: HFColors.error,
      onPrimary: HFColors.textOnPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? HFColors.darkBackground : HFColors.background,
      textTheme: _buildTextTheme(isDark ? Colors.white : HFColors.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? HFColors.darkBackground : HFColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: HFTypography.headingS,
          fontWeight: HFTypography.weightSemiBold,
          color: isDark ? Colors.white : HFColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: HFRadius.cardBorderRadius,
        ),
        color: colorScheme.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HFColors.primary,
          foregroundColor: HFColors.textOnPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: HFRadius.buttonBorderRadius,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: HFTypography.body,
            fontWeight: HFTypography.weightMedium,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark 
          ? Colors.white.withAlpha(13) // ~0.05 opacity
          : Colors.black.withAlpha(5),  // ~0.02 opacity
        border: const OutlineInputBorder(
          borderRadius: HFRadius.buttonBorderRadius,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: HFSpacing.m,
          vertical: HFSpacing.m,
        ),
      ),
      extensions: const [_sharedExtension],
    );
  }

  static ThemeData _buildKidsTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFFEB3B), // Vibrant Yellow
      brightness: Brightness.light,
      primary: const Color(0xFFFFC107), // Amber
      secondary: const Color(0xFF4CAF50), // Green
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFFFFDE7), // Light Yellow
      textTheme: _buildTextTheme(HFColors.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFFFDE7),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: HFTypography.headingM,
          fontWeight: HFTypography.weightBold,
          color: HFColors.textPrimary,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)), // More rounded
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          shape: const StadiumBorder(),
          elevation: 4,
        ),
      ),
      extensions: const [_sharedExtension],
    );
  }
}
```

### lib/shared/widgets/layout/hf_bottom_navigation.dart
```dart
import 'package:flutter/material.dart';

/// [HFBottomNavigation] is the primary navigation shell for HabitFlow.
/// 
/// It implements the Material 3 Navigation Bar pattern.
/// 
/// ### Example Usage:
/// ```dart
/// HFBottomNavigation(
///   currentIndex: 0,
///   onDestinationSelected: (index) => setState(() => _index = index),
/// )
/// ```
class HFBottomNavigation extends StatelessWidget {
  /// Creates an [HFBottomNavigation].
  const HFBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  /// The index of the currently selected navigation item.
  final int currentIndex;

  /// Callback when a navigation item is selected.
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.check_circle_outline_rounded),
          selectedIcon: Icon(Icons.check_circle_rounded),
          label: 'Habits',
        ),
        NavigationDestination(
          icon: Icon(Icons.emoji_events_outlined),
          selectedIcon: Icon(Icons.emoji_events_rounded),
          label: 'Rewards',
        ),
        NavigationDestination(
          icon: Icon(Icons.family_restroom_outlined),
          selectedIcon: Icon(Icons.family_restroom_rounded),
          label: 'Family',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
```

### pubspec.yaml
```yaml
name: habitflow
description: "A new Flutter project."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: ^3.12.1

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  flutter:
    sdk: flutter

  # Icons
  cupertino_icons: ^1.0.8

  # State Management
  flutter_riverpod: ^2.5.1

  # Routing
  go_router: ^14.2.0

  # Firebase
  firebase_core: ^3.1.1
  firebase_auth: ^5.1.1
  cloud_firestore: ^5.0.2
  firebase_storage: ^12.1.0
  firebase_messaging: ^15.0.3
  firebase_analytics: ^11.1.0
  firebase_crashlytics: ^4.0.3

  # Local Storage
  path_provider: ^2.1.3

  # Utilities
  intl: ^0.19.0
  uuid: ^4.4.0
  shared_preferences: ^2.2.3
  google_fonts: ^6.2.1

  # Charts
  fl_chart: ^0.68.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.11

  # Linting
  flutter_lints: ^4.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  assets:
    - assets/icons/
    - assets/images/branding/

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package
```
