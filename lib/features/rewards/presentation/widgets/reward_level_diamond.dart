import 'package:flutter/material.dart';

class RewardLevelDiamond extends StatelessWidget {
  final int level;
  final double size;

  const RewardLevelDiamond({
    super.key,
    required this.level,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: 45 * 3.1415926535 / 180,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.primary.withAlpha(100),
                width: 2,
              ),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LEVEL',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              level.toString(),
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const Positioned(
          top: 10,
          right: 10,
          child: Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
        ),
      ],
    );
  }
}
