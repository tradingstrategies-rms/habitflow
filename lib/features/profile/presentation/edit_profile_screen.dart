import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/features/profile/application/profile_controller.dart';
import 'package:habitflow/features/profile/data/profile_providers.dart';
import 'package:habitflow/features/profile/domain/family_role.dart';
import 'package:habitflow/features/profile/domain/user_profile.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'widgets/family_role_selector.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _birthdayController = TextEditingController();
  
  FamilyRole _selectedRole = FamilyRole.parent;
  DateTime? _selectedBirthday;
  String _selectedCountry = 'United States';
  String _selectedLanguage = 'English (US)';
  String _selectedTimezone = '(GMT+00:00) London';
  String? _photoUrl;

  bool _isInitialized = false;

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
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _displayNameController.text = profile.displayName;
    _selectedBirthday = profile.birthday;
    if (_selectedBirthday != null) {
      _birthdayController.text = "${_selectedBirthday!.toLocal()}".split(' ')[0];
    }
    _selectedRole = profile.familyRole;
    _selectedCountry = profile.country;
    _selectedLanguage = profile.language;
    _selectedTimezone = profile.timezone;
    _photoUrl = profile.photoUrl;
    _isInitialized = true;
  }

  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
        _birthdayController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _saveProfile(UserProfile currentProfile) async {
    final updatedProfile = currentProfile.copyWith(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      displayName: _displayNameController.text,
      birthday: _selectedBirthday,
      country: _selectedCountry,
      language: _selectedLanguage,
      timezone: _selectedTimezone,
      familyRole: _selectedRole,
      photoUrl: _photoUrl,
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

        ref.listen(profileControllerProvider, (previous, next) {
          next.whenOrNull(
            error: (error, stack) {
              HFFeedback.showSnackBar(context, error.toString(), isError: true);
            },
          );
        });

        return HFLoadingOverlay(
          isLoading: profileState.isLoading,
          child: Scaffold(
            appBar: HFTopAppBar(
              title: 'Edit Profile',
              centerTitle: true,
              leading: HFIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: profileState.isLoading ? null : () => context.pop(),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar Section
                  GestureDetector(
                    onTap: profileState.isLoading ? null : () async {
                      final newUrl = await context.pushNamed(RouteNames.avatarSelection);
                      if (newUrl != null && newUrl is String) {
                        setState(() => _photoUrl = newUrl);
                      }
                    },
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            HFAvatar(
                              imageUrl: _photoUrl,
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
                        const SizedBox(height: 12),
                        Text(
                          'CHANGE PHOTO',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Form
                  FamilyRoleSelector(
                    selectedRole: _selectedRole,
                    onRoleChanged: profileState.isLoading 
                        ? (_) {} 
                        : (role) => setState(() => _selectedRole = role),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: HFTextField(
                          controller: _firstNameController,
                          label: 'FIRST NAME',
                          hintText: 'First name',
                          textInputAction: TextInputAction.next,
                          enabled: !profileState.isLoading,
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
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: profileState.isLoading ? null : _selectBirthday,
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
                  const SizedBox(height: 40),
                  HFButton(
                    label: 'Save Changes',
                    onPressed: () => _saveProfile(profile),
                    isLoading: profileState.isLoading,
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: HFLoadingIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}
