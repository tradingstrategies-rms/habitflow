import 'package:flutter/foundation.dart';
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
    debugPrint("toggleCompletion called");
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (!isCompleted) {
        debugPrint("Complete");
        await markHabitComplete(habitId, DateTime.now());
      } else {
        debugPrint("Undo");
        await ref.read(completionRepositoryProvider).undoCompletion(habitId, DateTime.now());
      }
    });
    ref.read(todaysCompletionsProvider.notifier).refresh();
  }
}

final completionControllerProvider = StateNotifierProvider<CompletionController, AsyncValue<void>>((ref) {
  return CompletionController(ref.read(markCompleteProvider), ref);
});
