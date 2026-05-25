import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';

class ActivityLevelScreen extends ConsumerStatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  ConsumerState<ActivityLevelScreen> createState() =>
      _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends ConsumerState<ActivityLevelScreen> {
  String _selectedActivity = 'Moderately Active';

  @override
  void initState() {
    super.initState();
    // Load existing activity if available
    final profile = ref.read(userProfileProvider);
    if (profile.activityLevel.isNotEmpty) {
      // Map existing values to new options
      if (profile.activityLevel == 'Sedentary' ||
          profile.activityLevel == 'No Active') {
        _selectedActivity = 'No Active';
      } else if (profile.activityLevel == 'Light' ||
          profile.activityLevel == 'Lightly Active') {
        _selectedActivity = 'Lightly Active';
      } else if (profile.activityLevel == 'Moderate' ||
          profile.activityLevel == 'Moderately Active') {
        _selectedActivity = 'Moderately Active';
      } else if (profile.activityLevel == 'Very' ||
          profile.activityLevel == 'Highly Active') {
        _selectedActivity = 'Highly Active';
      }
    }
  }

  void _onNext() {
    final currentProfile = ref.read(userProfileProvider);
    ref
        .read(userProfileProvider.notifier)
        .updateProfile(
          currentProfile.copyWith(activityLevel: _selectedActivity),
        );
    context.go(AppRoutes.onboardingCalorieCut);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final activities = [
      {
        'title': 'No Active',
        'subtitle': 'Desk job or sitting routine',
        'desc':
            'Spend most of the day sitting, watching screens, or doing minimal physical tasks.',
        'icon': LucideIcons.armchair,
      },
      {
        'title': 'Lightly Active',
        'subtitle': 'Regular walking or light tasks',
        'desc':
            'On your feet some of the day, light gardening, casual stretching, or light chores.',
        'icon': LucideIcons.footprints,
      },
      {
        'title': 'Moderately Active',
        'subtitle': 'Exercise or active walking 3-5 days',
        'desc':
            'Gym sessions, running, cycling, or working a job that keeps you continuously moving.',
        'icon': LucideIcons.trendingUp,
      },
      {
        'title': 'Highly Active',
        'subtitle': 'Heavy physical training 6-7 days',
        'desc':
            'High-intensity athletic conditioning, competitive sports, or heavy manual labor.',
        'icon': LucideIcons.dumbbell,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go(AppRoutes.onboardingPrediction),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(9, (index) {
            final isCurrent = index == 5;
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "What's your activity level?",
                style: AppTypography.headingXl(color: colors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                "This helps us estimate your daily calorie burn to calibrate your baseline budget accurately.",
                style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),

              // Activity Cards Grid/List
              ...activities.map((act) {
                final title = act['title'] as String;
                final subtitle = act['subtitle'] as String;
                final desc = act['desc'] as String;
                final icon = act['icon'] as IconData;
                final isSelected = _selectedActivity == title;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedActivity = title);
                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (mounted) {
                        _onNext();
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primary.withValues(alpha: 0.15)
                                : colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? colors.primary
                                : colors.onSurfaceVariant,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Text Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTypography.headingMd(
                                  color: isSelected
                                      ? colors.primary
                                      : colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: AppTypography.labelMd(
                                  color: colors.onSurfaceVariant,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                desc,
                                style: AppTypography.bodySm(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Icon(
                            LucideIcons.checkCircle2,
                            color: colors.primary,
                            size: 22,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
