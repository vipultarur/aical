import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_durations.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.splash,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _navigateToNext();
  }

  void _navigateToNext() {
    _splashTimer = Timer(AppDurations.splash, () {
      if (!mounted) {
        return;
      }

      final profile = ref.read(userProfileProvider);
      if (profile.hasCompletedOnboarding) {
        context.go(AppRoutes.dashboard);
        return;
      }

      context.go(AppRoutes.onboardingWelcome);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [AppColors.greenLeaf, AppColors.greenDark],
            center: Alignment.center,
            radius: 1.2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      padding: AppDimensions.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.neutral0.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.greenFresh.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        LucideIcons.leaf,
                        color: AppColors.neutral0,
                        size: AppDimensions.icon(64),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: AppDimensions.space(24)),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'CaloriePal',
                      style: AppTypography.displayMd(color: AppColors.neutral0),
                    ),
                    SizedBox(height: AppDimensions.space(8)),
                    Text(
                      'Fuel your life, organically.',
                      style: AppTypography.bodyLg(
                        color: AppColors.neutral0.withValues(alpha: 0.7),
                      ),
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
}
