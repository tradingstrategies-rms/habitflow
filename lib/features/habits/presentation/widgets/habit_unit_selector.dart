import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class HabitUnitSelector extends StatefulWidget {
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<String> onCustomUnitChanged;

  const HabitUnitSelector({
    super.key,
    required this.onUnitChanged,
    required this.onCustomUnitChanged,
  });

  @override
  State<HabitUnitSelector> createState() => _HabitUnitSelectorState();
}

class _HabitUnitSelectorState extends State<HabitUnitSelector> {
  String _selectedUnit = 'Minutes';
  final List<String> _units = [
    'Minutes', 'Hours', 'Glasses', 'Steps', 'Pages', 'Sessions', 'Kilometers', 'Calories', 'Custom...'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Unit'),
          items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
          onChanged: (val) {
            setState(() => _selectedUnit = val!);
            widget.onUnitChanged(val!);
          },
        ),
        if (_selectedUnit == 'Custom...') ...[
          const SizedBox(height: 12),
          HFTextField(
            label: 'Custom Unit',
            hintText: 'e.g. Push-ups',
            onChanged: widget.onCustomUnitChanged,
          ),
        ],
      ],
    );
  }
}
