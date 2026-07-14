import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/habit.dart';
import '../../application/habit_controller.dart';

class HabitEditScreen extends ConsumerStatefulWidget {
  const HabitEditScreen({super.key, this.habit});
  final Habit? habit;

  @override
  ConsumerState<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends ConsumerState<HabitEditScreen> {
  final _formKey = GlobalKey<FormState>();
  // Form controllers would go here
  
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(habitControllerProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text(widget.habit == null ? 'Create Habit' : 'Edit Habit')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Fields here
            ElevatedButton(
              onPressed: state.isLoading ? null : () {
                if (_formKey.currentState?.validate() ?? false) {
                  // Submit
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
