import 'package:flutter/material.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';

/// DayDone colour tokens.
/// Never use raw hex values in widget code — always reference this class.
abstract class AppColors {
  // ── Primary ───────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF3D9E9E);
  static const Color primaryLight = Color(0xFFE3F4F4);
  static const Color primaryDark  = Color(0xFF2E7A7A);
  static const Color onPrimary    = Color(0xFFFFFFFF);

  static const Color primaryDarkMode      = Color(0xFF4DB6B6);
  static const Color primaryLightDarkMode = Color(0xFF1A3A3A);
  static const Color primaryDarkDarkMode  = Color(0xFF3DA8A8);

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color backgroundLight      = Color(0xFFF1F3F5);
  static const Color backgroundDark       = Color(0xFF111318);

  static const Color surfaceLight         = Color(0xFFFFFFFF);
  static const Color surfaceDark          = Color(0xFF1C2128);

  static const Color surfaceVariantLight  = Color(0xFFF7F8FA);
  static const Color surfaceVariantDark   = Color(0xFF242A33);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimaryLight     = Color(0xFF1A2B3C);
  static const Color textPrimaryDark      = Color(0xFFE8ECF0);

  static const Color textSecondaryLight   = Color(0xFF6B7A90);
  static const Color textSecondaryDark    = Color(0xFF8A9BB0);

  static const Color textMutedLight       = Color(0xFFA8B4C0);
  static const Color textMutedDark        = Color(0xFF4A5568);

  static const Color textLinkLight        = Color(0xFF3D9E9E);
  static const Color textLinkDark         = Color(0xFF4DB6B6);

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color borderLight          = Color(0xFFE4E8ED);
  static const Color borderDark           = Color(0xFF2D3748);

  static const Color dividerLight         = Color(0xFFEDF0F3);
  static const Color dividerDark          = Color(0xFF242A33);

  // ── Priority ─────────────────────────────────────────────────────────────
  // none → no decoration
  static const Color priorityNoneBorder   = Color(0x00000000); // transparent

  static const Color priorityLowBorder    = Color(0xFFA8B4C0);
  static const Color priorityLowBadge     = Color(0xFFF1F3F5);
  static const Color priorityLowIcon      = Color(0xFFA8B4C0);

  static const Color priorityMediumBorder = Color(0xFFF59E0B);
  static const Color priorityMediumBadge  = Color(0xFFFFFBEB);
  static const Color priorityMediumIcon   = Color(0xFFF59E0B);

  static const Color priorityHighBorder   = Color(0xFFF97316);
  static const Color priorityHighBadge    = Color(0xFFFFF7ED);
  static const Color priorityHighIcon     = Color(0xFFF97316);

  static const Color priorityUrgentBorder = Color(0xFFEF4444);
  static const Color priorityUrgentBadge  = Color(0xFFFEF2F2);
  static const Color priorityUrgentIcon   = Color(0xFFEF4444);

  // Dark mode priority — same hue, +10% lightness
  static const Color priorityLowBorderDark    = Color(0xFFBCC8D4);
  static const Color priorityLowBadgeDark     = Color(0xFF1E2530);
  static const Color priorityMediumBorderDark = Color(0xFFFBBF24);
  static const Color priorityMediumBadgeDark  = Color(0xFF2A2010);
  static const Color priorityHighBorderDark   = Color(0xFFFB923C);
  static const Color priorityHighBadgeDark    = Color(0xFF2A1A0A);
  static const Color priorityUrgentBorderDark = Color(0xFFF87171);
  static const Color priorityUrgentBadgeDark  = Color(0xFF2A1010);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFF0FDF4);
  static const Color successDark  = Color(0xFF0F2A1A);

  static const Color warning      = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);

  static const Color error        = Color(0xFFEF4444);
  static const Color errorLight   = Color(0xFFFEF2F2);

  static const Color amber        = Color(0xFFF59E0B);
  static const Color amberLight   = Color(0xFFFFFBEB);

  // ── Icon badge backgrounds (notification screen) ──────────────────────────
  static const Color badgeTeal    = Color(0xFFE3F4F4);
  static const Color badgeAmber   = Color(0xFFFFFBEB);
  static const Color badgeOrange  = Color(0xFFFFF7ED);
  static const Color badgeRed     = Color(0xFFFEF2F2);

  static const Color badgeTealDark   = Color(0xFF1A3A3A);
  static const Color badgeAmberDark  = Color(0xFF2A2010);
  static const Color badgeOrangeDark = Color(0xFF2A1A0A);
  static const Color badgeRedDark    = Color(0xFF2A1010);

  // ── Disabled ─────────────────────────────────────────────────────────────
  static const Color disabledBackground = Color(0xFFE4E8ED);
  static const Color disabledText       = Color(0xFFA8B4C0);

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns the correct set of priority colours for [brightness].
  static ({
    Color border,
    Color badge,
    Color icon,
  }) priorityColors(Priority priority, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return switch (priority) {
      Priority.none   => (border: Colors.transparent, badge: Colors.transparent, icon: Colors.transparent),
      Priority.low    => (
          border: dark ? priorityLowBorderDark    : priorityLowBorder,
          badge:  dark ? priorityLowBadgeDark     : priorityLowBadge,
          icon:   dark ? priorityLowBorderDark    : priorityLowIcon,
        ),
      Priority.medium => (
          border: dark ? priorityMediumBorderDark : priorityMediumBorder,
          badge:  dark ? priorityMediumBadgeDark  : priorityMediumBadge,
          icon:   dark ? priorityMediumBorderDark : priorityMediumIcon,
        ),
      Priority.high   => (
          border: dark ? priorityHighBorderDark   : priorityHighBorder,
          badge:  dark ? priorityHighBadgeDark    : priorityHighBadge,
          icon:   dark ? priorityHighBorderDark   : priorityHighIcon,
        ),
      Priority.urgent => (
          border: dark ? priorityUrgentBorderDark : priorityUrgentBorder,
          badge:  dark ? priorityUrgentBadgeDark  : priorityUrgentBadge,
          icon:   dark ? priorityUrgentBorderDark : priorityUrgentIcon,
        ),
    };
  }
}

/// Spacing constants. Use only these values — never arbitrary numbers.
abstract class AppSpacing {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 20.0;
  static const double xl2 = 24.0;
  static const double xl3 = 32.0;
  static const double xl4 = 40.0;
  static const double xl5 = 48.0;
}

/// Border radius constants.
abstract class AppRadius {
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 24.0;
  static const double full = 999.0;

  static BorderRadius get smAll   => BorderRadius.circular(sm);
  static BorderRadius get mdAll   => BorderRadius.circular(md);
  static BorderRadius get lgAll   => BorderRadius.circular(lg);
  static BorderRadius get xlAll   => BorderRadius.circular(xl);
  static BorderRadius get fullAll => BorderRadius.circular(full);
}

