import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

/// [HFSocialLoginButton] is a specialized button for social logins.
class HFSocialLoginButton extends StatelessWidget {
  const HFSocialLoginButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon = Icons.g_mobiledata_rounded,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return HFButton(
      label: label,
      onPressed: onPressed,
      variant: HFButtonVariant.secondary,
      isLoading: isLoading,
      icon: icon,
    );
  }
}
