import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/router/route_paths.dart';
import 'package:habitflow/features/goals/domain/entities/goal.dart';
import 'package:habitflow/features/goals/presentation/screens/goal_detail_screen.dart';
import 'package:habitflow/features/goals/presentation/screens/create_goal_screen.dart';
import 'package:habitflow/features/goals/presentation/screens/edit_goal_screen.dart';

final goalRoutes = [
  GoRoute(
    path: RoutePaths.goalDetails,
    name: RouteNames.goalDetails,
    pageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: GoalDetailScreen(
        goalId: state.pathParameters['goalId'],
      ),
    ),
  ),
  GoRoute(
    path: RoutePaths.createGoal,
    name: RouteNames.createGoal,
    pageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: const CreateGoalScreen(),
    ),
  ),
  GoRoute(
    path: RoutePaths.editGoal,
    name: RouteNames.editGoal,
    pageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: EditGoalScreen(
        goal: state.extra as Goal,
      ),
    ),
  ),
];
