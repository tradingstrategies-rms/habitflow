/// [PlatformService] defines an interface for interacting with platform-specific features.
abstract class PlatformService {
  /// Triggers haptic feedback if supported.
  Future<void> hapticFeedback();

  /// Opens the system share sheet.
  Future<void> share(String message);
  
  // TODO: Add methods for DatePicker, ImagePicker, etc.
}

/// [NoOpPlatformService] is a placeholder for platform-specific interactions.
class NoOpPlatformService implements PlatformService {
  @override
  Future<void> hapticFeedback() async {}

  @override
  Future<void> share(String message) async {}
}
