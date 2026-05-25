import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';

class EatingStyleScreen extends ConsumerStatefulWidget {
  const EatingStyleScreen({super.key});

  @override
  ConsumerState<EatingStyleScreen> createState() => _EatingStyleScreenState();
}

class _EatingStyleScreenState extends ConsumerState<EatingStyleScreen> {
  String _selectedStyle = 'Balanced';

  @override
  void initState() {
    super.initState();
    // Load from existing profile if available
    final profile = ref.read(userProfileProvider);
    if (profile.dietPrefs.isNotEmpty) {
      _selectedStyle = profile.dietPrefs.first;
    }
  }

  void _onNext() {
    final currentProfile = ref.read(userProfileProvider);
    ref
        .read(userProfileProvider.notifier)
        .updateProfile(currentProfile.copyWith(dietPrefs: [_selectedStyle]));
    context.go(AppRoutes.onboardingRecipePlan);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final styles = [
      {
        'name': 'Balanced',
        'desc':
            'Standard nutrient balance. Ideal for flexible and diverse nutrition.',
        'macros': 'PRO 30%  ·  CARB 50%  ·  FAT 20%',
        'icon': LucideIcons.coffee,
        'color': AppColors.macroFiber,
      },
      {
        'name': 'Low Carb',
        'desc':
            'High proteins and fats, reduced starches. Boosts steady fat metabolism.',
        'macros': 'PRO 25%  ·  CARB 20%  ·  FAT 55%',
        'icon': LucideIcons.egg,
        'color': AppColors.macroCarbs,
      },
      {
        'name': 'Keto',
        'desc':
            'High fats, ultra-low carbohydrates. Shifts body into burning fats for fuel.',
        'macros': 'PRO 20%  ·  CARB 5%  ·  FAT 75%',
        'icon': LucideIcons.menu,
        'color': AppColors.macroProtein,
      },
      {
        'name': 'Vegetarian',
        'desc':
            'Plant-focused diet, dairy and egg inclusive. Free of meat and seafood.',
        'macros': 'PRO 25%  ·  CARB 55%  ·  FAT 20%',
        'icon': LucideIcons.leaf,
        'color': AppColors.greenFresh,
      },
      {
        'name': 'Vegan',
        'desc':
            '100% plant-based organic nutrition. Zero animal ingredients, high fibers.',
        'macros': 'PRO 20%  ·  CARB 60%  ·  FAT 20%',
        'icon': LucideIcons.leaf,
        'color': AppColors.macroFiber,
      },
      {
        'name': 'Mediterranean',
        'desc':
            'Heart-healthy olive oils, lean seafood, grains, and fresh vegetables.',
        'macros': 'PRO 25%  ·  CARB 45%  ·  FAT 30%',
        'icon': LucideIcons.fish,
        'color': AppColors.blueInfo,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go(AppRoutes.onboardingCalorieCut),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(9, (index) {
            final isCurrent = index == 7;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isCurrent ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isCurrent
                    ? colors.primary
                    : colors.outline.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Eating Style",
                    style: AppTypography.headingXl(color: colors.onSurface),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Choose an eating style that represents your preferred daily meals. This pre-calibrates your macros.",
                    style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Scrollable list of styles
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                itemCount: styles.length,
                itemBuilder: (context, index) {
                  final style = styles[index];
                  final name = style['name'] as String;
                  final desc = style['desc'] as String;
                  final macros = style['macros'] as String;
                  final icon = style['icon'] as IconData;
                  final styleColor = style['color'] as Color;
                  final isSelected = _selectedStyle == name;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedStyle = name);
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (mounted) {
                          _onNext();
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primaryContainer.withValues(alpha: 0.12)
                            : colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? colors.primary : colors.outline,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isSelected ? 0.03 : 0.01,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Custom styled icon container
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: styleColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: styleColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(icon, color: styleColor, size: 24),
                          ),
                          const SizedBox(width: 16),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      name,
                                      style: AppTypography.headingMd(
                                        color: isSelected
                                            ? colors.primary
                                            : colors.onSurface,
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        LucideIcons.checkCircle2,
                                        color: colors.primary,
                                        size: 20,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  desc,
                                  style: AppTypography.bodySm(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Macros split label
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colors.primary.withValues(alpha: 0.1)
                                        : colors.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    macros,
                                    style: AppTypography.labelSm(
                                      color: isSelected
                                          ? colors.primary
                                          : colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
