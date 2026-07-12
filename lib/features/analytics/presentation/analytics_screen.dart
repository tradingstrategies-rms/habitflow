import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: HFTopAppBar(title: 'Analytics'),
      body: Center(
        child: HFStatCard(label: 'Total Habits Completed', value: '452'),
      ),
    );
  }
}
