import 'package:flutter/material.dart';
import '../../domain/enums/redemption_status.dart';

class RedemptionStatusBadge extends StatelessWidget {
  final RedemptionStatus status;

  const RedemptionStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color color;
    final String label;

    switch (status) {
      case RedemptionStatus.pending:
        color = Colors.orange;
        label = 'PENDING';
        break;
      case RedemptionStatus.approved:
        color = Colors.blue;
        label = 'APPROVED';
        break;
      case RedemptionStatus.rejected:
        color = theme.colorScheme.error;
        label = 'REJECTED';
        break;
      case RedemptionStatus.fulfilled:
        color = Colors.green;
        label = 'FULFILLED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
