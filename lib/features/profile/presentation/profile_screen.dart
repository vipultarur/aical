import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTypography.headingXl(color: colors.onSurface),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. User details avatar header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: colors.primaryContainer,
                      child: Text(
                        profile.name.substring(0, 2).toUpperCase(),
                        style: AppTypography.displayLg(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.name,
                      style: AppTypography.headingXl(color: colors.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Member since May 2026',
                      style: AppTypography.bodyMd(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 2. Metrics summary matrix
              Text(
                'Personal Statistics',
                style: AppTypography.headingSm(color: colors.onSurface),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMetricStatCard(
                    'Age',
                    '28 yrs',
                    LucideIcons.calendar,
                    AppColors.greenLeaf,
                    context,
                  ),
                  const SizedBox(width: 8),
                  _buildMetricStatCard(
                    'Height',
                    '${profile.height.round()} cm',
                    LucideIcons.arrowUpDown,
                    AppColors.blueInfo,
                    context,
                  ),
                  const SizedBox(width: 8),
                  _buildMetricStatCard(
                    'Weight',
                    '${profile.weight.round()} lbs',
                    LucideIcons.scale,
                    AppColors.amberWarm,
                    context,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Goal summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Goal',
                    style: AppTypography.headingSm(color: colors.onSurface),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      context.go(AppRoutes.onboardingGoals);
                    },
                    icon: Icon(LucideIcons.edit3, size: 16, color: colors.onSurfaceVariant),
                    label: Text(
                      'Edit',
                      style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              Card(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildProfileRow('Main goal', profile.mainGoal, colors),
                      Divider(color: colors.outline.withValues(alpha: 0.2)),
                      _buildProfileRow('Target date', _formatDate(profile.targetDate), colors),
                      Divider(color: colors.outline.withValues(alpha: 0.2)),
                      _buildProfileRow('Active level', profile.activityLevel, colors),
                      Divider(color: colors.outline.withValues(alpha: 0.2)),
                      _buildProfileRow('Initial Weight', '${profile.weight}${profile.weightUnit}', colors),
                      Divider(color: colors.outline.withValues(alpha: 0.2)),
                      _buildProfileRow('Goal weight', '${profile.targetWeight}${profile.weightUnit}', colors),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 4. Panel details lists
              Text(
                'Preference',
                style: AppTypography.headingSm(color: colors.onSurface),
              ),
              const SizedBox(height: 12),
              Card(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Notifications'),
                      trailing: Icon(LucideIcons.chevronRight, size: 20, color: colors.onSurfaceVariant),
                      onTap: () {},
                    ),
                    Divider(height: 1, color: colors.outline.withValues(alpha: 0.2)),
                    ListTile(
                      title: const Text('Add workout calories to budget'),
                      trailing: Switch(value: true, onChanged: (val) {}),
                    ),
                    Divider(height: 1, color: colors.outline.withValues(alpha: 0.2)),
                    ListTile(
                      title: const Text('Auto budget'),
                      trailing: Switch(value: true, onChanged: (val) {}),
                    ),
                    Divider(height: 1, color: colors.outline.withValues(alpha: 0.2)),
                    ListTile(
                      title: const Text('Unit'),
                      trailing: Icon(LucideIcons.chevronRight, size: 20, color: colors.onSurfaceVariant),
                      onTap: () {},
                    ),
                    Divider(height: 1, color: colors.outline.withValues(alpha: 0.2)),
                    ListTile(
                      title: const Text('Language'),
                      trailing: Icon(LucideIcons.chevronRight, size: 20, color: colors.onSurfaceVariant),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Support',
                style: AppTypography.headingSm(color: colors.onSurface),
              ),
              const SizedBox(height: 12),

              // 5. Logout action buttons
              OutlinedButton.icon(
                onPressed: () {
                  // Simply reset to welcome
                  context.go(AppRoutes.onboardingWelcome);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.coralAlert,
                  side: const BorderSide(color: AppColors.coralAlert, width: 1),
                ),
                icon: Icon(LucideIcons.logOut, size: 18),
                label: const Text('Sign Out of Account'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    final colors = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTypography.labelSm(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.numeralSm(color: colors.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMd(color: colors.onSurface),
          ),
          Text(
            value,
            style: AppTypography.bodyMd(color: colors.primary),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
