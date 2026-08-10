import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class HabitDescriptionField extends StatelessWidget {
  final TextEditingController controller;
  const HabitDescriptionField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return HFTextField(
      controller: controller,
      label: 'Description (Optional)',
      hintText: 'Add some details about your habit',
    );
  }
}
