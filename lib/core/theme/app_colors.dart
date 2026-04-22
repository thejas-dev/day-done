import 'package:flutter/material.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';

/// DayDone colour tokens — synced with the design system (tokens.jsx).
/// Never use raw hex values in widget code — always reference this class.
abstract class AppColors {
  // ── Primary ───────────────────────────────────────────────────────────────
  static const Color primary          = Color(0xFF00796B);
  static const Color primaryContainer = Color(0xFFE0F2F1);
  static const Color primaryBorder    = Color(0xFF00796B);
  static const Color onPrimary        = Color(0xFFFFFFFF);

  static const Color primaryDark          = Color(0xFF4DB6AC);
  static const Color primaryContainerDark = Color(0xFF0F3530);
  static const Color primaryBorderDark    = Color(0xFF4DB6AC);
  static const Color onPrimaryDark        = Color(0xFF0B1416);

  // ── Backgrounds (Figma: docs/design/styles.css :root / .dark) ─────────────
  static const Color backgroundLight = Color(0xFFF5F5F3);
  static const Color backgroundDark  = Color(0xFF121212);

  static const Color surfaceLight      = Color(0xFFFFFFFF);
  static const Color surfaceDark       = Color(0xFF1E1E1E);

  static const Color surfaceRaisedLight = Color(0xFFFFFFFF);
  static const Color surfaceRaisedDark  = Color(0xFF2C2C2C);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimaryLight   = Color(0xFF1A1A1A);
  static const Color textPrimaryDark    = Color(0xFFFAFAFA);

  static const Color textSecondaryLight = Color(0xFF6B6B6B);
  static const Color textSecondaryDark  = Color(0xFFA0A0A0);

  static const Color textDisabledLight  = Color(0xFFB8B8B8);
  static const Color textDisabledDark   = Color(0xFF5A5A5A);

  static const Color textOnAccentLight  = Color(0xFFFFFFFF);
  static const Color textOnAccentDark   = Color(0xFF0B1416);

  // ── Borders & Dividers ────────────────────────────────────────────────────
  /// Hairline divider — matches `--divider` rgba(0,0,0,0.07) in light mode.
  static const Color dividerLight  = Color(0x12000000);
  static const Color dividerDark   = Color(0x14FFFFFF);

  static const Color chipBorderLight = Color(0xFFCFD4D9);
  static const Color chipBorderDark  = Color(0xFF3A3A3A);

  // ── Scrim ─────────────────────────────────────────────────────────────────
  static const Color scrimLight = Color(0x7A0F1419); // rgba(15,20,25,0.48)
  static const Color scrimDark  = Color(0x9E000000); // rgba(0,0,0,0.62)

  // ── Priority ─────────────────────────────────────────────────────────────
  static const Color priorityUrgentLight = Color(0xFFD32F2F);
  static const Color priorityHighLight   = Color(0xFFE64A19);
  static const Color priorityMediumLight = Color(0xFFF9A825);
  static const Color priorityLowLight    = Color(0xFF90A4AE);

  static const Color priorityUrgentDark  = Color(0xFFEF5350);
  static const Color priorityHighDark    = Color(0xFFFF6E40);
  static const Color priorityMediumDark  = Color(0xFFFFD54F);
  static const Color priorityLowDark     = Color(0xFF607D8B);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color successLight  = Color(0xFF388E3C);
  static const Color successDark   = Color(0xFF66BB6A);

  static const Color warningLight  = Color(0xFFF9A825);
  static const Color warningDark   = Color(0xFFFFB300);

  static const Color errorLight    = Color(0xFFD32F2F);
  static const Color errorDark     = Color(0xFFEF5350);

  static const Color infoLight     = Color(0xFF1976D2);
  static const Color infoDark      = Color(0xFF64B5F6);

  // ── Progress ──────────────────────────────────────────────────────────────
  static const Color onTrackLight  = Color(0xFF388E3C);
  static const Color onTrackDark   = Color(0xFF66BB6A);

  static const Color partialLight  = Color(0xFFF57C00);
  static const Color partialDark   = Color(0xFFFFB300);

  // ── Semantic Tints ────────────────────────────────────────────────────────
  static const Color errorTintLight   = Color(0xFFFDECEA);
  static const Color errorTintDark    = Color(0xFF2A1616);

  static const Color warningTintLight = Color(0xFFFEF3D9);
  static const Color warningTintDark  = Color(0xFF2A2416);

  static const Color infoTintLight    = Color(0xFFE6F0FA);
  static const Color infoTintDark     = Color(0xFF16202A);

