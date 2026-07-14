import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/use_cases/completion/mark_habit_complete.dart';
import '../../data/habit_providers.dart';
import '../../domain/models/habit_id.dart';

final markCompleteProvider = Provider((ref) => MarkHabitComplete(ref.read(completionRepositoryProvider)));

class CompletionController extends StateNotifier<AsyncValue<void>> {
  CompletionController(this.markHabitComplete, this.ref) : super(const AsyncData(null));

  final MarkHabitComplete markHabitComplete;
  final Ref ref;

  Future<void> toggleCompletion(HabitId habitId, bool isCompleted) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (!isCompleted) {
        await markHabitComplete(habitId, DateTime.now());
      }
      // Note: Undo logic was requested only if available.
    });
    ref.read(allHabitsProvider.notifier).refresh();
  }
}

final completionControllerProvider = StateNotifierProvider<CompletionController, AsyncValue<void>>((ref) {
  return CompletionController(ref.read(markCompleteProvider), ref);
});
