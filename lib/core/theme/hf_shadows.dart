import 'package:flutter/material.dart';

/// [HFShadows] defines the elevation and shadow tokens for HabitFlow.
class HFShadows {
  /// Light shadow for Level 1 elevation (Cards).
  static const List<BoxShadow> light = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  /// Medium shadow for Level 2 elevation (Floating Cards).
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  /// Heavy shadow for Level 3 elevation (Dialogs).
  static const List<BoxShadow> heavy = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 30,
      offset: Offset(0, 12),
    ),
  ];
}
