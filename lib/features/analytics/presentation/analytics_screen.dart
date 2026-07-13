import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HFTopAppBar(title: 'Analytics'),
      body: Center(
        child: HFEmptyState(
          title: 'Insights',
          message: 'Analyze your family\'s progress over time.',
          icon: Icons.bar_chart_rounded,
          actionLabel: 'View Detailed Report',
          onActionPressed: () {
            // TODO: Navigate to detailed analytics in Sprint 2
          },
        ),
      ),
    );
  }
}
