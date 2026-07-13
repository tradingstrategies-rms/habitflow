import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [splashMinTimeReachedProvider] tracks if the minimum display time for the splash screen has passed.
final splashMinTimeReachedProvider = StateProvider<bool>((ref) => false);
