import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/core/bootstrap/bootstrap_gate.dart';
import 'package:habitflow/shared/widgets/foundation/hf_loading_indicator.dart';

void main() {
  testWidgets('BootstrapGate shows loading indicator initially', (tester) async {
    // We don't need to mock Bootstrap here if we just want to see the initial state
    // because it will start as loading.
    await tester.pumpWidget(const BootstrapGate());
    
    expect(find.byType(HFLoadingIndicator), findsOneWidget);
    expect(find.text('Initializing services...'), findsOneWidget);
  });
}
