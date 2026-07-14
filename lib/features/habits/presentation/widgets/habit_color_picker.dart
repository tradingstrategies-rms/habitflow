import 'package:flutter/material.dart';
import '../../domain/models/habit_color.dart';

class HabitColorPicker extends StatelessWidget {
  final HabitColor selectedColor;
  final ValueChanged<HabitColor> onColorChanged;

  const HabitColorPicker({super.key, required this.selectedColor, required this.onColorChanged});

  static const List<int> _colors = [0xFF86A789, 0xFFD27666, 0xFF4F6F52, 0xFF967E76];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: _colors.map((color) => InkWell(
        onTap: () => onColorChanged(HabitColor(color)),
        child: CircleAvatar(
          backgroundColor: Color(color),
          child: selectedColor.value == color ? const Icon(Icons.check, color: Colors.white) : null,
        ),
      )).toList(),
    );
  }
}
