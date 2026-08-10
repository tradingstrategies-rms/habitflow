import 'package:flutter/material.dart';

class RankBadge extends StatelessWidget {
  final int rank;

  const RankBadge({super.key, required this.rank});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTop3 = rank <= 3;
    
    Color badgeColor;
    Color textColor = Colors.white;

    switch (rank) {
      case 1:
        badgeColor = const Color(0xFFFFD700); // Gold
        textColor = Colors.black87;
        break;
      case 2:
        badgeColor = const Color(0xFFC0C0C0); // Silver
        textColor = Colors.black87;
        break;
      case 3:
        badgeColor = const Color(0xFFCD7F32); // Bronze
        break;
      default:
        badgeColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurfaceVariant;
    }

    return Container(
      width: isTop3 ? 32 : 28,
      height: isTop3 ? 32 : 28,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        boxShadow: isTop3 ? [
          BoxShadow(
            color: badgeColor.withAlpha(100),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ] : null,
      ),
      child: Center(
        child: Text(
          rank.toString(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
