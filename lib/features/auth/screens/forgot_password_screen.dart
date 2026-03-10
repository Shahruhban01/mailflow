import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _form  = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false, _loading = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).forgotPassword(_email.text.trim());
      setState(() => _sent = true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    } finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientDark),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl2),
              child: Column(
                children: [
                  Row(children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.xl2),
                    child: _sent ? _SuccessView(email: _email.text) : Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reset password', style: AppTypography.displayMd),
                          const SizedBox(height: AppSpacing.xs),
                          Text("Enter your email and we'll send a reset link",
                            style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: AppSpacing.xl2),
                          AppTextField(
                            label: 'Email Address', hint: 'you@example.com',
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.mail_outline_rounded,
                              size: 18, color: AppColors.textLight),
                            validator: Validators.email,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppButton(
                            label: 'Send Reset Link',
                            onPressed: _loading ? null : _submit,
                            isLoading: _loading,
                            fullWidth: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: const Icon(Icons.check_rounded, color: Color(0xFF065F46), size: 32),
      ),
      const SizedBox(height: AppSpacing.lg),
      Text('Check your inbox', style: AppTypography.headingMd),
      const SizedBox(height: AppSpacing.sm),
      Text("We sent a reset link to $email",
        style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
        textAlign: TextAlign.center,
      ),
    ],
  );
}
