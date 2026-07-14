/// [HabitIcon] represents the icon associated with a habit.
class HabitIcon {
  const HabitIcon(this.value);
  final String value; // Icon identifier or asset path

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitIcon && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
