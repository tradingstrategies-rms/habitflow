import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/family_provider.dart';

class SetupPinScreen extends ConsumerStatefulWidget {
  const SetupPinScreen({super.key});

  @override
  ConsumerState<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends ConsumerState<SetupPinScreen> {
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _hasExistingPin = false;
  bool _isLoading = true;
  int _currentStep = 0; // 0: Verify current, 1: Enter new, 2: Confirm new

  @override
  void initState() {
    super.initState();
    _checkPin();
  }

  Future<void> _checkPin() async {
    final repo = ref.read(familyRepositoryProvider);
    final exists = await repo.hasParentPin();
    if (mounted) {
      setState(() {
        _hasExistingPin = exists;
        _currentStep = exists ? 0 : 1;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _verifyCurrentPin() async {
    final repo = ref.read(familyRepositoryProvider);
    final isValid = await repo.verifyParentPin(_currentPinController.text);
    if (isValid) {
      setState(() => _currentStep = 1);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect current PIN')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final repo = ref.read(familyRepositoryProvider);
      await repo.saveParentPin(_newPinController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parent PIN updated successfully')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_hasExistingPin ? 'Change Parent PIN' : 'Set Parent PIN'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentStep == 0) ...[
                const Text('Enter your current PIN to continue.', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 32),
                _buildPinField(
                  controller: _currentPinController,
                  label: 'Current PIN',
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _verifyCurrentPin,
                    child: const Text('Verify'),
                  ),
                ),
              ] else ...[
                const Text('Choose a 4-6 digit PIN to secure your account.', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 32),
                _buildPinField(
                  controller: _newPinController,
                  label: 'New PIN',
                  validator: (v) {
                    if (v == null || v.length < 4 || v.length > 6) {
                      return 'PIN must be 4-6 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildPinField(
                  controller: _confirmPinController,
                  label: 'Confirm New PIN',
                  validator: (v) => v != _newPinController.text ? 'PINs do not match' : null,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save PIN'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        counterText: '',
      ),
      keyboardType: TextInputType.number,
      maxLength: 6,
      obscureText: true,
      validator: validator,
    );
  }
}
