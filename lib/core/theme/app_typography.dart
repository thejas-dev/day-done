import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// DayDone typography system.
/// Font: Inter (Google Fonts).
/// Use [Theme.of(context).textTheme.*] in widgets — these are pre-wired into ThemeData.
abstract class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final primary   = isLight ? AppColors.textPrimaryLight   : AppColors.textPrimaryDark;
    final secondary = isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark;
    final muted     = isLight ? AppColors.textMutedLight     : AppColors.textMutedDark;

    return GoogleFonts.interTextTheme(
      TextTheme(
        // ── Display ─────────────────────────────────────────────────────────
        // Usage: Onboarding headings ("When does your day end?")
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: primary,
          letterSpacing: -0.3,
          height: 1.3,
        ),

        // ── Headlines ───────────────────────────────────────────────────────
        // Usage: Screen titles
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: primary,
          letterSpacing: -0.3,
          height: 1.3,
        ),

        // ── Titles ──────────────────────────────────────────────────────────
        // Usage: Card headings, section titles
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: 0,
          height: 1.4,
        ),
        // Usage: Task titles in list, form field values
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: 0,
          height: 1.4,
        ),
        // Usage: Smaller headings
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: 0,
          height: 1.4,
        ),

        // ── Body ────────────────────────────────────────────────────────────
        // Usage: Body copy, onboarding descriptions
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: secondary,
          letterSpacing: 0,
          height: 1.5,
        ),
        // Usage: Secondary body, subtitles, notes
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: secondary,
          letterSpacing: 0,
          height: 1.5,
        ),
        // Usage: Captions, counters, hints, timestamps
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: muted,
          letterSpacing: 0,
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
        // Usage: Chip labels, filter chips, badges
        labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: secondary,
          letterSpacing: 0,
          height: 1.0,
        ),
        // Usage: Tiny labels, overflow indicators
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: muted,
          letterSpacing: 0,
          height: 1.0,
        ),
      ),
    );
  }

  // ── Convenience getters for use outside of ThemeData ────────────────────

  static TextStyle urgentTaskTitle(Brightness brightness) =>
      TextStyle(
        fontFamily: GoogleFonts.inter().fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w700, // bold for urgent
        color: brightness == Brightness.light
            ? AppColors.textPrimaryLight
            : AppColors.textPrimaryDark,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle doneTaskTitle(Brightness brightness) =>
      TextStyle(
        fontFamily: GoogleFonts.inter().fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: brightness == Brightness.light
            ? AppColors.textMutedLight
            : AppColors.textMutedDark,
        decoration: TextDecoration.lineThrough,
        decorationColor: brightness == Brightness.light
            ? AppColors.textMutedLight
            : AppColors.textMutedDark,
        letterSpacing: 0,
        height: 1.4,
      );
}
