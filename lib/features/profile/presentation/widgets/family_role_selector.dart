import 'package:flutter/material.dart';
import 'package:habitflow/features/profile/domain/family_role.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';

class FamilyRoleSelector extends StatelessWidget {
  const FamilyRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  final FamilyRole selectedRole;
  final ValueChanged<FamilyRole> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FAMILY ROLE',
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            color: theme.colorScheme.onSurface.withAlpha(HFOpacity.alpha60),
          ),
        ),
        const SizedBox(height: HFSpacing.s),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withAlpha(HFOpacity.alpha20),
            ),
          ),
          child: Row(
            children: FamilyRole.values.map((role) {
              final isSelected = selectedRole == role;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onRoleChanged(role),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      role.label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
