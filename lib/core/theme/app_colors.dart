import 'package:flutter/material.dart';

abstract final class AppColors {
  // --- Brand ---
  static const Color primary = Color(0xFFB71C1C);
  static const Color primaryLight = Color(0xFFE53935);
  static const Color primaryDark = Color(0xFF7F0000);

  // --- Background ---
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceVariant = Color(0xFF1E1E1E);
  static const Color surfaceHighlight = Color(0xFF252525);

  // --- Text ---
  static const Color textPrimary = Color(0xFFF0EDE8);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted = Color(0xFF5C5C5C);
  static const Color textOnRed = Color(0xFFFFF5F5);

  // --- Status ---
  static const Color warning = Color(0xFFE65100);
  static const Color success = Color(0xFF1B5E20);
  static const Color info = Color(0xFF0D47A1);
  static const Color danger = Color(0xFFB71C1C);

  // --- Misc ---
  static const Color divider = Color(0xFF2A2A2A);
  static const Color border = Color(0xFF2E2E2E);
  static const Color shimmerBase = Color(0xFF1A1A1A);
  static const Color shimmerHighlight = Color(0xFF2A2A2A);

  // --- Source badges ---
  static const Color interpolBadge = Color(0xFF1A237E);
  static const Color interpolBadgeText = Color(0xFFBBDEFB);
  static const Color communityBadge = Color(0xFF1B5E20);
  static const Color communityBadgeText = Color(0xFFA5D6A7);
  static const Color pendingBadge = Color(0xFF4A3000);
  static const Color pendingBadgeText = Color(0xFFFFCC80);
}
