import 'package:flutter/material.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'package:habitflow/features/authentication/application/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: const HFTopAppBar(title: 'Settings'),
      body: ListView(
        children: [
          const HFSectionHeader(title: 'Appearance'),
          ListTile(
            title: const Text('Theme Mode'),
            subtitle: Text(themeMode.name.toUpperCase()),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              _showThemePicker(context, ref);
            },
          ),
          const HFSectionHeader(title: 'Account'),
          ListTile(
            title: const Text('Logout'),
            textColor: Theme.of(context).colorScheme.error,
            leading: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.error),
            onTap: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: HFThemeMode.values.map((mode) {
            return ListTile(
              title: Text(mode.name.toUpperCase()),
              onTap: () {
                ref.read(themeControllerProvider.notifier).setThemeMode(mode);
                Navigator.pop(context);
              },
              trailing: ref.read(themeControllerProvider) == mode 
                  ? const Icon(Icons.check_rounded, color: Colors.green) 
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }
}
