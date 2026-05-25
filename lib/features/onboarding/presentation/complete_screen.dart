import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_durations.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';

class CompleteScreen extends ConsumerStatefulWidget {
  const CompleteScreen({super.key});

  @override
  ConsumerState<CompleteScreen> createState() => _CompleteScreenState();
}

class _CompleteScreenState extends ConsumerState<CompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
    _completeAndNavigate();
  }

  Future<void> _completeAndNavigate() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(userProfileProvider.notifier).completeOnboarding();
      }
    });

    await Future.delayed(AppDurations.onboardingComplete);
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.dashboard);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.primary.withValues(alpha: 0.05), colors.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.trophy,
                      color: colors.primary,
                      size: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "You're all set!",
                  style: AppTypography.displayLg(color: colors.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "Your personalized calorie ring, nutrition splits, and daily trackers are ready for your first meal log.",
                  style: AppTypography.bodyLg(color: colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  strokeWidth: 3,
                  strokeCap: StrokeCap.round,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
