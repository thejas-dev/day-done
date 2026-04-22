import 'package:flutter/material.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/core/theme/app_typography.dart';

/// Figma Today hero — layout per DayDone UI System (screens-today.jsx):
///
///   Row 1: [ datestamp / greeting ]  ............  [ countdown chip ] [ settings ]
///   Row 2: [ pending pill ]          ............................  [ X of Y done ]
///   Row 3: [ ================== progress bar ================== ]
class TodayHeader extends StatelessWidget {
  const TodayHeader({
    super.key,
    required this.dateLine,
    required this.greetingLine,
    required this.pendingCount,
    required this.totalCount,
    required this.resolvedCount,
    this.countdownLabel,
    this.countdownUrgency = TodayCountdownUrgency.calm,
    this.onSettings,
    this.celebrateAll = false,
  });

  final String dateLine;
  final String greetingLine;
  final int pendingCount;
  final int totalCount;
  final int resolvedCount;

  /// e.g. "4h 20m to bedtime"; null hides the countdown chip.
  final String? countdownLabel;

  /// Colours the countdown chip (Figma: calm / amber / red).
  final TodayCountdownUrgency countdownUrgency;

  final VoidCallback? onSettings;

  /// When every task for the day is resolved — hide metrics row (Figma empty success).
  final bool celebrateAll;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;

    final pendingIsUrgent =
        !celebrateAll &&
        pendingCount > 0 &&
        countdownUrgency == TodayCountdownUrgency.red;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        2,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLine,
                      style: AppTypography.todayDatestamp(brightness),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      greetingLine,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ],
                ),
              ),
              if (countdownLabel != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _CountdownChip(
                    label: countdownLabel!,
                    urgency: countdownUrgency,
                  ),
                ),
              ],
              if (onSettings != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 2),
                  child: IconButton(
                    onPressed: onSettings,
                    icon: const Icon(Icons.settings_outlined),
                    iconSize: 20,
                    color: isLight
                        ? AppColors.textSecondaryLight
                        : AppColors.textSecondaryDark,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 32,
                      height: 32,
                    ),
                  ),
                ),
            ],
          ),
          if (!celebrateAll && totalCount > 0) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                _PendingBadge(count: pendingCount, errorStyle: pendingIsUrgent),
                const Spacer(),
                Text(
                  '$resolvedCount of $totalCount done',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isLight
                        ? AppColors.textSecondaryLight
                        : AppColors.textSecondaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _DailyProgressBar(
              done: resolvedCount,
              total: totalCount,
              brightness: brightness,
            ),
          ],
        ],
      ),
    );
  }
}

enum TodayCountdownUrgency { calm, amber, red }

/// Pending pill — teal when calm, red when the countdown enters the "red" window.
/// Matches screens-today.jsx: `background: urgent ? t.error : t.primary`.
class _PendingBadge extends StatelessWidget {
  const _PendingBadge({required this.count, required this.errorStyle});

  final int count;
  final bool errorStyle;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final error = isLight ? AppColors.errorLight : AppColors.errorDark;
    final primary = isLight ? AppColors.primary : AppColors.primaryDark;
    final onAccent = isLight
        ? AppColors.textOnAccentLight
        : AppColors.textOnAccentDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: errorStyle ? error : primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count pending',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: errorStyle ? Colors.white : onAccent,
        ),
      ),
    );
  }
}

/// Countdown chip — placed on the top-right of the header.
/// Uses tinted background + border when urgent (Figma: `errorTint` + `error` border).
class _CountdownChip extends StatelessWidget {
  const _CountdownChip({required this.label, required this.urgency});

  final String label;
  final TodayCountdownUrgency urgency;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final warning = isLight ? AppColors.warningLight : AppColors.warningDark;
    final error = isLight ? AppColors.errorLight : AppColors.errorDark;
    final text = isLight
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

    late Color fg;
    late Color bg;
    Color? borderColor;
    switch (urgency) {
      case TodayCountdownUrgency.calm:
        fg = text;
        bg = isLight ? const Color(0xFFF0F1F3) : const Color(0xFF262626);
      case TodayCountdownUrgency.amber:
        fg = warning;
        bg = isLight ? AppColors.warningTintLight : AppColors.warningTintDark;
        borderColor = warning.withValues(alpha: 0.33);
      case TodayCountdownUrgency.red:
        fg = error;
        bg = isLight ? AppColors.errorTintLight : AppColors.errorTintDark;
        borderColor = error.withValues(alpha: 0.33);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyProgressBar extends StatelessWidget {
  const _DailyProgressBar({
    required this.done,
    required this.total,
    required this.brightness,
  });

  final int done;
  final int total;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final track = brightness == Brightness.light
        ? AppColors.dividerLight
        : AppColors.dividerDark;
    final fill = AppColors.successColor(brightness);
    final frac = total > 0 ? done / total : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 4,
        child: Stack(
          children: [
            Container(color: track),
            FractionallySizedBox(
              widthFactor: frac.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: fill,
                  boxShadow: brightness == Brightness.dark
                      ? [
                          BoxShadow(
                            color: fill.withValues(alpha: 0.55),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Copy-style greeting from local time (no profile name — add when accounts exist).
String greetingForHour(DateTime now) {
  final h = now.hour;
  if (h >= 5 && h < 12) return 'Good morning';
  if (h >= 12 && h < 17) return 'Good afternoon';
  if (h >= 17 && h < 22) return 'Good evening';
  return 'Good evening';
}

/// "Sunday, Apr 19" — long-form date per design (was short-caps previously).
String formatTodayDatestamp(DateTime date) {
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final wd = days[date.weekday - 1];
  final m = months[date.month - 1];
  final d = date.day;
  return '$wd, $m $d';
}
