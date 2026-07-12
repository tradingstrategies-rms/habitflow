import 'package:flutter/widgets.dart';

/// [PlatformWidget] is a base class for widgets that render differently on Android and iOS.
abstract class PlatformWidget<A extends Widget, I extends Widget> extends StatelessWidget {
  const PlatformWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement platform check once Cupertino dependencies are added
    return createAndroidWidget(context);
  }

  A createAndroidWidget(BuildContext context);
  I createIosWidget(BuildContext context);
}
