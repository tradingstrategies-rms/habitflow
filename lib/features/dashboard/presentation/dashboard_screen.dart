import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                HFSectionHeader(title: 'Overview'),
                HFStatCard(label: 'Daily Score', value: '85%'),
                SizedBox(height: 16),
                HFSectionHeader(title: 'Top Habit'),
                HFHabitTile(title: 'Morning Run', isCompleted: true, streakCount: 12),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
