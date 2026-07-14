extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String toTitleCase() {
    return split('_').map((word) => word.capitalize()).join(' ');
  }
}
