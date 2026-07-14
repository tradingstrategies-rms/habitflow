import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/features/profile/application/profile_controller.dart';
import 'package:habitflow/features/profile/data/profile_providers.dart';
import 'package:habitflow/features/profile/domain/family_role.dart';
import 'package:habitflow/features/profile/domain/user_profile.dart';
import 'package:habitflow/features/profile/presentation/avatar_selection_screen.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'widgets/family_role_selector.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _birthdayController = TextEditingController();
  
  FamilyRole _selectedRole = FamilyRole.parent;
  DateTime? _selectedBirthday;
  String _selectedCountry = 'United States';
  String _selectedTimezone = 'UTC';
  AvatarItem? _selectedAvatar;

  bool _isInitialized = false;
  late UserProfile _initialProfile;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  void _initFields(UserProfile profile) {
    if (_isInitialized) return;
    _initialProfile = profile;
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _displayNameController.text = profile.displayName;
    _selectedBirthday = profile.birthday;
    if (_selectedBirthday != null) {
      _birthdayController.text = "${_selectedBirthday!.toLocal()}".split(' ')[0];
    }
    _selectedRole = profile.familyRole;
    _selectedCountry = profile.country;
    _selectedTimezone = profile.timezone;
    if (profile.avatarId != null) {
      _selectedAvatar = AvatarItem(
        id: profile.avatarId!,
        name: 'Selected Avatar',
        url: profile.photoUrl ?? '',
        category: 'Personal',
      );
    }
    _firstNameController.addListener(() => setState(() {}));
    _lastNameController.addListener(() => setState(() {}));
    _displayNameController.addListener(() => setState(() {}));
    _isInitialized = true;
  }

  bool get _hasChanges {
    if (!_isInitialized) return false;
    return _firstNameController.text != _initialProfile.firstName ||
           _lastNameController.text != _initialProfile.lastName ||
           _displayNameController.text != _initialProfile.displayName ||
           _selectedBirthday != _initialProfile.birthday ||
           _selectedRole != _initialProfile.familyRole ||
           _selectedCountry != _initialProfile.country ||
           _selectedTimezone != _initialProfile.timezone ||
           _selectedAvatar?.id != _initialProfile.avatarId;
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _saveProfile(UserProfile currentProfile) async {
    if (!_formKey.currentState!.validate()) return;

    final updatedProfile = currentProfile.copyWith(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      displayName: _displayNameController.text,
      birthday: _selectedBirthday,
      country: _selectedCountry,
      timezone: _selectedTimezone,
      familyRole: _selectedRole,
      avatarId: _selectedAvatar?.id,
      photoUrl: _selectedAvatar?.url,
    );

    await ref.read(profileControllerProvider.notifier).saveProfile(updatedProfile);
    if (mounted && !ref.read(profileControllerProvider).hasError) {
      HFFeedback.showSnackBar(context, 'Profile updated successfully');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const Scaffold(body: Center(child: Text('No profile found')));
        _initFields(profile);

        final profileState = ref.watch(profileControllerProvider);

        return PopScope(
          canPop: !_hasChanges,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldPop = await _onWillPop();
            if (shouldPop && context.mounted) {
              context.pop();
            }
          },
          child: HFLoadingOverlay(
            isLoading: profileState.isLoading,
            child: Scaffold(
              appBar: HFTopAppBar(
                title: 'Edit Profile',
                centerTitle: true,
                leading: HFIconButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: () async {
                    final shouldPop = await _onWillPop();
                    if (shouldPop && context.mounted) context.pop();
                  },
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Avatar Section
                      Center(
                        child: Hero(
                          tag: _selectedAvatar != null ? 'avatar_${_selectedAvatar!.id}' : 'current_avatar',
                          child: GestureDetector(
                            onTap: profileState.isLoading ? null : () async {
                              final result = await context.pushNamed(RouteNames.avatarSelection);
                              if (result != null && result is AvatarItem) {
                                setState(() => _selectedAvatar = result);
                              }
                            },
                            child: Stack(
                              children: [
                                HFAvatar(
                                  imageUrl: _selectedAvatar?.url,
                                  initials: _firstNameController.text.isNotEmpty 
                                      ? _firstNameController.text[0] 
                                      : '?',
                                  size: 120,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                                    ),
                                    child: Icon(Icons.edit_rounded, size: 20, color: Theme.of(context).colorScheme.onPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      const HFSectionHeader(title: 'PERSONAL DETAILS'),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: HFTextField(
                              controller: _firstNameController,
                              label: 'FIRST NAME',
                              hintText: 'First name',
                              textInputAction: TextInputAction.next,
                              enabled: !profileState.isLoading,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: HFTextField(
                              controller: _lastNameController,
                              label: 'LAST NAME',
                              hintText: 'Last name',
                              textInputAction: TextInputAction.next,
                              enabled: !profileState.isLoading,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      HFTextField(
                        controller: _displayNameController,
                        label: 'DISPLAY NAME',
                        hintText: 'How should we call you?',
                        prefixIcon: const Icon(Icons.alternate_email_rounded),
                        textInputAction: TextInputAction.next,
                        enabled: !profileState.isLoading,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: profileState.isLoading ? null : () async {
                           final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedBirthday ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedBirthday = picked;
                              _birthdayController.text = "${picked.toLocal()}".split(' ')[0];
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: HFTextField(
                            controller: _birthdayController,
                            label: 'DATE OF BIRTH',
                            hintText: 'Select date',
                            prefixIcon: const Icon(Icons.calendar_today_rounded),
                            enabled: !profileState.isLoading,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      FamilyRoleSelector(
                        selectedRole: _selectedRole,
                        onRoleChanged: profileState.isLoading 
                            ? (_) {} 
                            : (role) => setState(() => _selectedRole = role),
                      ),

                      const SizedBox(height: 32),
                      const HFSectionHeader(title: 'REGIONAL SETTINGS'),
                      const SizedBox(height: 16),
                      
                      _buildSelector(
                        context,
                        label: 'COUNTRY',
                        value: _selectedCountry,
                        icon: Icons.public_rounded,
                        onTap: () => _showPicker(context, 'Country', ['United States', 'United Kingdom', 'Germany'], (v) => setState(() => _selectedCountry = v)),
                      ),
                      const SizedBox(height: 16),
                      _buildSelector(
                        context,
                        label: 'TIME ZONE',
                        value: _selectedTimezone,
                        icon: Icons.schedule_rounded,
                        onTap: () => _showPicker(context, 'Time Zone', ['UTC', 'PST', 'EST', 'CET'], (v) => setState(() => _selectedTimezone = v)),
                      ),

                      const SizedBox(height: 40),
                      HFButton(
                        label: 'Save Changes',
                        onPressed: _hasChanges && !profileState.isLoading ? () => _saveProfile(profile) : null,
                        isLoading: profileState.isLoading,
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: HFLoadingIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }

  Widget _buildSelector(BuildContext context, {required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
                const Icon(Icons.keyboard_arrow_down_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context, String title, List<String> options, ValueChanged<String> onSelected) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select $title', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...options.map((opt) => ListTile(
              title: Text(opt),
              onTap: () {
                onSelected(opt);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}
