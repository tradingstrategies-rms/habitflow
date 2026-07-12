import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: HFProfileCard(
          name: 'The Habit Family',
          email: 'family@habitflow.com',
        ),
      ),
    );
  }
}
