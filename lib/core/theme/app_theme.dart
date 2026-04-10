import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract class AppTheme {
  // ── Card shadow (light only) ─────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    const BoxShadow(
      color: Color(0x0A1A2B3C),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    const BoxShadow(
      color: Color(0x061A2B3C),
      blurRadius: 1,
      offset: Offset(0, 1),
    ),
  ];

  // ── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get light {
    const brightness = Brightness.light;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary:          AppColors.primary,
      onPrimary:        AppColors.onPrimary,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary:        AppColors.primary,
      onSecondary:      AppColors.onPrimary,
      secondaryContainer: AppColors.primaryLight,
      onSecondaryContainer: AppColors.primaryDark,
      tertiary:         AppColors.amber,
      onTertiary:       AppColors.onPrimary,
      tertiaryContainer: AppColors.amberLight,
      onTertiaryContainer: AppColors.warning,
      error:            AppColors.error,
      onError:          AppColors.onPrimary,
      errorContainer:   AppColors.errorLight,
      onErrorContainer: AppColors.error,
      surface:          AppColors.surfaceLight,
      onSurface:        AppColors.textPrimaryLight,
      surfaceContainerHighest: AppColors.surfaceVariantLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      outline:          AppColors.borderLight,
      outlineVariant:   AppColors.dividerLight,
      shadow:           const Color(0x0A1A2B3C),
      scrim:            const Color(0x661A2B3C),
      inverseSurface:   AppColors.textPrimaryLight,
      onInverseSurface: AppColors.surfaceLight,
      inversePrimary:   AppColors.primaryLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: AppTypography.textTheme(brightness),

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme(brightness).headlineMedium,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      ),

      // ── Bottom Navigation ─────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMutedLight,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Cards ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Elevated Button (Primary CTA) ─────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.disabledBackground;
            }
            return AppColors.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.disabledText;
            }
            return AppColors.onPrimary;
          }),
          overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
          ),
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
          textStyle: WidgetStateProperty.all(
            AppTypography.textTheme(brightness).labelLarge,
          ),
          animationDuration: const Duration(milliseconds: 150),
        ),
      ),

      // ── Text Button (ghost / skip) ────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(AppColors.textSecondaryLight),
          overlayColor: WidgetStateProperty.all(
            AppColors.primary.withOpacity(0.06),
          ),
          textStyle: WidgetStateProperty.all(
            AppTypography.textTheme(brightness).bodyMedium,
          ),
          minimumSize: WidgetStateProperty.all(const Size(88, 44)),
        ),
      ),

      // ── Input Fields ──────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: AppTypography.textTheme(brightness).bodyMedium?.copyWith(
          color: AppColors.textMutedLight,
        ),
        labelStyle: AppTypography.textTheme(brightness).bodyMedium,
        errorStyle: AppTypography.textTheme(brightness).bodySmall?.copyWith(
          color: AppColors.error,
        ),
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
        showDragHandle: false,
        dragHandleColor: AppColors.borderLight,
        dragHandleSize: Size(32, 4),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
        space: 1,
      ),

      // ── Chip (base — use custom widgets where possible) ───────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariantLight,
        labelStyle: AppTypography.textTheme(brightness).labelSmall,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        titleTextStyle: AppTypography.textTheme(brightness).titleLarge,
        contentTextStyle: AppTypography.textTheme(brightness).bodyMedium,
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textMutedLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryLight;
          return AppColors.borderLight;
        }),
      ),
    );
  }

  // ── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get dark {
    const brightness = Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary:          AppColors.primaryDarkMode,
      onPrimary:        AppColors.onPrimary,
      primaryContainer: AppColors.primaryLightDarkMode,
      onPrimaryContainer: AppColors.primaryDarkDarkMode,
      secondary:        AppColors.primaryDarkMode,
      onSecondary:      AppColors.onPrimary,
      secondaryContainer: AppColors.primaryLightDarkMode,
      onSecondaryContainer: AppColors.primaryDarkMode,
      tertiary:         AppColors.amber,
      onTertiary:       AppColors.onPrimary,
      tertiaryContainer: AppColors.badgeAmberDark,
      onTertiaryContainer: AppColors.amber,
      error:            AppColors.error,
      onError:          AppColors.onPrimary,
      errorContainer:   AppColors.badgeRedDark,
      onErrorContainer: AppColors.error,
      surface:          AppColors.surfaceDark,
      onSurface:        AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline:          AppColors.borderDark,
      outlineVariant:   AppColors.dividerDark,
      shadow:           Colors.transparent,
      scrim:            const Color(0x99000000),
      inverseSurface:   AppColors.surfaceLight,
      onInverseSurface: AppColors.textPrimaryLight,
      inversePrimary:   AppColors.primaryLightDarkMode,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: AppTypography.textTheme(brightness),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme(brightness).headlineMedium,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryDarkMode,
        unselectedItemColor: AppColors.textMutedDark,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.surfaceVariantDark;
            }
            return AppColors.primaryDarkMode;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.textMutedDark;
            }
            return AppColors.onPrimary;
          }),
          overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.08)),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
          ),
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
          textStyle: WidgetStateProperty.all(
            AppTypography.textTheme(brightness).labelLarge,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(AppColors.textSecondaryDark),
          overlayColor: WidgetStateProperty.all(
            AppColors.primaryDarkMode.withOpacity(0.08),
          ),
          textStyle: WidgetStateProperty.all(
            AppTypography.textTheme(brightness).bodyMedium,
          ),
          minimumSize: WidgetStateProperty.all(const Size(88, 44)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: const BorderSide(color: AppColors.primaryDarkMode, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: AppTypography.textTheme(brightness).bodyMedium?.copyWith(
          color: AppColors.textMutedDark,
        ),
        labelStyle: AppTypography.textTheme(brightness).bodyMedium,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
        showDragHandle: false,
        dragHandleColor: AppColors.borderDark,
        dragHandleSize: Size(32, 4),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariantDark,
        labelStyle: AppTypography.textTheme(brightness).labelSmall,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        titleTextStyle: AppTypography.textTheme(brightness).titleLarge,
        contentTextStyle: AppTypography.textTheme(brightness).bodyMedium,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryDarkMode;
          return AppColors.textMutedDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryLightDarkMode;
          return AppColors.borderDark;
        }),
      ),
    );
  }
}
