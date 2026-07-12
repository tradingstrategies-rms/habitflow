import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/app/habit_flow_app.dart';
import 'package:habitflow/core/bootstrap/bootstrap.dart';
import 'package:habitflow/core/theme/theme_controller.dart';

void main() async {
  // Centralized app initialization
  await Bootstrap.initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          Bootstrap.initializer.sharedPreferences,
        ),
      ],
      child: const HabitFlowApp(),
    ),
  );
}
