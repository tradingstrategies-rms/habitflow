/// [PermissionService] defines the interface for requesting and checking platform permissions.
abstract class PermissionService {
  /// Requests permission for the camera.
  Future<bool> requestCamera();

  /// Requests permission for the photo gallery.
  Future<bool> requestPhotos();

  /// Requests permission for notifications.
  Future<bool> requestNotifications();

  /// Requests permission for location.
  Future<bool> requestLocation();

  /// Requests permission for the microphone.
  Future<bool> requestMicrophone();
}

/// [NoOpPermissionService] is a placeholder implementation.
class NoOpPermissionService implements PermissionService {
  // TODO: Implement permission_handler in later sprints.
  
  @override
  Future<bool> requestCamera() async => true;

  @override
  Future<bool> requestPhotos() async => true;

  @override
  Future<bool> requestNotifications() async => true;

  @override
  Future<bool> requestLocation() async => true;

  @override
  Future<bool> requestMicrophone() async => true;
}
