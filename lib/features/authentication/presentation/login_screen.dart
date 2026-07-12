import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HFSectionHeader(title: 'Welcome Back'),
            const HFTextField(label: 'Email', hintText: 'user@example.com'),
            const SizedBox(height: 16),
            const HFTextField(label: 'Password', obscureText: true),
            const SizedBox(height: 24),
            HFButton(label: 'Login', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
