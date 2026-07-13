import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_radius.dart';

/// [HFFeedback] provides standardized methods for showing snacks and toasts.
class HFFeedback {
  /// Shows a [SnackBar] with the given [message].
  /// 
  /// Automatically clears any existing SnackBars.
  static void showSnackBar(
    BuildContext context, 
    String message, {
    bool isError = false,
    SnackBarAction? action,
  }) {
    final theme = Theme.of(context);
    
    // Clear existing snackbars to avoid stacking
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isError ? theme.colorScheme.onError : theme.colorScheme.onPrimary,
          ),
        ),
        action: action,
        backgroundColor: isError ? theme.colorScheme.error : theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HFRadius.card),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Shows a toast-like [SnackBar].
  static void showToast(BuildContext context, String message) {
    showSnackBar(context, message);
  }
}
