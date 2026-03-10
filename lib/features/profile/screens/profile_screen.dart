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
    final initial   = user?.name.isNotEmpty == true
        ? user!.name[0].toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),

              // ── Avatar ──
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

              // Name — rebuilds silently from authProvider
              Text(user?.name ?? 'User', style: AppTypography.headingLg)
                  .animate().fadeIn(delay: 100.ms),
              const SizedBox(height: AppSpacing.xs),
              Text(user?.email ?? '',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textMuted,
                ),
              ).animate().fadeIn(delay: 150.ms),

              // ── Signature preview chip ──
              if (user?.signature != null && user!.signature!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => _showSignatureEditor(
                      context, ref, user.signature ?? '',
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusFull,
                        ),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.draw_outlined,
                            size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              user.signature!.length > 30
                                  ? '${user.signature!.substring(0, 30)}…'
                                  : user.signature!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit_outlined,
                            size: 11, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 180.ms),

              const SizedBox(height: AppSpacing.xl2),

              // ── Main menu ──
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(children: [
                  _MenuItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit Profile',
                    onTap: () => _showEditProfile(
                      context, ref,
                      user?.name ?? '',
                      user?.signature ?? '',
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  _MenuItem(
                    icon: Icons.draw_outlined,
                    label: 'Email Signature',
                    onTap: () => _showSignatureEditor(
                      context, ref, user?.signature ?? '',
                    ),
                    trailing: user?.signature != null &&
                            user!.signature!.isNotEmpty
                        ? _Chip(label: 'Set', color: AppColors.success)
                        : _Chip(label: 'Not set', color: AppColors.textLight),
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
                      final mode  = ref.watch(themeProvider);
                      final label = switch (mode) {
                        AppThemeMode.light  => 'Light',
                        AppThemeMode.dark   => 'Dark',
                        AppThemeMode.system => 'System',
                      };
                      return _Chip(label: label, color: AppColors.primary);
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

              // ── Logout ──
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

  // ─────────────────────────────────────────
  // EDIT PROFILE (name + signature together)
  // ─────────────────────────────────────────
  void _showEditProfile(
    BuildContext context,
    WidgetRef ref,
    String currentName,
    String currentSignature,
  ) {
    final nameCtrl = TextEditingController(text: currentName);
    final sigCtrl  = TextEditingController(text: currentSignature);
    final form     = GlobalKey<FormState>();
    bool loading   = false;

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
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg,
            MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl2,
          ),
          child: Form(
            key: form,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Handle(),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Edit Profile', style: AppTypography.headingMd),
                  const SizedBox(height: AppSpacing.xl),

                  AppTextField(
                    label: 'Full Name',
                    hint: 'Your name',
                    controller: nameCtrl,
                    textInputAction: TextInputAction.next,
                    validator: Validators.name,
                    prefixIcon: const Icon(Icons.person_outline_rounded,
                      size: 18, color: AppColors.textLight),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Signature field
                  _SignatureField(controller: sigCtrl),

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
                            .updateProfile(
                          name:      nameCtrl.text.trim(),
                          signature: sigCtrl.text.trim(),
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          _toast(context, 'Profile updated!', AppColors.success);
                        }
                      } catch (e) {
                        setState(() => loading = false);
                        if (ctx.mounted) {
                          _toast(context, e.toString(), AppColors.danger);
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

  // ─────────────────────────────────────────
  // SIGNATURE EDITOR (dedicated sheet)
  // ─────────────────────────────────────────
  void _showSignatureEditor(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) {
    final ctrl    = TextEditingController(text: current);
    bool  loading = false;
    bool  saved   = false;

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
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg,
            MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Handle(),
              const SizedBox(height: AppSpacing.xl),

              // Header
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Icon(Icons.draw_outlined,
                    color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: AppSpacing.md),
                Text('Email Signature', style: AppTypography.headingMd),
              ]),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Appended automatically to every email you send',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              _SignatureField(controller: ctrl),

              const SizedBox(height: AppSpacing.md),

              // Live preview
              if (ctrl.text.isNotEmpty)
                _SignaturePreview(text: ctrl.text)
              else
                _EmptySignatureHint(),

              const SizedBox(height: AppSpacing.xl),

              // Action row
              Row(children: [
                // Clear button
                if (ctrl.text.isNotEmpty)
                  Expanded(
                    child: AppButton(
                      label: 'Clear',
                      variant: AppButtonVariant.ghost,
                      onPressed: () {
                        ctrl.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.delete_outline_rounded,
                        size: 15, color: AppColors.danger),
                    ),
                  ),
                if (ctrl.text.isNotEmpty)
                  const SizedBox(width: AppSpacing.md),

                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: saved ? 'Saved ✓' : 'Save Signature',
                    isLoading: loading,
                    onPressed: loading ? null : () async {
                      setState(() => loading = true);
                      try {
                        await ref
                            .read(profileProvider.notifier)
                            .updateSignatureOnly(ctrl.text.trim());
                        setState(() { loading = false; saved = true; });

                        // Auto-close after brief success flash
                        await Future.delayed(
                          const Duration(milliseconds: 700),
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        setState(() => loading = false);
                        if (ctx.mounted) {
                          _toast(context, e.toString(), AppColors.danger);
                        }
                      }
                    },
                    icon: saved
                        ? const Icon(Icons.check_circle_rounded,
                            size: 15, color: Colors.white)
                        : null,
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // CHANGE PASSWORD
  // ─────────────────────────────────────────
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
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg,
            MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl2,
          ),
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Handle(),
                const SizedBox(height: AppSpacing.xl),
                Text('Change Password', style: AppTypography.headingMd),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: 'Current Password',
                  hint: 'Enter current password',
                  controller: currentCtrl,
                  obscure: true,
                  textInputAction: TextInputAction.next,
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
                  textInputAction: TextInputAction.next,
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
                        _toast(context, 'Password changed successfully!',
                          AppColors.success);
                      }
                    } catch (e) {
                      setState(() => loading = false);
                      if (ctx.mounted) {
                        _toast(context, e.toString(), AppColors.danger);
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

  // ─────────────────────────────────────────
  // THEME PICKER
  // ─────────────────────────────────────────
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
              _Handle(),
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

  // ─────────────────────────────────────────
  // ABOUT
  // ─────────────────────────────────────────
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
            _Handle(),
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
              'A professional email sending app built with Flutter,\n'
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

  // ─────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────
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
            _Handle(),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded,
                size: 28, color: AppColors.danger),
            ),
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

  // ── Helpers ──
  void _toast(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      margin: const EdgeInsets.all(AppSpacing.lg),
    ));
  }
}

// ─────────────────────────────────────────
// SIGNATURE FIELD WIDGET
// ─────────────────────────────────────────
class _SignatureField extends StatefulWidget {
  final TextEditingController controller;
  const _SignatureField({required this.controller});
  @override
  State<_SignatureField> createState() => _SignatureFieldState();
}

class _SignatureFieldState extends State<_SignatureField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('EMAIL SIGNATURE', style: AppTypography.labelSm),
          const Spacer(),
          Text(
            '${widget.controller.text.length}/200',
            style: AppTypography.caption.copyWith(
              color: widget.controller.text.length > 180
                  ? AppColors.danger
                  : AppColors.textLight,
            ),
          ),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.dark3 : AppColors.bg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: AppColors.border,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toolbar row
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Row(children: [
                  Text('Signature',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const Spacer(),
                  if (widget.controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        widget.controller.clear();
                        setState(() {});
                      },
                      child: const Icon(Icons.close_rounded,
                        size: 14, color: AppColors.textLight),
                    ),
                ]),
              ),
              // Text area
              TextFormField(
                controller: widget.controller,
                maxLines: 4,
                maxLength: 200,
                style: AppTypography.bodyMd.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(AppSpacing.md),
                  filled: false,
                  hintText: 'e.g. Best regards,\nRuhban Abdullah\nBackend Engineer',
                  hintStyle: TextStyle(
                    color: AppColors.textLight,
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// SIGNATURE LIVE PREVIEW
// ─────────────────────────────────────────
class _SignaturePreview extends StatelessWidget {
  final String text;
  const _SignaturePreview({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.dark3.withOpacity(0.5)
            : AppColors.primaryLight.withOpacity(0.4),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.visibility_outlined,
              size: 12, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text('Preview', style: AppTypography.caption),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 40, height: 1,
            color: AppColors.border,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(text,
            style: AppTypography.bodyMd.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.textMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySignatureHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      border: Border.all(
        color: AppColors.border,
        style: BorderStyle.solid,
      ),
    ),
    child: Row(children: [
      const Icon(Icons.lightbulb_outline_rounded,
        size: 16, color: AppColors.textLight),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Text(
          'A signature adds your name, title, or contact info to every email.',
          style: AppTypography.caption,
        ),
      ),
    ]),
  );
}

// ─────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────
class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40, height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm, vertical: 3,
    ),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(label,
      style: AppTypography.caption.copyWith(color: color),
    ),
  );
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
