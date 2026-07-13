import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

/// [HFPasswordField] is a specialized text field for passwords with a visibility toggle.
class HFPasswordField extends StatefulWidget {
  const HFPasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.hintText = 'Enter password',
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.errorText,
    this.onChanged,
    this.semanticsLabel,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String label;
  final String hintText;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final String? semanticsLabel;
  final bool enabled;

  @override
  State<HFPasswordField> createState() => _HFPasswordFieldState();
}

class _HFPasswordFieldState extends State<HFPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return HFTextField(
      controller: widget.controller,
      label: widget.label,
      hintText: widget.hintText,
      obscureText: _obscureText,
      enabled: widget.enabled,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      errorText: widget.errorText,
      onChanged: widget.onChanged,
      semanticsLabel: widget.semanticsLabel,
      prefixIcon: const Icon(Icons.lock_outline_rounded),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: widget.enabled 
            ? () => setState(() => _obscureText = !_obscureText)
            : null,
        tooltip: _obscureText ? 'Show password' : 'Hide password',
      ),
    );
  }
}
