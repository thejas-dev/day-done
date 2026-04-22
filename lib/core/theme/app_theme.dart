import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract class AppTheme {
  // ── Elevation / Shadow tokens (from design ELEV) ─────────────────────────

  /// Light tile: 0 1px 2px rgba(16,24,32,0.06), 0 1px 1px rgba(16,24,32,0.04)
  static List<BoxShadow> get tileShadowLight => const [
    BoxShadow(color: Color(0x0F101820), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A101820), blurRadius: 1, offset: Offset(0, 1)),
  ];

  /// Dark tile: 0 1px 2px rgba(0,0,0,0.4)
  static List<BoxShadow> get tileShadowDark => const [
    BoxShadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  /// Light sheet: 0 -8px 24px rgba(16,24,32,0.12)
  static List<BoxShadow> get sheetShadowLight => const [
    BoxShadow(color: Color(0x1F101820), blurRadius: 24, offset: Offset(0, -8)),
  ];

  /// Dark sheet: 0 -10px 28px rgba(0,0,0,0.6)
  static List<BoxShadow> get sheetShadowDark => const [
    BoxShadow(color: Color(0x99000000), blurRadius: 28, offset: Offset(0, -10)),
  ];

  /// Light FAB — Figma `--shadow-fab`: 0 6px 16px rgba(0, 121, 107, 0.35)
  static List<BoxShadow> get fabShadowLight => const [
    BoxShadow(color: Color(0x5900796B), blurRadius: 16, offset: Offset(0, 6)),
  ];

  /// Card / task tile elevation — matches `--shadow-tile` (light).
  static List<BoxShadow> cardShadow(Brightness brightness) =>
      brightness == Brightness.light ? tileShadowLight : tileShadowDark;

  /// Dark FAB: 0 6px 14px rgba(77,182,172,0.35), 0 2px 4px rgba(0,0,0,0.4)
  static List<BoxShadow> get fabShadowDark => const [
    BoxShadow(color: Color(0x594DB6AC), blurRadius: 14, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x66000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  // ── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get light {
    const brightness = Brightness.light;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary:            AppColors.primary,
      onPrimary:          AppColors.onPrimary,
      primaryContainer:   AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primary,
      secondary:          AppColors.primary,
      onSecondary:        AppColors.onPrimary,
      secondaryContainer: AppColors.primaryContainer,
      onSecondaryContainer: AppColors.primary,
      tertiary:           AppColors.warningLight,
      onTertiary:         AppColors.onPrimary,
      tertiaryContainer:  AppColors.warningTintLight,
      onTertiaryContainer: AppColors.warningLight,
      error:              AppColors.errorLight,
      onError:            AppColors.onPrimary,
      errorContainer:     AppColors.errorTintLight,
      onErrorContainer:   AppColors.errorLight,
      surface:            AppColors.surfaceLight,
      onSurface:          AppColors.textPrimaryLight,
      surfaceContainerHighest: AppColors.surfaceRaisedLight,
      onSurfaceVariant:   AppColors.textSecondaryLight,
      outline:            AppColors.dividerLight,
      outlineVariant:     AppColors.dividerLight,
      shadow:             const Color(0x0F101820),
      scrim:              AppColors.scrimLight,
      inverseSurface:     AppColors.textPrimaryLight,
      onInverseSurface:   AppColors.surfaceLight,
      inversePrimary:     AppColors.primaryContainer,
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
        backgroundColor: AppColors.navLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
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
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        margin: EdgeInsets.zero,
      ),

      // ── Elevated Button (Primary CTA) ─────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.chipBorderLight;
            }
            return AppColors.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.textDisabledLight;
            }
            return AppColors.onPrimary;
          }),
          overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          ),
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 48)),
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
            AppColors.primary.withValues(alpha: 0.06),
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
          borderSide: const BorderSide(color: AppColors.dividerLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: const BorderSide(color: AppColors.dividerLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: const BorderSide(color: AppColors.errorLight, width: 1),
        ),
        hintStyle: AppTypography.textTheme(brightness).bodyMedium?.copyWith(
          color: AppColors.textDisabledLight,
        ),
        labelStyle: AppTypography.textTheme(brightness).bodyMedium,
        errorStyle: AppTypography.textTheme(brightness).bodySmall?.copyWith(
          color: AppColors.errorLight,
        ),
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheetTop),
          ),
        ),
        showDragHandle: false,
        dragHandleColor: AppColors.dividerLight,
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
        backgroundColor: AppColors.surfaceLight,
        labelStyle: AppTypography.textTheme(brightness).labelSmall,
        side: const BorderSide(color: AppColors.chipBorderLight),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
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
          return AppColors.textDisabledLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryContainer;
          return AppColors.dividerLight;
        }),
      ),

      // ── FloatingActionButton ──────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 6,
        highlightElevation: 8,
        shape: CircleBorder(),
        sizeConstraints: BoxConstraints.tightFor(width: 56, height: 56),
      ),
    );
  }

  // ── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get dark {
    const brightness = Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary:            AppColors.primaryDark,
      onPrimary:          AppColors.onPrimaryDark,
      primaryContainer:   AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.primaryDark,
      secondary:          AppColors.primaryDark,
      onSecondary:        AppColors.onPrimaryDark,
      secondaryContainer: AppColors.primaryContainerDark,
      onSecondaryContainer: AppColors.primaryDark,
      tertiary:           AppColors.warningDark,
      onTertiary:         AppColors.onPrimaryDark,
      tertiaryContainer:  AppColors.warningTintDark,
      onTertiaryContainer: AppColors.warningDark,
      error:              AppColors.errorDark,
      onError:            AppColors.onPrimaryDark,
      errorContainer:     AppColors.errorTintDark,
      onErrorContainer:   AppColors.errorDark,
      surface:            AppColors.surfaceDark,
      onSurface:          AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.surfaceRaisedDark,
      onSurfaceVariant:   AppColors.textSecondaryDark,
      outline:            AppColors.dividerDark,
      outlineVariant:     AppColors.dividerDark,
      shadow:             Colors.transparent,
      scrim:              AppColors.scrimDark,
      inverseSurface:     AppColors.surfaceLight,
      onInverseSurface:   AppColors.textPrimaryLight,
      inversePrimary:     AppColors.primaryContainerDark,
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
        backgroundColor: AppColors.navDark,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textSecondaryDark,
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
              return AppColors.chipBorderDark;
            }
            return AppColors.primaryDark;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.textDisabledDark;
            }
            return AppColors.onPrimaryDark;
          }),
          overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.08)),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          ),
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 48)),
          textStyle: WidgetStateProperty.all(
            AppTypography.textTheme(brightness).labelLarge,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(AppColors.textSecondaryDark),
          overlayColor: WidgetStateProperty.all(
            AppColors.primaryDark.withValues(alpha: 0.08),
          ),
          textStyle: WidgetStateProperty.all(
            AppTypography.textTheme(brightness).bodyMedium,
          ),
          minimumSize: WidgetStateProperty.all(const Size(88, 44)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceRaisedDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: const BorderSide(color: AppColors.dividerDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: const BorderSide(color: AppColors.dividerDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: const BorderSide(color: AppColors.errorDark, width: 1),
        ),
        hintStyle: AppTypography.textTheme(brightness).bodyMedium?.copyWith(
          color: AppColors.textDisabledDark,
        ),
        labelStyle: AppTypography.textTheme(brightness).bodyMedium,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheetTop),
          ),
        ),
        showDragHandle: false,
        dragHandleColor: AppColors.dividerDark,
        dragHandleSize: Size(32, 4),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDark,
        labelStyle: AppTypography.textTheme(brightness).labelSmall,
        side: const BorderSide(color: AppColors.chipBorderDark),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
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
          if (states.contains(WidgetState.selected)) return AppColors.primaryDark;
          return AppColors.textDisabledDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryContainerDark;
          return AppColors.dividerDark;
        }),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.onPrimaryDark,
        elevation: 6,
        highlightElevation: 8,
        shape: CircleBorder(),
        sizeConstraints: BoxConstraints.tightFor(width: 56, height: 56),
      ),
    );
  }
}
