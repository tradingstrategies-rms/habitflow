import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/home/presentation/widgets/intelligence_preview_card.dart';
import 'package:habitflow/features/intelligence/application/providers/intelligence_providers.dart';

void main() {
  testWidgets('IntelligencePreviewCard renders loading state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          intelligenceSummaryProvider.overrideWith((ref) => Future.value(null)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: IntelligencePreviewCard(onTap: () {}),
          ),
        ),
      ),
    );

    // Initial state might be loading, then null data
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });
}
