import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class HabitNameField extends StatelessWidget {
  final TextEditingController controller;
  const HabitNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return HFTextField(
      controller: controller,
      label: 'Habit Name',
      hintText: 'e.g., Read for 20 mins',
    );
  }
}
