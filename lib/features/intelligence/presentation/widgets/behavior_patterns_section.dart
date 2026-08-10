import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_pattern.dart';
import 'behavior_pattern_chip.dart';
import 'section_header.dart';

class BehaviorPatternsSection extends StatelessWidget {
  final List<HabitPattern> patterns;
  final String title;

  const BehaviorPatternsSection({
    super.key,
    required this.patterns,
    this.title = 'Detected Patterns',
  });

  @override
  Widget build(BuildContext context) {
    if (patterns.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: HFSpacing.s),
        Wrap(
          spacing: HFSpacing.s,
          runSpacing: HFSpacing.s,
          children: patterns.map((pattern) {
            return BehaviorPatternChip(pattern: pattern);
          }).toList(),
        ),
      ],
    );
  }
}
