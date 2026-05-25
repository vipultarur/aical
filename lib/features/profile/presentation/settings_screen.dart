import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: AppTypography.headingLg(color: colors.onSurface),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Appearance theme switcher card
              Text(
                'Appearance & Theme',
                style: AppTypography.headingSm(color: colors.onSurface),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        isDark ? LucideIcons.moon : LucideIcons.sun,
                        color: colors.primary,
                      ),
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Organic dark mode slate'),
                      trailing: Switch(
                        value: isDark,
                        onChanged: (val) {
                          ref.read(themeProvider.notifier).toggleTheme();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Typography details card
              Text(
                'Brand Typography',
                style: AppTypography.headingSm(color: colors.onSurface),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFontRow(
                        'Display/Titles',
                        'Bricolage Grotesque',
                        'Premium Display',
                        context,
                      ),
                      const Divider(height: 24),
                      _buildFontRow(
                        'Body Content',
                        'DM Sans',
                        'Clean & highly readable',
                        context,
                      ),
                      const Divider(height: 24),
                      _buildFontRow(
                        'Numerals/Tables',
                        'JetBrains Mono',
                        'Tabular tabular lining',
                        context,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Customize meal categories slot editor representation
              Text(
                'Meal Slot Customization',
                style: AppTypography.headingSm(color: colors.onSurface),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    _buildMealCustomizerRow(
                      'Breakfast',
                      '08:00 AM',
                      AppColors.macroProtein,
                    ),
                    const Divider(height: 1),
                    _buildMealCustomizerRow(
                      'Lunch',
                      '01:00 PM',
                      AppColors.greenLeaf,
                    ),
                    const Divider(height: 1),
                    _buildMealCustomizerRow(
                      'Dinner',
                      '07:00 PM',
                      AppColors.amberWarm,
                    ),
                    const Divider(height: 1),
                    _buildMealCustomizerRow(
                      'Snacks',
                      'Flexible',
                      AppColors.blueInfo,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // About version notes
              Center(
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.leaf,
                      color: colors.primary.withValues(alpha: 0.5),
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'CaloriePal for Flutter\nVersion 1.0.0 (Build 2026.05.17)',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFontRow(
    String label,
    String fontName,
    String description,
    BuildContext context,
  ) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              fontName,
              style: AppTypography.headingSm(color: colors.primary),
            ),
          ],
        ),
        Text(
          description,
          style: AppTypography.bodySm(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildMealCustomizerRow(String defaultName, String time, Color color) {
    return ListTile(
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      title: Text(
        defaultName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('Reminds at $time'),
      trailing: Icon(LucideIcons.pencil, size: 16),
      onTap: () {},
    );
  }
}
