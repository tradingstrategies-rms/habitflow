import 'dart:io';
import 'package:flutter/foundation.dart';

/// [PlatformHelper] provides utilities for identifying the current platform.
class PlatformHelper {
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWeb => kIsWeb;
  static bool get isDesktop => !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
  
  static String get platformName {
    if (kIsWeb) return 'Web';
    return Platform.operatingSystem;
  }
}
