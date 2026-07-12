/// [ConnectivityService] defines the interface for monitoring network status.
abstract class ConnectivityService {
  /// Returns whether the device is currently connected to the internet.
  Future<bool> isConnected();

  /// A stream of connectivity status changes.
  Stream<bool> get connectivityStream;
}

/// [NoOpConnectivityService] is a placeholder implementation.
class NoOpConnectivityService implements ConnectivityService {
  // TODO: Implement actual connectivity monitoring (connectivity_plus) in later sprints.
  
  @override
  Future<bool> isConnected() async => true;

  @override
  Stream<bool> get connectivityStream => Stream.value(true);
}
