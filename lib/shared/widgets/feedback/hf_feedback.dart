import 'package:flutter/material.dart';

/// [HFFeedback] provides standardized methods for showing snacks and toasts.
class HFFeedback {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? theme.colorScheme.error : theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showToast(BuildContext context, String message) {
    // Standard Flutter doesn't have a Toast, SnackBar is the closest official replacement.
    showSnackBar(context, message);
  }
}
