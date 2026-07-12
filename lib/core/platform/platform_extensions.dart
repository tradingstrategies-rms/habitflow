import 'package:flutter/widgets.dart';
import 'platform_helper.dart';

/// [PlatformExtensions] provides extension methods for quick platform checks on BuildContext.
extension PlatformExtensions on BuildContext {
  bool get isAndroid => PlatformHelper.isAndroid;
  bool get isIOS => PlatformHelper.isIOS;
  bool get isWeb => PlatformHelper.isWeb;
}
