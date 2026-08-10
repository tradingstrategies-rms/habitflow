import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitflow/core/sync/datasources/sync_queue_datasource.dart';
import 'package:habitflow/core/sync/models/sync_operation.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late SyncQueueDataSourceImpl dataSource;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    dataSource = SyncQueueDataSourceImpl(mockPrefs);
  });

  group('SyncQueueDataSource', () {
    test('addToQueue and getQueue work correctly', () async {
      when(() => mockPrefs.getString(any())).thenReturn(null);
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      final operation = SyncOperation(
        id: '1',
        profileId: 'p1',
        type: SyncOperationType.addTransaction,
        data: const {'test': 'data'},
        createdAt: DateTime.now(),
      );

      await dataSource.addToQueue('u1', operation);
      verify(() => mockPrefs.setString('sync_queue_u1', any())).called(1);
    });

    test('removeFromQueue works correctly', () async {
      final operation = SyncOperation(
        id: '1',
        profileId: 'p1',
        type: SyncOperationType.addTransaction,
        data: const {'test': 'data'},
        createdAt: DateTime.now(),
      );

      when(() => mockPrefs.getString('sync_queue_u1')).thenReturn(json.encode([operation.toJson()]));
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      await dataSource.removeFromQueue('u1', '1');
      verify(() => mockPrefs.setString('sync_queue_u1', '[]')).called(1);
    });
  });
}
