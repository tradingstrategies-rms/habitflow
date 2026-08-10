import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class HabitActionSection extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final bool isArchived;

  const HabitActionSection({
    super.key,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
    this.isArchived = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HFButton(label: 'Edit Habit', onPressed: onEdit, icon: Icons.edit),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: onArchive,
          icon: Icon(isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
          label: Text(isArchived ? 'Restore Habit' : 'Archive Habit'),
        ),
        TextButton(
          onPressed: onDelete,
          child: Text('Delete Habit', style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      ],
    );
  }
}
