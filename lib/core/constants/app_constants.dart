/// [AppConstants] is the single source of truth for application-level constants.
class AppConstants {
  /// The name of the application.
  static const String appName = 'HabitFlow';
  
  /// The current version of the application.
  static const String appVersion = '1.0.0';
  
  /// Flag to indicate if the application is running in production mode.
  static const bool isProduction = false;

  /// The required length for the parent PIN.
  static const int parentPinLength = 4;

  /// The maximum number of family members allowed.
  static const int maxFamilyMembers = 20;

  /// Standard duration for fast animations.
  static const Duration animationFast = Duration(milliseconds: 200);
  
  /// Standard duration for normal animations.
  static const Duration animationNormal = Duration(milliseconds: 300);
  
  /// Standard duration for slow animations.
  static const Duration animationSlow = Duration(milliseconds: 500);
}
