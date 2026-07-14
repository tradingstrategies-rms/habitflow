import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/theme/avatar_theme.dart';
import 'package:habitflow/core/theme/hf_durations.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class AvatarItem {
  final String id;
  final String url; // Using 'url' for compatibility, stores local path for now
  final String category;
  final String? name;

  const AvatarItem({
    required this.id,
    required this.url,
    required this.category,
    this.name,
  });
}

class AvatarSelectionScreen extends StatefulWidget {
  const AvatarSelectionScreen({super.key});

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  String? _selectedAvatarId;
  String _selectedCategory = 'Adults';

  final List<String> _categories = ['Adults', 'Kids', 'Pets'];

  late final List<AvatarItem> _avatars;

  @override
  void initState() {
    super.initState();
    _avatars = _loadAvatars();
  }

  List<AvatarItem> _loadAvatars() {
    return [
      const AvatarItem(id: 'male_01', url: 'assets/avatars/adults/male_01.svg', category: 'Adults', name: 'James'),
      const AvatarItem(id: 'female_01', url: 'assets/avatars/adults/female_01.svg', category: 'Adults', name: 'Sarah'),
      const AvatarItem(id: 'male_02', url: 'assets/avatars/adults/male_02.svg', category: 'Adults', name: 'Marcus'),
      const AvatarItem(id: 'female_02', url: 'assets/avatars/adults/female_02.svg', category: 'Adults', name: 'Elena'),
      const AvatarItem(id: 'male_03', url: 'assets/avatars/adults/male_03.svg', category: 'Adults', name: 'David'),
      const AvatarItem(id: 'female_03', url: 'assets/avatars/adults/female_03.svg', category: 'Adults', name: 'Aisha'),
    ];
  }

  List<AvatarItem> get _filteredAvatars {
    return _avatars.where((a) => a.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarTheme = theme.extension<AvatarTheme>() ?? AvatarTheme.organic();
    final avatars = _filteredAvatars;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: HFTopAppBar(
        title: 'Choose Your Avatar',
        centerTitle: true,
        leading: HFIconButton(
          icon: Icons.arrow_back_rounded,
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: HFSpacing.m),
          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: HFSpacing.l),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                final isEnabled = category != 'Pets';
                
                return Padding(
                  padding: const EdgeInsets.only(right: HFSpacing.s),
                  child: Opacity(
                    opacity: isEnabled ? 1.0 : 0.4,
                    child: HFChip(
                      label: category,
                      isSelected: isSelected,
                      onTap: isEnabled ? () {
                        setState(() {
                          _selectedCategory = category;
                          _selectedAvatarId = null;
                        });
                      } : null,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: HFSpacing.l),

          // Avatar Grid
          Expanded(
            child: avatars.isEmpty
                ? const HFEmptyState(
                    title: 'Coming Soon',
                    message: 'More avatars are being designed!',
                    icon: Icons.auto_awesome_rounded,
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: HFSpacing.l),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: HFSpacing.m,
                      crossAxisSpacing: HFSpacing.m,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: avatars.length,
                    itemBuilder: (context, index) {
                      final avatar = avatars[index];
                      final isSelected = _selectedAvatarId == avatar.id;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedAvatarId = avatar.id),
                        child: AnimatedScale(
                          scale: isSelected ? 1.05 : 1.0,
                          duration: HFDurations.fast,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.transparent : avatarTheme.background,
                              borderRadius: BorderRadius.circular(avatarTheme.radius),
                              boxShadow: isSelected ? avatarTheme.shadows : [],
                              gradient: isSelected ? avatarTheme.primaryGradient : null,
                              border: Border.all(
                                color: isSelected ? Colors.transparent : avatarTheme.strokeColor,
                                width: AvatarSpacing.strokeWidth,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(AvatarSpacing.innerPadding),
                                    child: Hero(
                                      tag: 'avatar_${avatar.id}',
                                      child: SvgPicture.asset(
                                        avatar.url,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_circle,
                                        size: 18,
                                        color: AvatarColors.forest,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HFSpacing.l),
          child: HFButton(
            label: _selectedAvatarId != null ? 'Confirm Selection' : 'Skip',
            onPressed: () {
              AvatarItem? selected;
              if (_selectedAvatarId != null) {
                selected = _avatars.firstWhere((a) => a.id == _selectedAvatarId);
              }

              final bool isOnboarding = GoRouterState.of(context).extra == 'onboarding';

              if (isOnboarding) {
                context.goNamed(RouteNames.dashboard);
              } else {
                context.pop(selected);
              }
            },
          ),
        ),
      ),
    );
  }
}
