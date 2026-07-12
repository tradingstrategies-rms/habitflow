import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: HFTopAppBar(title: 'Settings'),
      body: Center(
        child: Text('Settings Screen Placeholder'),
      ),
    );
  }
}
