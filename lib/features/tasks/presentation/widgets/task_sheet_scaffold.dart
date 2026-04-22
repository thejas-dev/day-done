import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/core/theme/app_theme.dart';

/// Full-screen modal presentation — `styles.css` `.sheet`: **`--surface-raised`**,
/// header **14×16 padding**, title **18px / 700**, divider hairline.
class TaskSheetScaffold extends StatelessWidget {
  const TaskSheetScaffold({
    super.key,
    required this.headerTitle,
    required this.onClose,
    required this.onSaveTap,
    required this.saveEnabled,
    required this.body,
    required this.bottom,
    this.isLoading = false,
  });

  final String headerTitle;
  final VoidCallback onClose;
  final VoidCallback onSaveTap;
  final bool saveEnabled;
  final Widget body;
  final Widget bottom;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final sheetBg = isLight
        ? AppColors.surfaceRaisedLight
        : AppColors.surfaceRaisedDark;
    final primary = isLight ? AppColors.primary : AppColors.primaryDark;
    final divider = isLight ? AppColors.dividerLight : AppColors.dividerDark;
    final scrim = isLight ? AppColors.scrimLight : AppColors.scrimDark;
    final muted = isLight
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    final topInset = MediaQuery.paddingOf(context).top;
    final sheetHeight = MediaQuery.sizeOf(context).height - topInset;
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.pop(),
            child: Container(color: scrim),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: sheetHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.sheetTop),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: sheetBg,
                  boxShadow: isLight
                      ? AppTheme.sheetShadowLight
                      : AppTheme.sheetShadowDark,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 14, 8, 14),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: onClose,
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(foregroundColor: muted),
                          ),
                          Expanded(
                            child: Text(
                              headerTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: saveEnabled && !isLoading
                                ? onSaveTap
                                : null,
                            child: Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: divider),
                    Expanded(child: ClipRect(child: body)),
                    const SizedBox(height: 6),
                    Padding(
                      padding: EdgeInsets.only(
                        left: AppSpacing.lg,
                        right: AppSpacing.lg,
                        bottom: viewInsets + safeBottom + AppSpacing.sm,
                      ),
                      child: bottom,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
