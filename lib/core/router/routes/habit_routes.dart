import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/router/route_paths.dart';
import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/presentation/screens/create_habit_screen.dart';
import 'package:habitflow/features/habits/presentation/screens/habit_details_screen.dart';
import 'package:habitflow/features/habits/presentation/screens/archived_habits_screen.dart';
import 'package:habitflow/features/habits/presentation/screens/reminder_settings_screen.dart';

final habitRoutes = [
  GoRoute(
    path: '${RoutePaths.habits}/create',
    name: RouteNames.createHabit,
    pageBuilder: (context, state) {
      final extra = state.extra;
      Habit? habitToEdit;
      bool? isShared;

      if (extra is Habit) {
        habitToEdit = extra;
      } else if (extra is Map<String, dynamic>) {
        habitToEdit = extra['habitToEdit'] as Habit?;
        isShared = extra['isShared'] as bool?;
      }

      return MaterialPage(
        key: state.pageKey,
        child: CreateHabitScreen(
          habitToEdit: habitToEdit,
          initialIsShared: isShared,
        ),
      );
    },
  ),
  GoRoute(
    path: RoutePaths.habitDetails,
    name: RouteNames.habitDetails,
    pageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: HabitDetailsScreen(
        habit: state.extra as Habit?,
        habitId: state.pathParameters['habitId'],
      ),
    ),
  ),
  GoRoute(
    path: '${RoutePaths.habits}/archived',
    name: RouteNames.archivedHabits,
    pageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: const ArchivedHabitsScreen(),
    ),
  ),
  GoRoute(
    path: '${RoutePaths.habits}/reminders',
    name: RouteNames.reminderSettings,
    pageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: ReminderSettingsScreen(habitId: state.extra as String),
    ),
  ),
];
