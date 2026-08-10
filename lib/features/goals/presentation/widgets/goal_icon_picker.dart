import 'package:flutter/material.dart';
import '../../../../core/theme/hf_spacing.dart';

class GoalIconPicker extends StatelessWidget {
  final String selectedIcon;
  final ValueChanged<String> onIconSelected;

  static const Map<String, IconData> icons = {
    'fitness_center': Icons.fitness_center_rounded,
    'music_note': Icons.music_note_rounded,
    'piano': Icons.piano_rounded,
    'flight_takeoff': Icons.flight_takeoff_rounded,
    'directions_run': Icons.directions_run_rounded,
    'water_drop': Icons.water_drop_rounded,
    'menu_book': Icons.menu_book_rounded,
    'extension': Icons.extension_rounded,
    'rocket_launch': Icons.rocket_launch_rounded,
    'park': Icons.park_rounded,
    'emoji_events': Icons.emoji_events_rounded,
    'spa': Icons.spa_rounded,
    'favorite': Icons.favorite_rounded,
    'self_improvement': Icons.self_improvement_rounded,
    'psychology': Icons.psychology_rounded,
  };

  const GoalIconPicker({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ICON',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: HFSpacing.s),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: HFSpacing.s,
            crossAxisSpacing: HFSpacing.s,
          ),
          itemCount: icons.length,
          itemBuilder: (context, index) {
            final entry = icons.entries.elementAt(index);
            final isSelected = entry.key == selectedIcon;
            return InkWell(
              onTap: () => onIconSelected(entry.key),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Icon(
                  entry.value,
                  color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : null,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
