import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/foundation/hf_text_field.dart';

class GoalTargetInput extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onTargetChanged;
  final String label;

  const GoalTargetInput({
    super.key,
    required this.initialValue,
    required this.onTargetChanged,
    this.label = 'TARGET VALUE',
  });

  @override
  State<GoalTargetInput> createState() => _GoalTargetInputState();
}

class _GoalTargetInputState extends State<GoalTargetInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HFTextField(
      controller: _controller,
      label: widget.label,
      keyboardType: TextInputType.number,
      hintText: 'Enter target value',
      onChanged: (value) {
        final double? target = double.tryParse(value);
        if (target != null) {
          widget.onTargetChanged(target);
        }
      },
    );
  }
}
