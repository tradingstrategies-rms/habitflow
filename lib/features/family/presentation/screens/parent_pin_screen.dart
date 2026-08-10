import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';

class ParentPinScreen extends ConsumerStatefulWidget {
  final FamilyProfile profile;
  const ParentPinScreen({super.key, required this.profile});

  @override
  ConsumerState<ParentPinScreen> createState() => _ParentPinScreenState();
}

class _ParentPinScreenState extends ConsumerState<ParentPinScreen> {
  final _pinController = TextEditingController();
  String _error = '';

  Future<void> _verify() async {
    final verified = await ref.read(activeProfileSessionProvider.notifier).verifyPin(_pinController.text);
    if (verified) {
      await ref.read(activeProfileSessionProvider.notifier).startSession(widget.profile.id, true);
      if (mounted) {
        context.goNamed(RouteNames.family);
      }
    } else {
      if (mounted) {
        setState(() {
          _error = 'Invalid PIN. Please try again.';
          _pinController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Parent Verification')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              'Enter PIN for ${widget.profile.displayName}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 16),
                decoration: InputDecoration(
                  hintText: '••••',
                  errorText: _error.isNotEmpty ? _error : null,
                  border: const UnderlineInputBorder(),
                ),
                maxLength: 6,
                onChanged: (v) {
                  if (v.length >= 4) {
                    setState(() => _error = '');
                  }
                  if (v.length == 6) {
                    _verify();
                  }
                },
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _verify,
                child: const Text('Verify PIN'),
              ),
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
