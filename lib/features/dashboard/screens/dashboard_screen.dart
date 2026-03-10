import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../home/screens/home_screen.dart';
import '../../compose/screens/compose_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../templates/screens/templates_screen.dart';
import '../../profile/screens/profile_screen.dart';

final dashboardTabProvider = StateProvider<int>((ref) => 0);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _screens = [
    HomeScreen(),       // 0 — new
    ComposeScreen(),    // 1
    TemplatesScreen(),  // 2
    HistoryScreen(),    // 3
    ProfileScreen(),    // 4
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(dashboardTabProvider);
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(tab),
          child: _screens[tab],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        current: tab,
        onTap: (i) => ref.read(dashboardTabProvider.notifier).state = i,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.current, required this.onTap});

  static const _items = [
    (Icons.home_rounded,      Icons.home_outlined,         'Home'),
    (Icons.edit_rounded,      Icons.edit_outlined,         'Compose'),
    (Icons.grid_view_rounded, Icons.grid_view_outlined,    'Templates'),
    (Icons.inbox_rounded,     Icons.inbox_outlined,        'History'),
    (Icons.person_rounded,    Icons.person_outline_rounded,'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16, offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: _items.asMap().entries.map((e) {
              final i = e.key;
              final (activeIcon, inactiveIcon, label) = e.value;
              final isActive = current == i;

              // Compose tab gets a special FAB-like pill
              if (i == 1) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44, height: 30,
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? AppColors.gradientPrimary
                                : null,
                            color: isActive ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusFull,
                            ),
                          ),
                          child: Icon(
                            isActive ? activeIcon : inactiveIcon,
                            color: isActive
                                ? Colors.white
                                : AppColors.textLight,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(label,
                          style: AppTypography.caption.copyWith(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textLight,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryLight
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull,
                          ),
                        ),
                        child: Icon(
                          isActive ? activeIcon : inactiveIcon,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textLight,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(label,
                        style: AppTypography.caption.copyWith(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textLight,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
