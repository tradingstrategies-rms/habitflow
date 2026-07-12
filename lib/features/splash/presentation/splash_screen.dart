import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HFAvatar(initials: 'HF', size: 80),
            SizedBox(height: 24),
            Text(
              'HabitFlow',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            HFLoadingIndicator(),
          ],
        ),
      ),
    );
  }
}
