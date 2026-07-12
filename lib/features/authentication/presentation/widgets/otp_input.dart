import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';

/// [OTPInput] is a configurable digit input field for verification codes.
class OTPInput extends StatelessWidget {
  const OTPInput({
    super.key,
    this.length = 4,
    this.onChanged,
    this.onCompleted,
  });

  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<TextEditingController> controllers = List.generate(length, (_) => TextEditingController());
    final List<FocusNode> focusNodes = List.generate(length, (_) => FocusNode());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(length, (index) {
        return SizedBox(
          width: length == 4 ? 64 : 48,
          height: 64,
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(HFOpacity.alpha40),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              if (value.length == 1 && index < length - 1) {
                focusNodes[index + 1].requestFocus();
              }
              if (value.isEmpty && index > 0) {
                focusNodes[index - 1].requestFocus();
              }
              
              final otp = controllers.map((c) => c.text).join();
              onChanged?.call(otp);
              if (otp.length == length) {
                onCompleted?.call(otp);
              }
            },
          ),
        );
      }),
    );
  }
}
