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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form  = GlobalKey<FormState>();
  final _name  = TextEditingController();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  final _conf  = TextEditingController();

  @override
  void dispose() {
    _name.dispose(); _email.dispose();
    _pass.dispose(); _conf.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    ref.read(authProvider.notifier).register(
      _name.text.trim(), _email.text.trim(), _pass.text,
    );
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
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      ),
                      Text('MailFlow',
                        style: AppTypography.headingMd.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
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
                          Text('Create account', style: AppTypography.displayMd),
                          const SizedBox(height: AppSpacing.xs),
                          Text('Start sending emails in seconds',
                            style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: AppSpacing.xl2),

                          AppTextField(
                            label: 'Full Name', hint: 'John Doe',
                            controller: _name,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.person_outline_rounded,
                              size: 18, color: AppColors.textLight),
                            validator: Validators.name,
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          AppTextField(
                            label: 'Email Address', hint: 'you@example.com',
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.mail_outline_rounded,
                              size: 18, color: AppColors.textLight),
                            validator: Validators.email,
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          AppTextField(
                            label: 'Password', hint: 'Min. 8 characters',
                            controller: _pass, obscure: true,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                              size: 18, color: AppColors.textLight),
                            validator: Validators.password,
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          AppTextField(
                            label: 'Confirm Password', hint: 'Re-enter password',
                            controller: _conf, obscure: true,
                            textInputAction: TextInputAction.done,
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                              size: 18, color: AppColors.textLight),
                            validator: (v) {
                              if (v != _pass.text) return 'Passwords do not match.';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          AppButton(
                            label: 'Create Account',
                            onPressed: isLoading ? null : _submit,
                            isLoading: isLoading,
                            fullWidth: true,
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Already have an account? ',
                                style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
                              ),
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: Text('Sign in',
                                  style: AppTypography.labelLg.copyWith(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
