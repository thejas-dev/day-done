import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/core/theme/app_theme.dart';
import 'package:todo_tracker/core/theme/app_typography.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';
import 'package:todo_tracker/features/tasks/domain/task_status.dart';
import 'package:todo_tracker/features/tasks/domain/today_task.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/task_action_sheet.dart';

/// Task row — design ref `primitives.jsx:170 TaskTile`.
///
/// Layout: shadow + radius only (no outline border), 4px absolute-positioned
/// priority stripe on the leading edge, 20px left padding to clear it. Urgent
/// pre-bedtime tiles get a flat `urgentTileTint` background plus a 13%-alpha
/// `pUrgent` border (= the design's `pUrgent22` token).
class TaskTile extends ConsumerWidget {
  const TaskTile({
    super.key,
    required this.task,
    this.eveningUrgencyActive = false,
    this.overdue = false,
  });

  final TodayTask task;

  /// When true and we're in the pre-bedtime "push" window, urgent/high tiles
  /// get the flat urgent wash (`screens-today.jsx:108 urgentTint` prop).
  final bool eveningUrgencyActive;

  /// Renders the "From yesterday" pill before the title.
  final bool overdue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final isStrike =
        task.status == TaskStatus.done || task.status == TaskStatus.closed;
    final isSnoozed = task.status == TaskStatus.snoozed;
    final hasSecondaryContent =
        task.labels.isNotEmpty ||
        (task.status == TaskStatus.snoozed && task.snoozeUntil != null);

    final urgentWash =
        eveningUrgencyActive &&
        task.status == TaskStatus.pending &&
        (task.priority == Priority.urgent || task.priority == Priority.high);

    final tileBg = urgentWash
        ? (isLight
              ? AppColors.urgentTileTintLight
              : AppColors.urgentTileTintDark)
        : (Theme.of(context).cardTheme.color ??
              (isLight ? AppColors.surfaceLight : AppColors.surfaceDark));

    final urgentColor = isLight
        ? AppColors.priorityUrgentLight
        : AppColors.priorityUrgentDark;

    Widget tile = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: () => showTaskActionSheet(context, task),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 5, // 10px between tiles per design
          ),
          decoration: BoxDecoration(
            color: tileBg,
            borderRadius: AppRadius.mdAll,
            boxShadow: AppTheme.cardShadow(brightness),
            border: urgentWash
                ? Border.all(
                    color: urgentColor.withValues(alpha: 0.13),
                    width: 1,
                  )
                : null,
          ),
          child: Stack(
            children: [
              if (task.priority != Priority.none)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: kPriorityStripWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.priorityColor(
                        task.priority,
                        brightness,
                      ).withValues(alpha: (isStrike || isSnoozed) ? 0.35 : 1.0),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.md),
                        bottomLeft: Radius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                child: Row(
                  crossAxisAlignment: hasSecondaryContent
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: hasSecondaryContent ? 2 : 0,
                      ),
                      child: _LeadingCheckbox(
                        status: task.status,
                        brightness: brightness,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _TileBody(
                        task: task,
                        brightness: brightness,
                        overdue: overdue,
                        parentContext: context,
                        hasSecondaryContent: hasSecondaryContent,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: hasSecondaryContent ? 4 : 0,
                      ),
                      child: _ActionIcons(
                        status: task.status,
                        brightness: brightness,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (isSnoozed) {
      tile = Opacity(opacity: 0.75, child: tile);
    }
    return tile;
  }
}

class _TileBody extends StatelessWidget {
  const _TileBody({
    required this.task,
    required this.brightness,
    required this.overdue,
    required this.parentContext,
    required this.hasSecondaryContent,
  });

  final TodayTask task;
  final Brightness brightness;
  final bool overdue;
  final BuildContext parentContext;
  final bool hasSecondaryContent;

  @override
  Widget build(BuildContext context) {
    final isStrike =
        task.status == TaskStatus.done || task.status == TaskStatus.closed;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: hasSecondaryContent
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (overdue && !isStrike) ...[
              _OverduePill(brightness: brightness),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                task.title,
                style: _titleStyle(brightness),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (task.labels.isNotEmpty) ...[
          const SizedBox(height: 8),
          _LabelChipsRow(labels: task.labels, brightness: brightness),
        ],
        if (task.status == TaskStatus.snoozed && task.snoozeUntil != null) ...[
          const SizedBox(height: 6),
          _SnoozedLine(
            until: task.snoozeUntil!,
            brightness: brightness,
            parentContext: parentContext,
          ),
        ],
      ],
    );
  }

  TextStyle _titleStyle(Brightness brightness) {
    if (task.status == TaskStatus.done || task.status == TaskStatus.closed) {
      return AppTypography.doneTaskTitle(brightness);
    }
    if (task.priority == Priority.urgent) {
      return AppTypography.tileTitleUrgent(brightness);
    }
    return AppTypography.tileTitle(brightness);
  }
}

class _ActionIcons extends StatelessWidget {
  const _ActionIcons({required this.status, required this.brightness});

  final TaskStatus status;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final isStrike = status == TaskStatus.done || status == TaskStatus.closed;
    final isSnoozed = status == TaskStatus.snoozed;
    final color = brightness == Brightness.light
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isStrike && !isSnoozed) ...[
          Icon(Icons.snooze_outlined, size: 18, color: color),
          const SizedBox(width: 4),
        ],
        Icon(Icons.more_vert, size: 18, color: color),
      ],
    );
  }
}

class _OverduePill extends StatelessWidget {
  const _OverduePill({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final isLight = brightness == Brightness.light;
    final bg = isLight ? AppColors.errorTintLight : AppColors.errorTintDark;
    final fg = AppColors.errorColor(brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'From yesterday',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: fg,
        ),
      ),
    );
  }
}

class _LeadingCheckbox extends StatelessWidget {
  const _LeadingCheckbox({required this.status, required this.brightness});

  final TaskStatus status;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).colorScheme.onSurfaceVariant;
    switch (status) {
      case TaskStatus.pending:
      case TaskStatus.snoozed:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 1.5),
          ),
        );
      case TaskStatus.done:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.successColor(brightness),
          ),
          child: const Icon(Icons.check, size: 14, color: Colors.white),
        );
      case TaskStatus.closed:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: brightness == Brightness.light
                ? AppColors.textDisabledLight
                : AppColors.textDisabledDark,
          ),
          child: Icon(
            Icons.close,
            size: 14,
            color: Theme.of(context).cardTheme.color,
          ),
        );
    }
  }
}

class _LabelChipsRow extends StatelessWidget {
  const _LabelChipsRow({required this.labels, required this.brightness});

  final List<String> labels;
  final Brightness brightness;

  static const int _maxVisible = 3;

  @override
  Widget build(BuildContext context) {
    final visible = labels.take(_maxVisible).toList();
    final overflow = labels.length - _maxVisible;
    final isLight = brightness == Brightness.light;
    final bg = isLight ? AppColors.labelChipBgLight : AppColors.labelChipBgDark;
    final fg = isLight
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final label in visible)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (overflow > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Text(
              '+$overflow',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ),
      ],
    );
  }
}

class _SnoozedLine extends StatelessWidget {
  const _SnoozedLine({
    required this.until,
    required this.brightness,
    required this.parentContext,
  });

  final DateTime until;
  final Brightness brightness;
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(until).format(parentContext);
    final info = AppColors.infoColor(brightness);
    return Row(
      children: [
        Icon(Icons.schedule, size: 12, color: info),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            'Snoozed until $time',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: info,
            ),
          ),
        ),
      ],
    );
  }
}
