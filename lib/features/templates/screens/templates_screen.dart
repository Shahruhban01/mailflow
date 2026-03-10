import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../models/template_model.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/loading_skeleton.dart';
import '../../compose/providers/compose_provider.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../providers/templates_provider.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  static const _icons = [
    Icons.school_outlined,      Icons.work_outline_rounded,
    Icons.business_outlined,    Icons.notifications_outlined,
    Icons.email_outlined,       Icons.article_outlined,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(templatesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Templates', style: AppTypography.displayMd),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${state.templates.length} template${state.templates.length == 1 ? '' : 's'}',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, 100,
              ),
              sliver: state.isLoading
                  ? const SliverToBoxAdapter(
                      child: LoadingSkeleton(count: 4),
                    )
                  : state.error != null
                      ? SliverToBoxAdapter(
                          child: _ErrorView(
                            msg: state.error!,
                            onRetry: () =>
                                ref.read(templatesProvider.notifier).load(),
                          ),
                        )
                      : state.templates.isEmpty
                          ? const SliverToBoxAdapter(child: _EmptyView())
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) {
                                  final t = state.templates[i];
                                  final icon = _icons[i % _icons.length];
                                  final color = AppColors.avatarColors[
                                      i % AppColors.avatarColors.length];
                                  return _TemplateCard(
                                    template: t,
                                    icon: icon,
                                    color: color,
                                    onUse: () {
                                      ref
                                          .read(prefillProvider.notifier)
                                          .state = PrefillState(
                                        subject: t.subject,
                                        body: t.body,
                                      );
                                      ref
                                          .read(dashboardTabProvider.notifier)
                                          .state = 1;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(_successSnack(
                                        'Template "${t.name}" loaded',
                                      ));
                                    },
                                    onEdit: () =>
                                        _showTemplateForm(context, ref, t),
                                    onDelete: () =>
                                        _confirmDelete(context, ref, t),
                                  ).animate()
                                   .fadeIn(
                                      delay: Duration(milliseconds: 60 * i))
                                   .slideY(begin: 0.05);
                                },
                                childCount: state.templates.length,
                              ),
                            ),
            ),
          ],
        ),
      ),

      // ── FAB ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTemplateForm(context, ref, null),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('New Template',
          style: AppTypography.labelLg.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  SnackBar _successSnack(String msg) => SnackBar(
    content: Row(children: [
      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
      const SizedBox(width: 8),
      Text(msg),
    ]),
    backgroundColor: AppColors.success,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    ),
  );

  void _showTemplateForm(
    BuildContext context,
    WidgetRef ref,
    TemplateModel? existing,
  ) {
    final isEdit    = existing != null;
    final nameCtrl  = TextEditingController(text: existing?.name ?? '');
    final subjCtrl  = TextEditingController(text: existing?.subject ?? '');
    final bodyCtrl  = TextEditingController(text: existing?.body ?? '');
    final formKey   = GlobalKey<FormState>();
    bool loading    = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl2,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    isEdit ? 'Edit Template' : 'New Template',
                    style: AppTypography.headingMd,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  AppTextField(
                    label: 'Template Name',
                    hint: 'e.g. Offer Letter',
                    controller: nameCtrl,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.required(v, 'Name'),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    label: 'Subject',
                    hint: 'Email subject line',
                    controller: subjCtrl,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.required(v, 'Subject'),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    label: 'Body',
                    hint: 'Write template body…',
                    controller: bodyCtrl,
                    maxLines: 6,
                    validator: (v) => Validators.required(v, 'Body'),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  AppButton(
                    label: isEdit ? 'Save Changes' : 'Create Template',
                    fullWidth: true,
                    isLoading: loading,
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => loading = true);
                      try {
                        if (isEdit) {
                          await ref.read(templatesProvider.notifier).update(
                            id:      existing.id,
                            name:    nameCtrl.text.trim(),
                            subject: subjCtrl.text.trim(),
                            body:    bodyCtrl.text.trim(),
                          );
                        } else {
                          await ref.read(templatesProvider.notifier).create(
                            name:    nameCtrl.text.trim(),
                            subject: subjCtrl.text.trim(),
                            body:    bodyCtrl.text.trim(),
                          );
                        }
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            _successSnack(isEdit
                              ? 'Template updated!'
                              : 'Template created!'),
                          );
                        }
                      } catch (e) {
                        setState(() => loading = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: AppColors.danger,
                          ));
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TemplateModel t,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                color: AppColors.danger, size: 28),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Delete "${t.name}"?', style: AppTypography.headingMd),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This template will be permanently deleted.',
              style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Delete',
              variant: AppButtonVariant.danger,
              fullWidth: true,
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await ref.read(templatesProvider.notifier).delete(t.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Template deleted'),
                      backgroundColor: AppColors.danger,
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppColors.danger,
                    ));
                  }
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Cancel',
              variant: AppButtonVariant.secondary,
              fullWidth: true,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final TemplateModel template;
  final IconData icon;
  final Color color;
  final VoidCallback onUse;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TemplateCard({
    required this.template,
    required this.icon,
    required this.color,
    required this.onUse,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.name, style: AppTypography.headingSm),
                const SizedBox(height: 3),
                Text(template.subject,
                  style: AppTypography.bodySm,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Use
              _ActionChip(
                label: 'Use',
                color: AppColors.primary,
                bg: AppColors.primaryLight,
                onTap: onUse,
              ),
              const SizedBox(width: AppSpacing.xs),
              // Edit
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.edit_outlined,
                    size: 15, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Delete
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                      color: AppColors.danger.withOpacity(0.2),
                    ),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                    size: 15, color: AppColors.danger),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final Color color, bg;
  final VoidCallback onTap;
  const _ActionChip({
    required this.label, required this.color,
    required this.bg,    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.sm - 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(label,
        style: AppTypography.labelSm.copyWith(color: color, fontSize: 12),
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
      Icon(Icons.grid_view_outlined, size: 56, color: AppColors.textLight),
      SizedBox(height: AppSpacing.lg),
      Text('No templates yet', style: AppTypography.headingSm),
      SizedBox(height: AppSpacing.xs),
      Text('Tap + to create your first template',
        style: AppTypography.bodyMd, textAlign: TextAlign.center),
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
