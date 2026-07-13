import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/features/authentication/data/auth_providers.dart';
import 'package:habitflow/features/profile/application/profile_controller.dart';
import 'package:habitflow/features/profile/domain/family_role.dart';
import 'package:habitflow/features/profile/domain/user_profile.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'widgets/family_role_selector.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _birthdayController = TextEditingController();
  
  FamilyRole _selectedRole = FamilyRole.parent;
  DateTime? _selectedBirthday;
  final String _selectedCountry = 'United States';
  final String _selectedLanguage = 'English (US)';
  final String _selectedTimezone = '(GMT+00:00) London';
  String? _photoUrl;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
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

  Future<void> _saveProfile() async {
    final authState = ref.read(authStateProvider);
    final uid = authState.value;
    if (uid == null) return;

    if (_firstNameController.text.isEmpty || _displayNameController.text.isEmpty) {
      HFFeedback.showSnackBar(context, 'Please fill in all required fields', isError: true);
      return;
    }

    final profile = UserProfile(
      uid: uid,
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

    await ref.read(profileControllerProvider.notifier).saveProfile(profile);
    if (mounted && !ref.read(profileControllerProvider).hasError) {
      context.goNamed(RouteNames.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          title: 'Create Profile',
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
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.colorScheme.surface, width: 2),
                            ),
                            child: Icon(Icons.add_a_photo_rounded, size: 20, color: theme.colorScheme.onPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ADD PHOTO',
                      style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
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
              const SizedBox(height: 24),
              
              const HFSectionHeader(title: 'Location & Settings'),
              const SizedBox(height: 16),

              HFButton(
                label: 'Continue',
                onPressed: _saveProfile,
                isLoading: profileState.isLoading,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
