import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/settings_notifier.dart';
import '../domain/country_constants.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';

class CountrySelectionScreen extends ConsumerStatefulWidget {
  const CountrySelectionScreen({super.key});

  @override
  ConsumerState<CountrySelectionScreen> createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends ConsumerState<CountrySelectionScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final filteredCountries = CountryConstants.countries
        .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Country'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(HFSpacing.m),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search country...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCountries.length,
              itemBuilder: (context, index) {
                final country = filteredCountries[index];
                final isSelected = country == settings.selectedCountry;

                return ListTile(
                  leading: Text(country.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(country.name),
                  subtitle: Text(country.timezone),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () async {
                    await ref.read(settingsProvider.notifier).setCountry(country);
                    if (context.mounted) Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
