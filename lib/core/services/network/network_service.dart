/// [NetworkService] defines the interface for making HTTP requests.
abstract class NetworkService {
  /// Makes a GET request.
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters});

  /// Makes a POST request.
  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters});

  /// Makes a PUT request.
  Future<dynamic> put(String path, {dynamic data, Map<String, dynamic>? queryParameters});

  /// Makes a DELETE request.
  Future<dynamic> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters});
  
  // TODO: Add support for file upload, GraphQL, and more complex retry policies.
}

/// [NoOpNetworkService] is a placeholder implementation.
class NoOpNetworkService implements NetworkService {
  // TODO: Implement Dio-based NetworkService in later sprints.
  
  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async => null;

  @override
  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async => null;

  @override
  Future<dynamic> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async => null;

  @override
  Future<dynamic> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async => null;
}
