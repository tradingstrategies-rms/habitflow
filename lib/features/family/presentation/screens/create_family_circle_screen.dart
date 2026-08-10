import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/family/domain/entities/family_circle.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';

class CreateFamilyCircleScreen extends ConsumerStatefulWidget {
  const CreateFamilyCircleScreen({super.key});

  @override
  ConsumerState<CreateFamilyCircleScreen> createState() => _CreateFamilyCircleScreenState();
}

class _CreateFamilyCircleScreenState extends ConsumerState<CreateFamilyCircleScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _create() {
    if (_formKey.currentState!.validate()) {
      final circle = FamilyCircle(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        ownerProfileId: 'owner-1',
        createdAt: DateTime.now(),
      );
      ref.read(familyProvider.notifier).createFamily(circle).then((_) {
        if (mounted) {
          final updatedState = ref.read(familyProvider);
          if (updatedState.circle != null) {
            GoRouter.of(context).goNamed(RouteNames.family);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to create family: ${updatedState.error ?? 'Unknown error'}')),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Family Circle')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(HFSpacing.m),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Family Group Name'),
                validator: (value) {
                  if (value == null || value.length < 3 || value.length > 40) {
                    return 'Name must be 3-40 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: HFSpacing.l),
              ElevatedButton(
                onPressed: state.isLoading ? null : _create,
                child: state.isLoading ? const CircularProgressIndicator() : const Text('Create Family'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
