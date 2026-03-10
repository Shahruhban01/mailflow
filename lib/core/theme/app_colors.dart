import 'package:flutter/material.dart';

/// MailFlow Design System — Color Palette
class AppColors {
  AppColors._();

  // Brand
  static const primary      = Color(0xFF6366F1);
  static const primaryDark  = Color(0xFF4F46E5);
  static const primaryLight = Color(0xFFE0E7FF);
  static const accent       = Color(0xFF06B6D4);

  // Semantic
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger  = Color(0xFFEF4444);
  static const info    = Color(0xFF3B82F6);

  // Dark surfaces
  static const dark       = Color(0xFF0F172A);
  static const dark2      = Color(0xFF1E293B);
  static const dark3      = Color(0xFF334155);
  static const darkCard   = Color(0xFF1A2236);

  // Light surfaces
  static const bg         = Color(0xFFF8FAFC);
  static const bgCard     = Color(0xFFFFFFFF);
  static const border     = Color(0xFFE2E8F0);
  static const borderDark = Color(0xFF2D3748);

  // Text
  static const textPrimary = Color(0xFF0F172A);
  static const textMuted   = Color(0xFF64748B);
  static const textLight   = Color(0xFF94A3B8);

  // Gradient presets
  static const gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const gradientAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  static const gradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [dark, Color(0xFF1E1B4B)],
  );

  // Avatar colors pool
  static const avatarColors = [
    Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899),
    Color(0xFF06B6D4), Color(0xFF10B981), Color(0xFFF59E0B),
    Color(0xFFEF4444), Color(0xFF3B82F6),
  ];

  static Color avatarColor(String seed) {
    final index = seed.codeUnits.fold(0, (a, b) => a + b) % avatarColors.length;
    return avatarColors[index];
  }
}
