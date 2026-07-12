/// [HFDurations] defines the animation duration tokens for HabitFlow.
class HFDurations {
  /// 150ms - Quick interactions like button presses.
  static const Duration fast = Duration(milliseconds: 150);
  
  /// 300ms - Standard transitions.
  static const Duration normal = Duration(milliseconds: 300);
  
  /// 500ms - Larger UI changes.
  static const Duration slow = Duration(milliseconds: 500);
  
  /// 800ms - Entrance animations or complex transitions.
  static const Duration extraSlow = Duration(milliseconds: 800);
}
