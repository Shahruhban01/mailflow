import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const _font = 'Inter';

  static const displayLg = TextStyle(
    fontFamily: _font, fontSize: 32,
    fontWeight: FontWeight.w800, letterSpacing: -0.8,
    color: AppColors.textPrimary,
  );
  static const displayMd = TextStyle(
    fontFamily: _font, fontSize: 26,
    fontWeight: FontWeight.w800, letterSpacing: -0.6,
    color: AppColors.textPrimary,
  );
  static const headingLg = TextStyle(
    fontFamily: _font, fontSize: 22,
    fontWeight: FontWeight.w700, letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );
  static const headingMd = TextStyle(
    fontFamily: _font, fontSize: 18,
    fontWeight: FontWeight.w700, letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );
  static const headingSm = TextStyle(
    fontFamily: _font, fontSize: 15,
    fontWeight: FontWeight.w600, letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );
  static const bodyLg = TextStyle(
    fontFamily: _font, fontSize: 16,
    fontWeight: FontWeight.w400, height: 1.6,
    color: AppColors.textPrimary,
  );
  static const bodyMd = TextStyle(
    fontFamily: _font, fontSize: 14,
    fontWeight: FontWeight.w400, height: 1.5,
    color: AppColors.textPrimary,
  );
  static const bodySm = TextStyle(
    fontFamily: _font, fontSize: 12,
    fontWeight: FontWeight.w400, height: 1.4,
    color: AppColors.textMuted,
  );
  static const labelLg = TextStyle(
    fontFamily: _font, fontSize: 13,
    fontWeight: FontWeight.w600, letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );
  static const labelSm = TextStyle(
    fontFamily: _font, fontSize: 11,
    fontWeight: FontWeight.w700, letterSpacing: 0.5,
    color: AppColors.textMuted,
  );
  static const caption = TextStyle(
    fontFamily: _font, fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
  );
}
