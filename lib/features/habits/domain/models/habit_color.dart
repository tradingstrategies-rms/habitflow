/// [HabitColor] represents the color associated with a habit.
class HabitColor {
  const HabitColor(this.value);
  final int value; // Represents ARGB color

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitColor && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
