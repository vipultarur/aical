import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';

class DietPrefsScreen extends ConsumerStatefulWidget {
  const DietPrefsScreen({super.key});

  @override
  ConsumerState<DietPrefsScreen> createState() => _DietPrefsScreenState();
}

class _DietPrefsScreenState extends ConsumerState<DietPrefsScreen> {
  final List<String> _selectedPrefs = ['High Protein'];

  final List<String> _options = [
    'Vegetarian',
    'Vegan',
    'Keto',
    'Low Carb',
    'High Protein',
    'Dairy-Free',
    'Gluten-Free',
    'Whole Foods',
    'Low Sodium',
    'Mediterranean',
  ];

  void _onFinish() {
    final currentProfile = ref.read(userProfileProvider);
    ref
        .read(userProfileProvider.notifier)
        .updateProfile(currentProfile.copyWith(dietPrefs: _selectedPrefs));
    context.go(AppRoutes.onboardingComplete);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go(AppRoutes.onboardingTarget),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: index == 4 ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: index == 4 ? colors.primary : colors.outline,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Dietary Preferences',
                style: AppTypography.headingXl(color: colors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Select any specific diets or nutrient priorities. This helps tailor search suggestions.',
                style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 32),

              // Multi-select Chips grid
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _options.map((option) {
                      final isSelected = _selectedPrefs.contains(option);
                      return FilterChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedPrefs.add(option);
                            } else {
                              _selectedPrefs.remove(option);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _onFinish,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(56, 56),
                    maximumSize: const Size(56, 56),
                    padding: EdgeInsets.zero,
                    shape: const CircleBorder(),
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    elevation: 2,
                  ),
                  child: Icon(LucideIcons.check, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
