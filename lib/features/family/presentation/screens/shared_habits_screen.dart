import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/family/domain/entities/shared_habit.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import 'package:habitflow/features/family/presentation/widgets/member_avatar.dart';

class SharedHabitsScreen extends ConsumerWidget {
  const SharedHabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedHabitsAsync = ref.watch(sharedHabitsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Habits'),
      ),
      body: sharedHabitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.checklist_rtl, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  const Text('No shared habits yet.'),
                  const SizedBox(height: 8),
                  const Text('Create one to grow together!'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(HFSpacing.m),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final sharedHabit = habits[index];
              return _SharedHabitListItem(sharedHabit: sharedHabit);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(RouteNames.createHabit, extra: {'isShared': true}),
        icon: const Icon(Icons.add),
        label: const Text('New Shared Habit'),
      ),
    );
  }
}

class _SharedHabitListItem extends ConsumerWidget {
  final SharedHabit sharedHabit;
  const _SharedHabitListItem({required this.sharedHabit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitByIdProvider(sharedHabit.habitId));
    final theme = Theme.of(context);
    final familyProfiles = ref.watch(familyProvider).profiles;

    return habitAsync.when(
      data: (habit) {
        if (habit == null) return const SizedBox.shrink();

        final anyCompletion = ref.watch(anyTodayCompletionProvider(habit.id)).value;
        final isCompleted = anyCompletion != null;

        return Card(
          margin: const EdgeInsets.only(bottom: HFSpacing.m),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: InkWell(
            onTap: () => context.pushNamed(
              RouteNames.familySharedHabitDetails,
              pathParameters: {'sharedHabitId': sharedHabit.id},
              extra: sharedHabit,
            ),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.checklist_rtl, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(habit.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            Text(
                              sharedHabit.completionMode.displayName,
                              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary),
                            ),
                          ],
                        ),
                      ),
                      if (isCompleted)
                        const Icon(Icons.check_circle, color: Colors.green)
                      else
                        Icon(Icons.circle_outlined, color: theme.colorScheme.outline),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Assigned:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: Stack(
                            children: sharedHabit.assignedMemberIds.asMap().entries.map((entry) {
                              final profile = familyProfiles.firstWhere((p) => p.id == entry.value, orElse: () => familyProfiles.first);
                              return Positioned(
                                left: entry.key * 20.0,
                                child: MemberAvatar(
                                  profileType: profile.profileType,
                                  avatarUrl: profile.avatarUrl,
                                  radius: 14,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Card(child: ListTile(title: Text('Loading...'))),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
