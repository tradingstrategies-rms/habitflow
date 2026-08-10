import 'package:flutter/material.dart';

class RewardCostBadge extends StatelessWidget {
  final int cost;
  final double? fontSize;
  final double iconSize;

  const RewardCostBadge({
    super.key,
    required this.cost,
    this.fontSize,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars_rounded, color: Colors.amber.shade700, size: iconSize),
          const SizedBox(width: 4),
          Text(
            cost.toString(),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade900,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
