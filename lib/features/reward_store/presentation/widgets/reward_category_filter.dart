import 'package:flutter/material.dart';
import '../../domain/enums/reward_category.dart';

class RewardCategoryFilter extends StatelessWidget {
  final RewardCategory? selectedCategory;
  final ValueChanged<RewardCategory?> onCategorySelected;

  const RewardCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selectedCategory == null,
            onSelected: (_) => onCategorySelected(null),
          ),
          const SizedBox(width: 8),
          ...RewardCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_getDisplayName(category)),
                selected: selectedCategory == category,
                onSelected: (_) => onCategorySelected(category),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getDisplayName(RewardCategory category) {
    return category.name[0].toUpperCase() + category.name.substring(1);
  }
}
