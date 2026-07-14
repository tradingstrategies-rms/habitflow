import 'package:flutter/material.dart';
import '../../domain/models/habit_icon.dart';

class HabitIconPicker extends StatelessWidget {
  final HabitIcon selectedIcon;
  final ValueChanged<HabitIcon> onIconChanged;

  const HabitIconPicker({super.key, required this.selectedIcon, required this.onIconChanged});

  static const List<String> _icons = ['✨', '🏃', '📚', '🍎', '🧘', '💧'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: _icons.map((icon) => InkWell(
        onTap: () => onIconChanged(HabitIcon(icon)),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: selectedIcon.value == icon ? Theme.of(context).primaryColor.withValues(alpha: 0.2) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(icon, style: const TextStyle(fontSize: 24)),
        ),
      )).toList(),
    );
  }
}
