import 'package:flutter/material.dart';
import 'app_colors.dart';

/// DayDone typography system — synced with the design system (tokens.jsx).
/// Uses platform system fonts (SF Pro on iOS, Roboto on Android).
/// Use [Theme.of(context).textTheme.*] in widgets — these are pre-wired into ThemeData.
abstract class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final primary   = isLight ? AppColors.textPrimaryLight   : AppColors.textPrimaryDark;
    final secondary = isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark;
    final disabled  = isLight ? AppColors.textDisabledLight  : AppColors.textDisabledDark;

    return TextTheme(
      // ── Display ─────────────────────────────────────────────────────────
      // Usage: Onboarding headings, "Good afternoon, Samir"
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.4,
        height: 1.2,
      ),

      // ── Headlines ───────────────────────────────────────────────────────
      // Usage: Screen titles
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: -0.2,
        height: 1.25,
      ),

      // Today greeting — Figma `.today-header .greeting` (24 / bold).
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.01,
        height: 1.1,
      ),

      // ── Titles ──────────────────────────────────────────────────────────
      // Usage: Card headings, section titles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: -0.2,
        height: 1.25,
      ),
      // Usage: Task titles in list, form field values (also tile title default)
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0,
        height: 1.35,
      ),
      // Usage: Smaller headings
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0,
        height: 1.35,
      ),

      // ── Body ────────────────────────────────────────────────────────────
      // Usage: Body copy, onboarding descriptions
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: secondary,
        letterSpacing: 0,
        height: 1.4,
      ),
      // Usage: Secondary body, subtitles, notes (14px — design bodyMedium)
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondary,
        letterSpacing: 0,
        height: 1.4,
      ),
      // Usage: Captions, counters, hints, timestamps (12px — design bodySmall)
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: disabled,
        letterSpacing: 0.1,
        height: 1.4,
      ),

      // ── Labels ──────────────────────────────────────────────────────────
      // Usage: Button labels
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0,
        height: 1.0,
      ),
      // Usage: Chip labels, filter chips, badges (12px — design labelMedium)
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondary,
        letterSpacing: 0.2,
        height: 1.3,
      ),
      // Usage: Tiny labels, overflow indicators (10px — design labelSmall)
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: disabled,
        letterSpacing: 0.3,
        height: 1.3,
      ),
    );
  }

  // ── Convenience getters for use outside of ThemeData ────────────────────

  /// Urgent task title — matches [tileTitleUrgent].
  static TextStyle urgentTaskTitle(Brightness brightness) =>
      tileTitleUrgent(brightness);

  /// Today date line — per screens-today.jsx: `bodyMedium` (14px regular).
  static TextStyle todayDatestamp(Brightness brightness) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.4,
        color: brightness == Brightness.light
            ? AppColors.textSecondaryLight
            : AppColors.textSecondaryDark,
      );

  /// Task tile title — Figma `.tile .title` (14 / medium).
  static TextStyle tileTitle(Brightness brightness) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: brightness == Brightness.light
            ? AppColors.textPrimaryLight
            : AppColors.textPrimaryDark,
        letterSpacing: 0,
        height: 1.25,
      );

  /// Urgent tile title — Figma `.tile.urgent .title` (14 / bold).
  static TextStyle tileTitleUrgent(Brightness brightness) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: brightness == Brightness.light
            ? AppColors.textPrimaryLight
            : AppColors.textPrimaryDark,
        letterSpacing: 0,
        height: 1.25,
      );

  /// Done/closed task title — muted + strikethrough.
  static TextStyle doneTaskTitle(Brightness brightness) =>
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: brightness == Brightness.light
            ? AppColors.textDisabledLight
            : AppColors.textDisabledDark,
        decoration: TextDecoration.lineThrough,
        decorationColor: brightness == Brightness.light
            ? AppColors.textDisabledLight
            : AppColors.textDisabledDark,
        letterSpacing: 0,
        height: 1.25,
      );
}