  static const Color successTintLight = Color(0xFFE4F3E4);
  static const Color successTintDark  = Color(0xFF16231A);

  static const Color urgentTileTintLight = Color(0xFFFFF5F4);
  static const Color urgentTileTintDark  = Color(0xFF2A1A1A);

  // ── Nav ───────────────────────────────────────────────────────────────────
  static const Color navLight          = Color(0xFFFFFFFF);
  static const Color navDark           = Color(0xFF1E1E1E);

  static const Color navIndicatorLight = Color(0xFFE0F2F1);
  static const Color navIndicatorDark  = Color(0xFF0F3530);

  // ── Label chip background (inline on tiles — Figma `.tile .chip`) ────────
  static const Color labelChipBgLight = Color(0x12000000);
  static const Color labelChipBgDark  = Color(0x14FFFFFF);

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns the correct priority colour for [priority] and [brightness].
  static Color priorityColor(Priority priority, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return switch (priority) {
      Priority.none   => Colors.transparent,
      Priority.low    => dark ? priorityLowDark    : priorityLowLight,
      Priority.medium => dark ? priorityMediumDark : priorityMediumLight,
      Priority.high   => dark ? priorityHighDark   : priorityHighLight,
      Priority.urgent => dark ? priorityUrgentDark : priorityUrgentLight,
    };
  }

  static Color successColor(Brightness brightness) =>
      brightness == Brightness.light ? successLight : successDark;

  static Color errorColor(Brightness brightness) =>
      brightness == Brightness.light ? errorLight : errorDark;

  static Color warningColor(Brightness brightness) =>
      brightness == Brightness.light ? warningLight : warningDark;

  static Color infoColor(Brightness brightness) =>
      brightness == Brightness.light ? infoLight : infoDark;

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
          border: dark ? priorityLowDark    : priorityLowLight,
          badge:  dark ? const Color(0xFF1E2530) : const Color(0xFFF1F3F5),
          icon:   dark ? priorityLowDark    : priorityLowLight,
        ),
      Priority.medium => (
          border: dark ? priorityMediumDark : priorityMediumLight,
          badge:  dark ? warningTintDark    : warningTintLight,
          icon:   dark ? priorityMediumDark : priorityMediumLight,
        ),
      Priority.high   => (
          border: dark ? priorityHighDark   : priorityHighLight,
          badge:  dark ? const Color(0xFF2A1A0A) : const Color(0xFFFFF7ED),
          icon:   dark ? priorityHighDark   : priorityHighLight,
        ),
      Priority.urgent => (
          border: dark ? priorityUrgentDark : priorityUrgentLight,
          badge:  dark ? errorTintDark      : errorTintLight,
          icon:   dark ? priorityUrgentDark : priorityUrgentLight,
        ),
    };
  }

  // ── Legacy aliases (older widgets; prefer theme + *Color(brightness)) ────
  static const Color success = successLight;
  static const Color error = errorLight;
  static const Color warning = warningLight;
  static const Color borderLight = dividerLight;
  static const Color borderDark = dividerDark;
  static const Color textMutedLight = textSecondaryLight;
  static const Color textMutedDark = textSecondaryDark;
  static const Color surfaceVariantLight = surfaceRaisedLight;
  static const Color surfaceVariantDark = surfaceRaisedDark;
  static const Color primaryLight = primaryContainer;
  static const Color primaryLightDarkMode = primaryContainerDark;
  static const Color primaryDarkDarkMode = primaryDark;
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
  static const double sm   = 8.0;   // chipRadius
  static const double md   = 12.0;  // tileRadius
  static const double sheetTop = 20.0; // bottom sheet top corners (Figma `.bsheet`)
  static const double lg   = 16.0;  // sheetRadius
  static const double xl   = 24.0;
  static const double full = 999.0;

  /// Progress bar radius
  static const double progress = 4.0;

  /// FAB radius
  static const double fab = 28.0;

  static BorderRadius get smAll       => BorderRadius.circular(sm);
  static BorderRadius get mdAll       => BorderRadius.circular(md);
  static BorderRadius get lgAll       => BorderRadius.circular(lg);
  static BorderRadius get xlAll       => BorderRadius.circular(xl);
  static BorderRadius get fullAll     => BorderRadius.circular(full);
  static BorderRadius get progressAll => BorderRadius.circular(progress);
  static BorderRadius get fabAll      => BorderRadius.circular(fab);
}

/// Priority strip width (left edge of task tiles).
const double kPriorityStripWidth = 5.0;
