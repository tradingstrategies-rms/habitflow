import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/core/sync/models/sync_status.dart';
import 'package:habitflow/core/sync/providers/sync_providers.dart';
import 'package:habitflow/core/sync/widgets/sync_status_indicator.dart';

void main() {
  testWidgets('SyncStatusIndicator shows syncing state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncStatusProvider.overrideWith((ref) => SyncStatus.syncing),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SyncStatusIndicator(),
          ),
        ),
      ),
    );

    expect(find.text('Syncing...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('SyncStatusIndicator shows failed state with retry', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncStatusProvider.overrideWith((ref) => SyncStatus.failed),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SyncStatusIndicator(),
          ),
        ),
      ),
    );

    expect(find.text('Sync Failed'), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
  });

  testWidgets('SyncStatusIndicator is hidden when idle or synced', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncStatusProvider.overrideWith((ref) => SyncStatus.synced),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SyncStatusIndicator(),
          ),
        ),
      ),
    );

    expect(find.byType(SyncStatusIndicator), findsOneWidget);
    expect(find.byType(InkWell), findsNothing);
  });
}
