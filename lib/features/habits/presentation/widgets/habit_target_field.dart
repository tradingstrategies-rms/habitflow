import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class HabitTargetField extends StatelessWidget {
  final TextEditingController controller;
  const HabitTargetField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return HFTextField(
      controller: controller,
      label: 'Target Value',
      hintText: 'e.g. 30',
      keyboardType: TextInputType.number,
    );
  }
}
