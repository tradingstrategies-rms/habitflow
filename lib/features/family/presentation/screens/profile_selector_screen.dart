import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';

class ProfileSelectorScreen extends ConsumerWidget {
  const ProfileSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(familyProfilesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Profile')),
      body: profilesAsync.when(
        data: (profiles) {
          if (profiles.isEmpty) return const Center(child: Text('No profiles found'));
          return ListView.builder(
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(profile.displayName),
                subtitle: Text(profile.role.name.toUpperCase()),
                trailing: profile.requiresPin ? const Icon(Icons.lock_outline, size: 16) : null,
                onTap: () async {
                  final repo = ref.read(familyRepositoryProvider);
                  final hasPin = await repo.hasParentPin();
                  
                  if (profile.requiresPin && hasPin) {
                    if (context.mounted) {
                      context.pushNamed(RouteNames.familyPin, extra: profile);
                    }
                  } else {
                    await ref.read(activeProfileSessionProvider.notifier).startSession(profile.id, false);
                    if (context.mounted) {
                      context.goNamed(profile.profileType == ProfileType.child 
                          ? RouteNames.familyChild 
                          : RouteNames.family);
                    }
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
