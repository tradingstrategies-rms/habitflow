import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class AvatarSelectionScreen extends StatefulWidget {
  const AvatarSelectionScreen({super.key});

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  String? _selectedAvatarUrl;

  final List<String> _categories = ['Kids', 'Adults', 'Animals', 'Abstract'];
  String _selectedCategory = 'Kids';

  final List<String> _avatars = List.generate(12, (index) => 'https://i.pravatar.cc/150?u=$index');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: HFTopAppBar(
        title: 'Choose Avatar',
        centerTitle: true,
        leading: HFIconButton(
          icon: Icons.arrow_back_rounded,
          onPressed: () => context.pop(),
        ),
        actions: [
          HFIconButton(
            icon: Icons.close_rounded,
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: HFChip(
                    label: category,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedCategory = category),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Avatar Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: _avatars.length,
              itemBuilder: (context, index) {
                final url = _avatars[index];
                final isSelected = _selectedAvatarUrl == url;

                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatarUrl = url),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected 
                        ? [BoxShadow(color: theme.colorScheme.primary.withAlpha(HFOpacity.alpha20), blurRadius: 15)] 
                        : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child: Stack(
                        children: [
                          Image.network(url, fit: BoxFit.cover),
                          if (isSelected)
                            Container(
                              color: theme.colorScheme.primary.withAlpha(HFOpacity.alpha10),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check, size: 20, color: Colors.white),
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(HFOpacity.alpha05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: HFButton(
            label: 'Save Avatar',
            onPressed: _selectedAvatarUrl != null 
                ? () => context.pop(_selectedAvatarUrl) 
                : () {},
          ),
        ),
      ),
    );
  }
}
