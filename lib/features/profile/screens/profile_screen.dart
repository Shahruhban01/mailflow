import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/theme_selector.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';


class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user      = authState is AuthSuccess ? authState.user : null;
    final initial   = user?.name[0].toUpperCase() ?? 'U';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Avatar
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20, offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(initial,
                    style: AppTypography.displayMd.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: AppSpacing.lg),

              Text(user?.name ?? 'User', style: AppTypography.headingLg)
                  .animate().fadeIn(delay: 100.ms),
              const SizedBox(height: AppSpacing.xs),
              Text(user?.email ?? '',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textMuted,
                ),
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: AppSpacing.xl2),

              // Menu
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(children: [
                  _MenuItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit Profile',
                    onTap: () => _showEditProfile(context, ref, user?.name ?? ''),
                  ),
                  const Divider(height: 1, indent: 56),
                  _MenuItem(
                    icon: Icons.lock_outline_rounded,
                    label: 'Change Password',
                    onTap: () => _showChangePassword(context, ref),
                  ),
                  const Divider(height: 1, indent: 56),
                  _MenuItem(
                    icon: Icons.palette_outlined,
                    label: 'Theme',
                    onTap: () => _showThemePicker(context, ref),
                    trailing: Consumer(builder: (_, ref, __) {
                      final mode = ref.watch(themeProvider);
                      final label = switch (mode) {
                        AppThemeMode.light  => 'Light',
                        AppThemeMode.dark   => 'Dark',
                        AppThemeMode.system => 'System',
                      };
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull,
                          ),
                        ),
                        child: Text(label,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }),
                  ),
                  const Divider(height: 1, indent: 56),
                  _MenuItem(
                    icon: Icons.info_outline_rounded,
                    label: 'About MailFlow',
                    onTap: () => _showAbout(context),
                  ),
                ]),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),

              const SizedBox(height: AppSpacing.lg),

              // Logout
              GlassCard(
                padding: EdgeInsets.zero,
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                child: _MenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Sign Out',
                  color: AppColors.danger,
                  onTap: () => _confirmLogout(context, ref),
                ),
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: AppSpacing.xl2),
              Text('MailFlow v1.0.0', style: AppTypography.caption)
                  .animate().fadeIn(delay: 300.ms),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  // ── Edit Profile ──
  void _showEditProfile(BuildContext context, WidgetRef ref, String currentName) {
    final nameCtrl = TextEditingController(text: currentName);
    final form = GlobalKey<FormState>();
    bool loading = false;

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
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text('Edit Profile', style: AppTypography.headingMd),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: 'Full Name',
                  hint: 'Your name',
                  controller: nameCtrl,
                  validator: Validators.name,
                  prefixIcon: const Icon(Icons.person_outline_rounded,
                    size: 18, color: AppColors.textLight),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Save Changes',
                  fullWidth: true,
                  isLoading: loading,
                  onPressed: () async {
                    if (!form.currentState!.validate()) return;
                    setState(() => loading = true);
                    try {
                      await ref.read(profileProvider.notifier)
                          .updateProfile(name: nameCtrl.text.trim());
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      setState(() => loading = false);
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Change Password ──
  void _showChangePassword(BuildContext context, WidgetRef ref) {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();
    final form        = GlobalKey<FormState>();
    bool loading      = false;

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
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text('Change Password', style: AppTypography.headingMd),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: 'Current Password',
                  hint: 'Enter current password',
                  controller: currentCtrl,
                  obscure: true,
                  validator: Validators.password,
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                    size: 18, color: AppColors.textLight),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'New Password',
                  hint: 'Min. 8 characters',
                  controller: newCtrl,
                  obscure: true,
                  validator: Validators.password,
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                    size: 18, color: AppColors.textLight),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Confirm New Password',
                  hint: 'Re-enter new password',
                  controller: confirmCtrl,
                  obscure: true,
                  validator: (v) {
                    if (v != newCtrl.text) return 'Passwords do not match.';
                    return null;
                  },
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                    size: 18, color: AppColors.textLight),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Update Password',
                  fullWidth: true,
                  isLoading: loading,
                  onPressed: () async {
                    if (!form.currentState!.validate()) return;
                    setState(() => loading = true);
                    try {
                      await ref.read(profileProvider.notifier).changePassword(
                        current: currentCtrl.text,
                        newPass: newCtrl.text,
                      );
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password changed successfully!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      setState(() => loading = false);
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Theme Picker ──
  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text('Choose Theme', style: AppTypography.headingMd),
              const SizedBox(height: AppSpacing.lg),
              const ThemeSelector(),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Done',
                fullWidth: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── About ──
  void _showAbout(BuildContext context) {
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
              width: 64, height: 64,
              decoration: BoxDecoration(
                gradient: AppColors.gradientAccent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.mail_rounded,
                color: Colors.white, size: 32),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('MailFlow', style: AppTypography.headingLg),
            const SizedBox(height: AppSpacing.xs),
            Text('Version 1.0.0',
              style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'A professional email sending app built with Flutter, '
              'powered by your PHP backend.',
              style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl2),
            AppButton(
              label: 'Close',
              variant: AppButtonVariant.secondary,
              fullWidth: true,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // ── Logout ──
  void _confirmLogout(BuildContext context, WidgetRef ref) {
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
            const Icon(Icons.logout_rounded, size: 40, color: AppColors.danger),
            const SizedBox(height: AppSpacing.md),
            Text('Sign out?', style: AppTypography.headingMd),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You will need to sign in again to access MailFlow.',
              style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Sign Out',
              variant: AppButtonVariant.danger,
              fullWidth: true,
              onPressed: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
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

// ── Reusable menu item ──
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? color;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.color,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(children: [
        Icon(icon, size: 20, color: color ?? AppColors.textMuted),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(label,
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w500,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ),
        trailing ?? Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppColors.textLight,
        ),
      ]),
    ),
  );
}
