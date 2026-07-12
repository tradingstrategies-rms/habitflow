import 'package:flutter/material.dart';
import 'package:habitflow/core/constants/life_areas.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/shared/widgets/foundation/hf_chip.dart';

/// [HFLifeAreaSelector] is a horizontal list for choosing a [LifeArea].
/// 
/// ### Example Usage:
/// ```dart
/// HFLifeAreaSelector(
///   selectedArea: LifeArea.health,
///   onAreaSelected: (area) => print(area),
/// )
/// ```
class HFLifeAreaSelector extends StatelessWidget {
  /// Creates an [HFLifeAreaSelector].
  const HFLifeAreaSelector({
    super.key,
    required this.onAreaSelected,
    this.selectedArea,
  });

  /// The currently selected LifeArea. Defaults to null ('All').
  final LifeArea? selectedArea;

  /// Callback when a LifeArea is selected.
  final ValueChanged<LifeArea?> onAreaSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: HFSpacing.s),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: HFSpacing.s),
            child: HFChip(
              label: 'All',
              isSelected: selectedArea == null,
              onTap: () => onAreaSelected(null),
            ),
          ),
          ...LifeArea.values.map((area) {
            return Padding(
              padding: const EdgeInsets.only(right: HFSpacing.s),
              child: HFChip(
                label: area.name,
                icon: area.icon,
                color: area.color,
                isSelected: selectedArea == area,
                onTap: () => onAreaSelected(area),
              ),
            );
          }),
        ],
      ),
    );
  }
}
