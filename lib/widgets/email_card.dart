import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_spacing.dart';
import '../models/email_model.dart';
import 'status_badge.dart';

class EmailCard extends StatelessWidget {
  final EmailModel email;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const EmailCard({
    super.key,
    required this.email,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  _Avatar(email: email.receiverEmail),
                  const SizedBox(width: AppSpacing.md),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                email.receiverEmail,
                                style: AppTypography.headingSm,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _formatDate(email.createdAt),
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          email.subject,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email.message.replaceAll(RegExp(r'<[^>]*>'), ''),
                          style: AppTypography.bodySm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            StatusBadge(status: email.status),
                            const SizedBox(width: AppSpacing.sm),
                            if (email.attachments != null)
                              const Icon(
                                Icons.attach_file_rounded,
                                size: 13, color: AppColors.textMuted,
                              ),
                            const Spacer(),
                            if (onDelete != null)
                              GestureDetector(
                                onTap: onDelete,
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18, color: AppColors.textLight,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.05, end: 0);
  }

  String _formatDate(String dt) {
    try {
      final d = DateTime.parse(dt);
      final now = DateTime.now();
      if (d.day == now.day) return '${d.hour}:${d.minute.toString().padLeft(2,'0')}';
      return '${d.day}/${d.month}';
    } catch (_) { return ''; }
  }
}

class _Avatar extends StatelessWidget {
  final String email;
  const _Avatar({required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: AppColors.avatarColor(email),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Center(
        child: Text(
          email[0].toUpperCase(),
          style: AppTypography.headingSm.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
