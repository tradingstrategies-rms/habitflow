import '../domain/models/habit.dart';
import 'habit_model.dart';

/// [HabitMapper] handles conversion between [Habit] and [HabitModel].
class HabitMapper {
  static Habit toDomain(HabitModel model) {
    return Habit(
      id: model.id,
      title: model.title,
      description: model.description,
      frequency: model.frequency,
      category: model.category,
      difficulty: model.difficulty,
      color: model.color,
      icon: model.icon,
      schedule: model.schedule,
      reminders: model.reminders,
    );
  }

  static HabitModel fromDomain(Habit Habit) {
    return HabitModel(
      id: Habit.id,
      title: Habit.title,
      description: Habit.description,
      frequency: Habit.frequency,
      category: Habit.category,
      difficulty: Habit.difficulty,
      color: Habit.color,
      icon: Habit.icon,
      schedule: Habit.schedule,
      reminders: Habit.reminders,
    );
  }
}
