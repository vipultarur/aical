import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Sign In'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Animated vector illustration representation
              Center(
                child: Container(
                  height: 240,
                  width: 240,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Floating bubbles representing nutrients
                      Positioned(
                        top: 40,
                        left: 40,
                        child: _buildFloatingIcon(
                          LucideIcons.cookie,
                          AppColors.macroCarbs,
                          48,
                        ),
                      ),
                      Positioned(
                        top: 50,
                        right: 30,
                        child: _buildFloatingIcon(
                          LucideIcons.menu,
                          AppColors.macroProtein,
                          40,
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 60,
                        child: _buildFloatingIcon(
                          LucideIcons.fish,
                          AppColors.macroFat,
                          44,
                        ),
                      ),
                      Positioned(
                        bottom: 60,
                        right: 50,
                        child: _buildFloatingIcon(
                          LucideIcons.droplets,
                          AppColors.blueInfo,
                          36,
                        ),
                      ),
                      // Core plate
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          LucideIcons.coffee,
                          size: 72,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              // Welcome title & description
              Text(
                'Track food,\nfuel your life.',
                style: AppTypography.displayMd(color: colors.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Organic calorie tracking designed to help you live healthier, build steady habits, and appreciate your food.',
                style: AppTypography.bodyLg(color: colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Progress indicator dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == 0 ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == 0 ? colors.primary : colors.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.onboardingBasicInfo),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 4,
        shape: const CircleBorder(),
        child: Icon(LucideIcons.arrowRight, size: 24),
      ),
    );
  }

  Widget _buildFloatingIcon(IconData icon, Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Center(
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}

// Border utility to keep syntax extremely clean
extension BorderColor on Border {
  static Border colorBorder(Color color, double width) {
    return Border.all(color: color, width: width);
  }
}
