import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/app/habit_flow_app.dart';
import 'package:habitflow/core/bootstrap/bootstrap.dart';

void main() async {
  final container = await Bootstrap.initialize();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const HabitFlowApp(),
    ),
  );
}
