import 'package:flutter/material.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/core/theme/app_theme.dart';

/// DayDone bottom sheet A — `styles.css` `.bsheet` + `build-slides.js` `sheetA_Snooze`.
Future<DateTime?> showSnoozePickerSheet(BuildContext context) {
  return showModalBottomSheet<DateTime>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => const _SnoozePickerSheet(),
  );
}

class _SnoozePickerSheet extends StatelessWidget {
  const _SnoozePickerSheet();

  static String _formatUntil(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute;
    final period = h >= 12 ? 'PM' : 'AM';
    final hh = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hh:${m.toString().padLeft(2, '0')} $period';
  }

  /// Next occurrence of [tod] strictly after [now] (today or tomorrow).
  static DateTime _combineNext(TimeOfDay tod, DateTime now) {
    var dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    if (!dt.isAfter(now)) {
      dt = dt.add(const Duration(days: 1));
    }
    return dt;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final sheetBg =
        isLight ? AppColors.surfaceRaisedLight : AppColors.surfaceRaisedDark;
    final secondary =
        isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark;
    final disabled =
        isLight ? AppColors.textDisabledLight : AppColors.textDisabledDark;

    final now = DateTime.now();
    final opt30 = now.add(const Duration(minutes: 30));
    final opt1h = now.add(const Duration(hours: 1));
    final opt2h = now.add(const Duration(hours: 2));

    final bottomInset = MediaQuery.paddingOf(context).bottom;

    Future<void> pickCustom() async {
      final tod = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          now.add(const Duration(hours: 1)),
        ),
      );
      if (!context.mounted || tod == null) return;
      final until = _combineNext(tod, DateTime.now());
      Navigator.pop(context, until);
    }

    Widget row({
      required IconData icon,
      required String title,
      String? subtitleRight,
      required VoidCallback onTap,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 22, color: secondary),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (subtitleRight != null)
                  Text(
                    subtitleRight,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: secondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            color: sheetBg,
            boxShadow: isLight
                ? AppTheme.sheetShadowLight
                : AppTheme.sheetShadowDark,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 4),
                      Center(
                        child: Opacity(
                          opacity: 0.5,
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: disabled,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                        child: Text(
                          'Snooze until…',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                row(
                  icon: Icons.timer_outlined,
                  title: '30 minutes',
                  subtitleRight: _formatUntil(opt30),
                  onTap: () => Navigator.pop(context, opt30),
                ),
                row(
                  icon: Icons.schedule,
                  title: '1 hour',
                  subtitleRight: _formatUntil(opt1h),
                  onTap: () => Navigator.pop(context, opt1h),
                ),
                row(
                  icon: Icons.nightlight_round,
                  title: '2 hours',
                  subtitleRight: _formatUntil(opt2h),
                  onTap: () => Navigator.pop(context, opt2h),
                ),
                row(
                  icon: Icons.edit_calendar_outlined,
                  title: 'Custom time…',
                  subtitleRight: null,
                  onTap: pickCustom,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                  child: Center(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
