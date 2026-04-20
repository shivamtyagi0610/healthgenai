import 'package:flutter/material.dart';

/// Centralized color palette for HealthGenAI.
/// Medical green theme inspired by the brand identity.
abstract final class AppColors {
  // ─── Primary Palette ────────────────────────────────────────────
  static const Color primary = Color(0xFF43C97A);
  static const Color primaryLight = Color(0xFF6EE7A0);
  static const Color primaryDark = Color(0xFF2DA55E);
  static const Color primarySurface = Color(0xFFE8F9F0);

  // ─── Background & Surface ───────────────────────────────────────
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F5);
  static const Color card = Color(0xFFFFFFFF);

  // ─── Text ───────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Input Fields ──────────────────────────────────────────────
  static const Color inputBorder = Color(0xFFE5E7EB);
  static const Color inputFill = Color(0xFFFFFFFF);
  static const Color inputIcon = Color(0xFF9CA3AF);
  static const Color inputFocusBorder = Color(0xFF43C97A);

  // ─── Status Colors ─────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── Misc ──────────────────────────────────────────────────────
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shadow = Color(0x1A000000);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
