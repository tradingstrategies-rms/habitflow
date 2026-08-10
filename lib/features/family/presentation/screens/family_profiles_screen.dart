import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import '../providers/family_invitation_provider.dart';
import '../widgets/family_member_card.dart';

class FamilyProfilesScreen extends ConsumerWidget {
  const FamilyProfilesScreen({super.key});

  void _showAddMemberOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: HFSpacing.m),
            ListTile(
              leading: const Icon(Icons.child_care_rounded),
              title: const Text('Add Child Profile'),
              subtitle: const Text('Create a local profile for a child'),
              onTap: () {
                Navigator.pop(context);
                _showAddChildSheet(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add_rounded),
              title: const Text('Invite Adult Member'),
              subtitle: const Text('Invite another user via email'),
              onTap: () {
                Navigator.pop(context);
                _showInviteAdultSheet(context);
              },
            ),
            const SizedBox(height: HFSpacing.m),
          ],
        ),
      ),
    );
  }

  void _showAddChildSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddChildBottomSheet(),
    );
  }

  void _showInviteAdultSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _InviteAdultBottomSheet(),
    );
  }

  void _showEditProfileSheet(BuildContext context, FamilyProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProfileBottomSheet(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyState = ref.watch(familyProvider);
    final profilesAsync = ref.watch(familyProfilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Members'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: profilesAsync.when(
        data: (profiles) {
          final familyName = familyState.circle?.name ?? 'Your Family';
          final createdAt = familyState.circle?.createdAt ?? DateTime.now();
          final formattedDate = DateFormat('MMMM yyyy').format(createdAt);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: HFSpacing.l),
            children: [
              const SizedBox(height: HFSpacing.l),
              Text(
                familyName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: HFSpacing.s),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${profiles.length} Members',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: HFSpacing.s),
                  Text(
                    'Active since $formattedDate',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: HFSpacing.l),
              ...profiles.map((profile) => FamilyMemberCard(
                    profile: profile,
                    onDelete: () => _showDeleteConfirmation(context, ref, profile),
                    onEdit: () => _showEditProfileSheet(context, profile),
                  )),
              const SizedBox(height: HFSpacing.m),
              _InviteMemberCard(onTap: () => _showAddMemberOptions(context)),
              const SizedBox(height: HFSpacing.xl),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, FamilyProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Are you sure you want to delete ${profile.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(familyProvider.notifier).deleteProfile(profile.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InviteMemberCard extends StatelessWidget {
  final VoidCallback onTap;

  const _InviteMemberCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: CustomPaint(
        painter: _DashedRectPainter(
          color: theme.colorScheme.outlineVariant,
          strokeWidth: 1.5,
          gap: 6,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha(102),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add_alt_1_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invite New Member',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Expand your family growth journey',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(24),
      ));

    final dashPath = _buildDashPath(path, gap);
    canvas.drawPath(dashPath, paint);
  }

  Path _buildDashPath(Path source, double dashWidth) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = dashWidth;
        if (draw) {
          dest.addPath(
              metric.extractPath(distance, distance + len), Offset.zero);
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(_DashedRectPainter oldDelegate) => false;
}

class _AddChildBottomSheet extends ConsumerStatefulWidget {
  const _AddChildBottomSheet();

  @override
  ConsumerState<_AddChildBottomSheet> createState() => _AddChildBottomSheetState();
}

class _AddChildBottomSheetState extends ConsumerState<_AddChildBottomSheet> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: HFSpacing.l,
        right: HFSpacing.l,
        top: HFSpacing.l,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: HFSpacing.l),
          Text(
            'Add Child Profile',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: HFSpacing.m),
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Child Name',
              hintText: 'e.g., Leo',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              prefixIcon: const Icon(Icons.child_care_rounded),
            ),
            maxLength: 30,
          ),
          const SizedBox(height: HFSpacing.l),
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              if (name.isNotEmpty) {
                await ref.read(familyProvider.notifier).addChildProfile(name);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Create Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: HFSpacing.xl),
        ],
      ),
    );
  }
}

class _InviteAdultBottomSheet extends ConsumerStatefulWidget {
  const _InviteAdultBottomSheet();

  @override
  ConsumerState<_InviteAdultBottomSheet> createState() => _InviteAdultBottomSheetState();
}

class _InviteAdultBottomSheetState extends ConsumerState<_InviteAdultBottomSheet> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final familyState = ref.watch(familyProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: HFSpacing.l,
        right: HFSpacing.l,
        top: HFSpacing.l,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: HFSpacing.l),
            Text(
              'Invite Adult Member',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: HFSpacing.m),
            Text(
              'Enter the email address of the person you want to invite to join "${familyState.circle?.name}".',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: HFSpacing.l),
            TextFormField(
              controller: _emailController,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'e.g., sarah@example.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter an email';
                if (!value.contains('@')) return 'Please enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: HFSpacing.l),
            ref.watch(invitationNotifierProvider).when(
              data: (_) => ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final email = _emailController.text.trim();
                    final family = familyState.circle;
                    if (family != null) {
                      await ref.read(invitationNotifierProvider.notifier).sendInvitation(
                        email,
                        family.id,
                        family.name,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invitation sent!')),
                        );
                        Navigator.pop(context);
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Send Invitation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Column(
                children: [
                  Text('Error: $e', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref.read(invitationNotifierProvider.notifier).sendInvitation(
                      _emailController.text.trim(),
                      familyState.circle!.id,
                      familyState.circle!.name,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: HFSpacing.xl),
          ],
        ),
      ),
    );
  }
}


class _EditProfileBottomSheet extends ConsumerStatefulWidget {
  final FamilyProfile profile;
  const _EditProfileBottomSheet({required this.profile});

  @override
  ConsumerState<_EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends ConsumerState<_EditProfileBottomSheet> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: HFSpacing.l,
        right: HFSpacing.l,
        top: HFSpacing.l,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: HFSpacing.l),
          Text('Edit Profile', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: HFSpacing.m),
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Display Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            maxLength: 30,
          ),
          const SizedBox(height: HFSpacing.l),
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              if (name.isNotEmpty) {
                final updated = widget.profile.copyWith(displayName: name);
                await ref.read(familyProvider.notifier).updateProfile(updated);
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: HFSpacing.xl),
        ],
      ),
    );
  }
}
