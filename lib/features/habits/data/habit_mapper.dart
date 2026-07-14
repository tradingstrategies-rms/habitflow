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
      isArchived: model.isArchived,
    );
  }

  static HabitModel fromDomain(Habit habit) {
    return HabitModel(
      id: habit.id,
      title: habit.title,
      description: habit.description,
      frequency: habit.frequency,
      category: habit.category,
      difficulty: habit.difficulty,
      color: habit.color,
      icon: habit.icon,
      schedule: habit.schedule,
      reminders: habit.reminders,
      isArchived: habit.isArchived,
    );
  }
}
