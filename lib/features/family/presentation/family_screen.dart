import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HFTopAppBar(title: 'Family'),
      body: Center(
        child: HFEmptyState(
          title: 'Family Tree',
          message: 'Invite your family members to grow together.',
          icon: Icons.people_outline_rounded,
          actionLabel: 'Invite Member',
          onActionPressed: () {
            // TODO: Navigate to Invite Member screen in Sprint 2
          },
        ),
      ),
    );
  }
}
