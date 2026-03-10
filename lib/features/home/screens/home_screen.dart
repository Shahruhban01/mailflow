// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/dashboard_stats_model.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user      = authState is AuthSuccess ? authState.user : null;
    final statsAsync = ref.watch(dashboardStatsProvider);
    final hour       = DateTime.now().hour;
    final greeting   = hour < 12 ? 'Good morning'
                     : hour < 17 ? 'Good afternoon'
                     : 'Good evening';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.invalidate(dashboardStatsProvider),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [

            // ── Hero Header ──
            SliverToBoxAdapter(
              child: _HeroHeader(
                greeting: greeting,
                name: user?.name.split(' ').first ?? 'User',
              ).animate().fadeIn().slideY(begin: -0.08),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: statsAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: _SkeletonDashboard(),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: _ErrorState(
                    msg: e.toString(),
                    onRetry: () => ref.invalidate(dashboardStatsProvider),
                  ),
                ),
                data: (stats) => SliverList(
                  delegate: SliverChildListDelegate([

                    // ── Today card ──
                    _TodayBanner(stats: stats)
                        .animate()
                        .fadeIn(delay: 80.ms)
                        .slideY(begin: 0.06),

                    const SizedBox(height: AppSpacing.lg),

                    // ── 4-stat grid ──
                    _StatGrid(stats: stats)
                        .animate()
                        .fadeIn(delay: 140.ms)
                        .slideY(begin: 0.06),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Bar chart ──
                    _SectionHeader(
                      title: 'Last 7 Days',
                      subtitle: 'Sent emails per day',
                      action: null,
                    ).animate().fadeIn(delay: 180.ms),
                    const SizedBox(height: AppSpacing.sm),
                    _BarChart(points: stats.chart)
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.06),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Activity ring row ──
                    _RingRow(stats: stats)
                        .animate()
                        .fadeIn(delay: 240.ms)
                        .slideY(begin: 0.06),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Quick actions ──
                    _SectionHeader(
                      title: 'Quick Actions',
                      subtitle: null,
                      action: null,
                    ).animate().fadeIn(delay: 260.ms),
                    const SizedBox(height: AppSpacing.sm),
                    _QuickActions(ref: ref)
                        .animate()
                        .fadeIn(delay: 280.ms)
                        .slideY(begin: 0.06),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Recent emails ──
                    _SectionHeader(
                      title: 'Recent Emails',
                      subtitle: '${stats.sent} total sent',
                      action: _TextAction(
                        label: 'View all',
                        onTap: () =>
                            ref.read(dashboardTabProvider.notifier).state = 3,
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: AppSpacing.sm),

                    if (stats.recent.isEmpty)
                      _EmptyRecent()
                          .animate()
                          .fadeIn(delay: 320.ms)
                    else
                      ...stats.recent.asMap().entries.map((e) =>
                        _RecentEmailTile(email: e.value, index: e.key)
                            .animate()
                            .fadeIn(delay: Duration(milliseconds: 320 + 60 * e.key))
                            .slideX(begin: 0.04)
                      ),

                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// HERO HEADER
// ─────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final String greeting, name;
  const _HeroHeader({required this.greeting, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.xl2 + 8, AppSpacing.lg, AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
            const Color(0xFF312E81),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft:  Radius.circular(AppSpacing.radiusXl + 8),
          bottomRight: Radius.circular(AppSpacing.radiusXl + 8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.mail_rounded,
                  color: Colors.white, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('MailFlow',
                style: AppTypography.headingMd.copyWith(color: Colors.white),
              ),
              const Spacer(),
              // Notification bell
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_outlined,
                  color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl2),

          Text('$greeting,', style: AppTypography.bodyLg.copyWith(
            color: Colors.white.withOpacity(0.8),
          )),
          Text(name, style: AppTypography.displayLg.copyWith(
            color: Colors.white, height: 1.1,
          )),
          const SizedBox(height: AppSpacing.sm),
          Text("Here's your email overview",
            style: AppTypography.bodyMd.copyWith(
              color: Colors.white.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// TODAY BANNER
// ─────────────────────────────────────────
class _TodayBanner extends StatelessWidget {
  final DashboardStats stats;
  const _TodayBanner({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's Activity",
                  style: AppTypography.labelLg.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${stats.today}',
                      style: AppTypography.displayLg.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 6),
                      child: Text('emails sent',
                        style: AppTypography.bodyMd.copyWith(
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('${stats.thisWeek} this week · ${stats.thisMonth} this month',
                  style: AppTypography.bodySm.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.trending_up_rounded,
              color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 4-STAT GRID
// ─────────────────────────────────────────
class _StatGrid extends StatelessWidget {
  final DashboardStats stats;
  const _StatGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem('Total',     '${stats.total}',    Icons.all_inbox_rounded,    AppColors.primary),
      _StatItem('Sent',      '${stats.sent}',     Icons.send_rounded,         AppColors.success),
      _StatItem('Drafts',    '${stats.draft}',    Icons.drafts_outlined,      AppColors.warning),
      _StatItem('Failed',    '${stats.failed}',   Icons.error_outline_rounded, AppColors.danger),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.55,
      children: items.map((i) => _StatCard(item: i)).toList(),
    );
  }
}

class _StatItem {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.dark2 : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.value,
                style: AppTypography.headingLg.copyWith(
                  fontSize: 24, fontWeight: FontWeight.w800,
                ),
              ),
              Text(item.label,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// BAR CHART (Pure Flutter — no library)
// ─────────────────────────────────────────
class _BarChart extends StatelessWidget {
  final List<ChartPoint> points;
  const _BarChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final max = points.map((p) => p.count).fold(0, (a, b) => a > b ? a : b);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 121,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points.map((p) {
                final ratio = max > 0 ? p.count / max : 0.0;
                final isToday = p.date == _today();
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (p.count > 0)
                          Text('${p.count}',
                            style: AppTypography.caption.copyWith(
                              color: isToday
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          height: ratio * 80 + (p.count > 0 ? 4 : 2),
                          decoration: BoxDecoration(
                            gradient: isToday
                                ? AppColors.gradientPrimary
                                : LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.primary.withOpacity(0.5),
                                      AppColors.primary.withOpacity(0.25),
                                    ],
                                  ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(p.label,
                          style: AppTypography.caption.copyWith(
                            color: isToday
                                ? AppColors.primary
                                : AppColors.textLight,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w400,
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
        ],
      ),
    );
  }

  String _today() => DateTime.now().toIso8601String().substring(0, 10);
}

// ─────────────────────────────────────────
// RING ROW — success rate + templates
// ─────────────────────────────────────────
class _RingRow extends StatelessWidget {
  final DashboardStats stats;
  const _RingRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(children: [
            SizedBox(
              width: 52, height: 52,
              child: CustomPaint(
                painter: _RingPainter(
                  value: stats.successRate / 100,
                  color: AppColors.success,
                ),
                child: Center(
                  child: Text(
                    '${stats.successRate.toInt()}%',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.success, fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Success Rate',
                    style: AppTypography.headingSm,
                  ),
                  Text('${stats.sent} of ${stats.total}',
                    style: AppTypography.bodySm,
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.grid_view_rounded,
                color: AppColors.accent, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${stats.templates}',
                    style: AppTypography.headingLg.copyWith(fontSize: 22),
                  ),
                  Text('Templates',
                    style: AppTypography.bodySm,
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    ]);
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  const _RingPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r  = (size.width - 8) / 2;
    final bg = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..shader = LinearGradient(colors: [color, color.withOpacity(0.6)])
          .createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), r, bg);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -1.5707963,
      value * 6.2831853,
      false, fg,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value;
}

// ─────────────────────────────────────────
// QUICK ACTIONS
// ─────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final WidgetRef ref;
  const _QuickActions({required this.ref});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QAction('Compose',   Icons.edit_rounded,       AppColors.primary,   0),
      _QAction('Templates', Icons.grid_view_rounded,  AppColors.accent,    2),
      _QAction('History',   Icons.inbox_rounded,      AppColors.success,   3),
      _QAction('Profile',   Icons.person_rounded,     AppColors.warning,   4),
    ];
    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: () =>
                ref.read(dashboardTabProvider.notifier).state = a.tab,
            child: Container(
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: a.color.withOpacity(0.08),
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: a.color.withOpacity(0.18),
                ),
              ),
              child: Column(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: a.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(a.icon, color: a.color, size: 17),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(a.label,
                  style: AppTypography.caption.copyWith(
                    color: a.color, fontWeight: FontWeight.w700, fontSize: 10,
                  ),
                ),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QAction {
  final String label;
  final IconData icon;
  final Color color;
  final int tab;
  const _QAction(this.label, this.icon, this.color, this.tab);
}

// ─────────────────────────────────────────
// RECENT EMAILS
// ─────────────────────────────────────────
class _RecentEmailTile extends StatelessWidget {
  final RecentEmail email;
  final int index;
  const _RecentEmailTile({required this.email, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppColors.avatarColors[index % AppColors.avatarColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.dark2 : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                email.receiverEmail[0].toUpperCase(),
                style: AppTypography.headingSm.copyWith(color: color),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email.subject,
                  style: AppTypography.headingSm.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(email.receiverEmail,
                  style: AppTypography.bodySm,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(status: email.status),
              const SizedBox(height: 4),
              Text(
                _timeAgo(email.createdAt),
                style: AppTypography.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(String dt) {
    try {
      final d    = DateTime.parse(dt);
      final diff = DateTime.now().difference(d);
      if (diff.inMinutes < 1)  return 'just now';
      if (diff.inHours   < 1)  return '${diff.inMinutes}m';
      if (diff.inDays    < 1)  return '${diff.inHours}h';
      return '${diff.inDays}d';
    } catch (_) { return ''; }
  }
}

class _EmptyRecent extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.xl2),
    decoration: BoxDecoration(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(children: [
      const Icon(Icons.inbox_outlined, size: 36, color: AppColors.textLight),
      const SizedBox(height: AppSpacing.sm),
      Text('No emails yet',
        style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
      ),
    ]),
  );
}

// ─────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  const _SectionHeader({
    required this.title, this.subtitle, this.action,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTypography.headingMd),
          if (subtitle != null)
            Text(subtitle!,
              style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
            ),
        ]),
      ),
      if (action != null) action!,
    ],
  );
}

class _TextAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TextAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Text(label,
      style: AppTypography.labelLg.copyWith(color: AppColors.primary),
    ),
  );
}

// ─────────────────────────────────────────
// SKELETON LOADER
// ─────────────────────────────────────────
class _SkeletonDashboard extends StatelessWidget {
  const _SkeletonDashboard();

  @override
  Widget build(BuildContext context) => Column(children: [
    const SizedBox(height: AppSpacing.lg),
    _Bone(height: 100, radius: AppSpacing.radiusLg),
    const SizedBox(height: AppSpacing.lg),
    Row(children: [
      Expanded(child: _Bone(height: 80, radius: AppSpacing.radiusLg)),
      const SizedBox(width: AppSpacing.md),
      Expanded(child: _Bone(height: 80, radius: AppSpacing.radiusLg)),
    ]),
    const SizedBox(height: AppSpacing.md),
    Row(children: [
      Expanded(child: _Bone(height: 80, radius: AppSpacing.radiusLg)),
      const SizedBox(width: AppSpacing.md),
      Expanded(child: _Bone(height: 80, radius: AppSpacing.radiusLg)),
    ]),
    const SizedBox(height: AppSpacing.lg),
    _Bone(height: 160, radius: AppSpacing.radiusLg),
    const SizedBox(height: AppSpacing.lg),
    _Bone(height: 72, radius: AppSpacing.radiusMd),
    const SizedBox(height: AppSpacing.sm),
    _Bone(height: 72, radius: AppSpacing.radiusMd),
    const SizedBox(height: AppSpacing.sm),
    _Bone(height: 72, radius: AppSpacing.radiusMd),
  ]);
}

class _Bone extends StatefulWidget {
  final double height, radius;
  const _Bone({required this.height, required this.radius});
  @override
  State<_Bone> createState() => _BoneState();
}

class _BoneState extends State<_Bone> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.8).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(_anim.value),
        borderRadius: BorderRadius.circular(widget.radius),
      ),
    ),
  );
}

// ─────────────────────────────────────────
// ERROR STATE
// ─────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _ErrorState({required this.msg, required this.onRetry});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 60),
    child: Column(children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.cloud_off_rounded,
          color: AppColors.danger, size: 30),
      ),
      const SizedBox(height: AppSpacing.lg),
      Text('Could not load stats', style: AppTypography.headingSm),
      const SizedBox(height: AppSpacing.xs),
      Text(msg,
        style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: AppSpacing.xl),
      GestureDetector(
        onTap: onRetry,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text('Retry',
            style: AppTypography.labelLg.copyWith(color: Colors.white),
          ),
        ),
      ),
    ]),
  );
}
