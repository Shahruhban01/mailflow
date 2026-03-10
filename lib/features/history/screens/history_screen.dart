import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/email_card.dart';
import '../../../widgets/loading_skeleton.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _search = TextEditingController();
  String _activeFilter = 'all';

  static const _filters = ['all', 'sent', 'draft', 'failed', 'scheduled'];

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email History', style: AppTypography.displayMd),
                    const SizedBox(height: AppSpacing.xs),
                    Text('${state.emails.length} emails',
                      style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Search
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _search,
                        onChanged: (q) => ref.read(historyProvider.notifier).setSearch(q),
                        style: AppTypography.bodyMd,
                        decoration: InputDecoration(
                          hintText: 'Search emails…',
                          prefixIcon: const Icon(Icons.search_rounded,
                            size: 20, color: AppColors.textLight),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters.map((f) => _FilterChip(
                          label: f[0].toUpperCase() + f.substring(1),
                          active: _activeFilter == f,
                          onTap: () {
                            setState(() => _activeFilter = f);
                            ref.read(historyProvider.notifier).setFilter(f);
                          },
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl4,
              ),
              sliver: state.isLoading
                  ? const SliverToBoxAdapter(child: LoadingSkeleton())
                  : state.error != null
                      ? SliverToBoxAdapter(child: _ErrorView(
                          msg: state.error!,
                          onRetry: () => ref.read(historyProvider.notifier).load(),
                        ))
                      : state.emails.isEmpty
                          ? const SliverToBoxAdapter(child: _EmptyView())
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) => EmailCard(
                                  email: state.emails[i],
                                  onTap: () => context.push('/email/${state.emails[i].id}'),
                                  onDelete: () async {
                                    await ref.read(historyProvider.notifier)
                                        .delete(state.emails[i].id);
                                  },
                                ),
                                childCount: state.emails.length,
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.sm - 2,
      ),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: active ? AppColors.primary : AppColors.border),
      ),
      child: Text(label,
        style: AppTypography.labelSm.copyWith(
          color: active ? Colors.white : AppColors.textMuted,
          fontSize: 12,
        ),
      ),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: 80),
    child: Column(children: [
      Icon(Icons.inbox_outlined, size: 56, color: AppColors.textLight),
      SizedBox(height: AppSpacing.lg),
      Text('No emails yet', style: AppTypography.headingSm),
      SizedBox(height: AppSpacing.xs),
      Text('Sent emails will appear here',
        style: AppTypography.bodyMd,
        textAlign: TextAlign.center,
      ),
    ]),
  );
}

class _ErrorView extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _ErrorView({required this.msg, required this.onRetry});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 60),
    child: Column(children: [
      const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
      const SizedBox(height: AppSpacing.md),
      Text(msg, style: AppTypography.bodyMd, textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.lg),
      TextButton(onPressed: onRetry, child: const Text('Retry')),
    ]),
  );
}
