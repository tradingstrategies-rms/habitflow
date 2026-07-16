import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/router/route_paths.dart';
import 'package:habitflow/features/authentication/data/auth_providers.dart';
import 'package:habitflow/features/profile/application/profile_controller.dart';
import 'package:habitflow/features/profile/domain/family_role.dart';
import 'package:habitflow/features/profile/domain/user_profile.dart';
import 'package:habitflow/features/profile/presentation/avatar_selection_screen.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'widgets/family_role_selector.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
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

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _selectedTimezone = DateTime.now().timeZoneName;
    _firstNameController.addListener(_validate);
    _displayNameController.addListener(_validate);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _isFormValid = _firstNameController.text.isNotEmpty && 
                     _lastNameController.text.isNotEmpty &&
                     _displayNameController.text.isNotEmpty &&
                     _selectedBirthday != null;
    });
  }

  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthday = picked;
        _birthdayController.text = "${picked.toLocal()}".split(' ')[0];
      });
      _validate();
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authStateProvider);
    final uid = authState.value;
    if (uid == null) return;

    final profile = UserProfile(
      uid: uid,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      displayName: _displayNameController.text,
      birthday: _selectedBirthday,
      country: _selectedCountry,
      language: 'English',
      timezone: _selectedTimezone,
      familyRole: _selectedRole,
      avatarId: _selectedAvatar?.id,
      photoUrl: _selectedAvatar?.url,
    );

    await ref.read(profileControllerProvider.notifier).saveProfile(profile);
    if (mounted && !ref.read(profileControllerProvider).hasError) {
      // Success navigation: Create Profile -> Avatar Selection -> Dashboard
      context.goNamed(RouteNames.avatarSelection, extra: 'onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(profileControllerProvider);

    return HFLoadingOverlay(
      isLoading: profileState.isLoading,
      child: Scaffold(
        appBar: HFTopAppBar(
          title: 'Profile Setup',
          centerTitle: true,
          leading: HFIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => context.go(RoutePaths.dashboard),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            onChanged: _validate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated Preview Header
                Center(
                  child: Column(
                    children: [
                      Hero(
                        tag: _selectedAvatar != null ? 'avatar_${_selectedAvatar!.id}' : 'new_avatar',
                        child: GestureDetector(
                          onTap: () async {
                            final result = await context.pushNamed(RouteNames.avatarSelection);
                            if (result != null && result is AvatarItem) {
                              setState(() => _selectedAvatar = result);
                            }
                          },
                          child: Stack(
                            children: [
                              HFAvatar(
                                imageUrl: _selectedAvatar?.url,
                                initials: _firstNameController.text.isNotEmpty ? _firstNameController.text[0] : '?',
                                size: 100,
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
                                  child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _displayNameController.text.isEmpty 
                          ? 'Welcome to HabitFlow' 
                          : 'Hi, ${_displayNameController.text} 👋',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Let\'s build your profile',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                const HFSectionHeader(title: 'PERSONAL INFORMATION'),
                const SizedBox(height: 16),
                
                HFTextField(
                  controller: _firstNameController,
                  label: 'FIRST NAME',
                  hintText: 'Enter first name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  textInputAction: TextInputAction.next,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                HFTextField(
                  controller: _lastNameController,
                  label: 'LAST NAME',
                  hintText: 'Enter last name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  textInputAction: TextInputAction.next,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                HFTextField(
                  controller: _displayNameController,
                  label: 'DISPLAY NAME',
                  hintText: 'How should we call you?',
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                  textInputAction: TextInputAction.next,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _selectBirthday,
                  child: AbsorbPointer(
                    child: HFTextField(
                      controller: _birthdayController,
                      label: 'DATE OF BIRTH',
                      hintText: 'Select your birthday',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                      validator: (v) {
                        if (_selectedBirthday == null) return 'Required';
                        final age = DateTime.now().year - _selectedBirthday!.year;
                        if (age < 3) return 'You must be at least 3 years old';
                        return null;
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                FamilyRoleSelector(
                  selectedRole: _selectedRole,
                  onRoleChanged: (role) => setState(() => _selectedRole = role),
                ),
                
                const SizedBox(height: 32),
                const HFSectionHeader(title: 'PREFERENCES'),
                const SizedBox(height: 16),
                
                // Mock Selectors for Country & TimeZone to maintain clean UI without heavy libs
                _buildSelector(
                  label: 'COUNTRY',
                  value: _selectedCountry,
                  icon: Icons.public_rounded,
                  onTap: () {
                     // In a real app, show search list. Here we mock it.
                     _showMockPicker('Select Country', ['United States', 'United Kingdom', 'Canada', 'Australia'], (val) {
                       setState(() => _selectedCountry = val);
                     });
                  },
                ),
                const SizedBox(height: 16),
                _buildSelector(
                  label: 'TIME ZONE',
                  value: _selectedTimezone,
                  icon: Icons.schedule_rounded,
                  onTap: () {
                     _showMockPicker('Select Time Zone', ['GMT+00:00 (London)', 'GMT-05:00 (EST)', 'GMT-08:00 (PST)'], (val) {
                       setState(() => _selectedTimezone = val);
                     });
                  },
                ),
                
                const SizedBox(height: 48),
                HFButton(
                  label: 'Complete Profile',
                  onPressed: _isFormValid ? _saveProfile : null,
                  isLoading: profileState.isLoading,
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelector({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
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
                 Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.onSurfaceVariant),
               ],
             ),
           ),
         ],
       ),
     );
  }

  void _showMockPicker(String title, List<String> options, ValueChanged<String> onSelected) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
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
