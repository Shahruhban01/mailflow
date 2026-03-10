import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form  = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass  = TextEditingController();

  @override
  void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    ref.read(authProvider.notifier).login(_email.text.trim(), _pass.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final isLoading = state is AuthLoading;

    ref.listen(authProvider, (_, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.msg),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientDark),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl2),
              child: Column(
                children: [
                  // Logo
                  _Logo().animate().fadeIn(delay: 100.ms).slideY(begin: -0.2),

                  const SizedBox(height: AppSpacing.xl3),

                  // Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 40, offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppSpacing.xl2),
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back', style: AppTypography.displayMd)
                              .animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                          const SizedBox(height: AppSpacing.xs),
                          Text('Sign in to continue to MailFlow',
                            style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
                          ).animate().fadeIn(delay: 250.ms),

                          const SizedBox(height: AppSpacing.xl2),

                          AppTextField(
                            label: 'Email Address',
                            hint: 'you@example.com',
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.mail_outline_rounded,
                              size: 18, color: AppColors.textLight),
                            validator: Validators.email,
                          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.05),

                          const SizedBox(height: AppSpacing.lg),

                          AppTextField(
                            label: 'Password',
                            hint: 'Enter your password',
                            controller: _pass,
                            obscure: true,
                            textInputAction: TextInputAction.done,
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                              size: 18, color: AppColors.textLight),
                            validator: Validators.password,
                          ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.05),

                          const SizedBox(height: AppSpacing.sm),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text('Forgot password?',
                                style: AppTypography.labelLg.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          AppButton(
                            label: 'Sign In',
                            onPressed: isLoading ? null : _submit,
                            isLoading: isLoading,
                            fullWidth: true,
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                          const SizedBox(height: AppSpacing.lg),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account? ",
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.push('/register'),
                                child: Text('Sign up',
                                  style: AppTypography.labelLg.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 450.ms),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          gradient: AppColors.gradientAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.mail_rounded, color: Colors.white, size: 20),
      ),
      const SizedBox(width: AppSpacing.md),
      Text('MailFlow',
        style: AppTypography.headingLg.copyWith(
          color: Colors.white, letterSpacing: -0.5,
        ),
      ),
    ],
  );
}
