import 'package:flutter/material.dart';
import '../../../../core/theme/hf_spacing.dart';

class GoalColorPicker extends StatelessWidget {
  final int selectedColor;
  final ValueChanged<int> onColorSelected;

  static const List<int> colors = [
    0xFF006C49, // Emerald Green
    0xFF10B981, // Primary Container
    0xFF006B5F, // Secondary
    0xFF855300, // Tertiary
    0xFFF97316, // Warning
    0xFFEF4444, // Danger
    0xFFFFC107, // Kids Accent
    0xFF22C55E, // Success
    0xFF3B82F6, // Blue
    0xFF8B5CF6, // Purple
  ];

  const GoalColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COLOR',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: HFSpacing.s),
        Wrap(
          spacing: HFSpacing.s,
          runSpacing: HFSpacing.s,
          children: colors.map((color) {
            final isSelected = color == selectedColor;
            return InkWell(
              onTap: () => onColorSelected(color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(color),
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                  boxShadow: isSelected ? [const BoxShadow(color: Colors.black26, blurRadius: 4)] : null,
                ),
                child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
