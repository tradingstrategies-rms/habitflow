import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/permission_service.dart';

final familyPermissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});
