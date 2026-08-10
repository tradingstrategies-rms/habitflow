import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sync_status.dart';
import '../datasources/sync_queue_datasource.dart';
import '../../../core/theme/theme_controller.dart';

final syncStatusProvider = StateProvider<SyncStatus>((ref) => SyncStatus.idle);

final syncQueueDataSourceProvider = Provider<SyncQueueDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SyncQueueDataSourceImpl(prefs);
});
