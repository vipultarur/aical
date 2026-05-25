import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_assets.dart';
import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';

class NavigationShell extends StatelessWidget {
  const NavigationShell({required this.child, super.key});

  final Widget child;

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.dashboard)) return 0;
    if (location.startsWith(AppRoutes.foodLog)) return 1;
    if (location.startsWith(AppRoutes.insights)) return 2;
    if (location.startsWith(AppRoutes.planner)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.go(AppRoutes.foodLog);
        break;
      case 2:
        context.go(AppRoutes.insights);
        break;
      case 3:
        context.go(AppRoutes.planner);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final selectedIndex = _calculateSelectedIndex(context);
    final colors = context.colors;
    final isDark = context.isDark;

    final destinations = [
      const _ShellDestination(
        label: 'Dashboard',
        icon: LucideIcons.home,
        activeIcon: LucideIcons.home,
      ),
      const _ShellDestination(
        label: 'Log Food',
        icon: LucideIcons.plusCircle,
        activeIcon: LucideIcons.plusCircle,
      ),
      const _ShellDestination(
        label: 'Insights',
        icon: LucideIcons.lineChart,
        activeIcon: LucideIcons.lineChart,
      ),
      const _ShellDestination(
        label: 'Planner',
        icon: LucideIcons.calendar,
        activeIcon: LucideIcons.calendar,
      ),
      const _ShellDestination(
        label: 'Profile',
        icon: LucideIcons.userCircle,
        activeIcon: LucideIcons.userCircle,
      ),
    ];

    if (width >= 1200) {
      return Scaffold(
        body: Row(
          children: [
            Container(
              width: AppDimensions.desktopNavWidth,
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(right: BorderSide(color: colors.outline)),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: AppDimensions.all(24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.leaf,
                                color: colors.primary,
                                size: AppDimensions.iconXl,
                              ),
                              SizedBox(width: AppDimensions.sm),
                              Text(
                                'CaloriePal',
                                style: AppTypography.headingXl(
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: destinations.length,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        itemBuilder: (context, index) {
                          final destination = destinations[index];
                          final isSelected = selectedIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              selected: isSelected,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              selectedTileColor: colors.primaryContainer
                                  .withValues(alpha: 0.3),
                              leading: Icon(
                                isSelected
                                    ? destination.activeIcon
                                    : destination.icon,
                                color: isSelected
                                    ? colors.primary
                                    : colors.onSurfaceVariant,
                              ),
                              title: Text(
                                destination.label,
                                style: AppTypography.labelLg(
                                  color: isSelected
                                      ? colors.primary
                                      : colors.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                              onTap: () => _onItemTapped(index, context),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'CaloriePal v1.0.0\nMay 2026',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    if (width >= 600) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) => _onItemTapped(index, context),
                backgroundColor: colors.surface,
                labelType: NavigationRailLabelType.all,
                selectedLabelTextStyle: AppTypography.labelSm(
                  color: colors.primary,
                ),
                unselectedLabelTextStyle: AppTypography.labelSm(
                  color: colors.onSurfaceVariant,
                ),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Icon(
                    LucideIcons.leaf,
                    color: colors.primary,
                    size: 28,
                  ),
                ),
                destinations: destinations.map((destination) {
                  return NavigationRailDestination(
                    icon: Icon(
                      destination.icon,
                      color: colors.onSurfaceVariant,
                    ),
                    selectedIcon: Icon(
                      destination.activeIcon,
                      color: colors.primary,
                    ),
                    label: Text(destination.label),
                  );
                }).toList(),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDark ? colors.surface : Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isDark
                          ? colors.outline
                          : Colors.grey.shade100,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GNav(
                      rippleColor: isDark ? colors.surfaceContainerHighest : Colors.grey[300]!,
                      hoverColor: isDark ? colors.surfaceContainerHighest : Colors.grey[100]!,
                      gap: 8,
                      activeColor: AppColors.greenLeaf,
                      iconSize: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutExpo,
                      tabBackgroundColor: AppColors.greenPale,
                      color: isDark ? colors.onSurfaceVariant : Colors.grey.shade400,
                      textStyle: AppTypography.labelSm(
                        color: AppColors.greenLeaf,
                      ).copyWith(fontWeight: FontWeight.w900,fontSize: 12),
                      tabs: const [
                        GButton(
                          icon: LucideIcons.home,
                          text: 'Home',
                        ),
                        GButton(
                          icon: LucideIcons.activity,
                          text: 'Insights',
                        ),
                        GButton(
                          icon: LucideIcons.chefHat,
                          text: 'Planner',
                        ),
                      ],
                      selectedIndex: selectedIndex == 2 ? 1 : (selectedIndex == 3 ? 2 : 0),
                      onTabChange: (index) {
                        if (index == 0) {
                          context.go(AppRoutes.dashboard);
                        } else if (index == 1) {
                          context.go(AppRoutes.insights);
                        } else if (index == 2) {
                          context.go(AppRoutes.planner);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blueInfo.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () => context.push(AppRoutes.barcodeScanner),
                  elevation: 0,
                  highlightElevation: 0,
                  backgroundColor: Colors.transparent,
                  shape: const CircleBorder(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.asset(
                      AppAssets.cameraButton,
                      fit: BoxFit.cover,
                      width: 64,
                      height: 64,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: AppColors.blueInfo,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.camera,
                            color: Colors.white,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _ShellDestination {
  const _ShellDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
