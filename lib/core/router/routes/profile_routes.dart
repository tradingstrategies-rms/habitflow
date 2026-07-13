import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/router/route_paths.dart';
import 'package:habitflow/features/profile/presentation/create_profile_screen.dart';
import 'package:habitflow/features/profile/presentation/edit_profile_screen.dart';
import 'package:habitflow/features/profile/presentation/avatar_selection_screen.dart';

final profileRoutes = [
  GoRoute(
    path: RoutePaths.createProfile,
    name: RouteNames.createProfile,
    builder: (context, state) => const CreateProfileScreen(),
  ),
  GoRoute(
    path: RoutePaths.editProfile,
    name: RouteNames.editProfile,
    builder: (context, state) => const EditProfileScreen(),
  ),
  GoRoute(
    path: RoutePaths.avatarSelection,
    name: RouteNames.avatarSelection,
    builder: (context, state) => const AvatarSelectionScreen(),
  ),
];
