import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_spacing.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'sent'      => (const Color(0xFFD1FAE5), const Color(0xFF065F46)),
      'failed'    => (const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
      'draft'     => (const Color(0xFFFEF3C7), const Color(0xFF92400E)),
      'scheduled' => (AppColors.primaryLight,   AppColors.primaryDark),
      _           => (const Color(0xFFF1F5F9), AppColors.textMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm, vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: AppTypography.caption.copyWith(
          color: fg, fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
