import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/router/route_paths.dart';
import 'package:habitflow/features/splash/presentation/splash_screen.dart';

final splashRoutes = [
  GoRoute(
    path: RoutePaths.splash,
    name: RouteNames.splash,
    builder: (context, state) => const SplashScreen(),
  ),
];
