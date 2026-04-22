import 'package:flutter/material.dart';
import 'package:todo_tracker/core/constants/app_constants.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/core/theme/app_theme.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';
import 'package:todo_tracker/features/tasks/domain/task_type.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/label_chips_input.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/priority_picker.dart';

/// Design tokens: `styles.css` `.sheet-body` gap **18px**, `.field-label`,
/// `.input-line`, `.segmented`, `.priority-pill`, `.filter-chip`.
const double _kSheetSectionGap = 18;
const double _kFieldLabelGap = 8;

/// Scrollable fields for task create/edit — matches DayDone task-create sheet HTML.
class TaskFormBody extends StatelessWidget {
  const TaskFormBody({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.notesController,
    required this.type,
    required this.onTypeChanged,
    required this.date,
    required this.onPickDate,
    required this.showDateSection,
    required this.showTypeToggle,
    required this.priority,
    required this.onPriorityChanged,
    required this.labels,
    required this.onLabelsChanged,
    required this.notesExpanded,
    required this.onNotesExpandedChanged,
    this.autofocusTitle = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController notesController;

  final TaskType type;
  final ValueChanged<TaskType> onTypeChanged;
  final DateTime? date;
  final VoidCallback onPickDate;
  final bool showDateSection;
  final bool showTypeToggle;

  final Priority priority;
  final ValueChanged<Priority> onPriorityChanged;

  final List<String> labels;
  final ValueChanged<List<String>> onLabelsChanged;

  final bool notesExpanded;
  final ValueChanged<bool> onNotesExpandedChanged;

  final bool autofocusTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primary = isLight ? AppColors.primary : AppColors.primaryDark;
    final disabled = isLight
        ? AppColors.textDisabledLight
        : AppColors.textDisabledDark;
    final secondary = isLight
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    /// `.input-line` — 20px / w500, underline **1.5px** primary.
    final inputLineStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      height: 1.35,
      color: theme.colorScheme.onSurface,
    );

    final underlineEnabled = UnderlineInputBorder(
      borderSide: BorderSide(color: primary, width: 1.5),
    );

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TITLE + counter (same row as `.field-label` row in spec)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(text: 'Title'),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: titleController,
                  builder: (context, value, _) {
                    final n = value.text.characters.length;
                    return Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '$n / ${AppConstants.maxTitleChars}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: disabled,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: _kFieldLabelGap),
            TextFormField(
              controller: titleController,
              autofocus: autofocusTitle,
              maxLength: AppConstants.maxTitleChars,
              style: inputLineStyle,
              decoration: InputDecoration(
                hintText: 'What do you need to do?',
                hintStyle: inputLineStyle.copyWith(
                  color: disabled,
                  fontWeight: FontWeight.w400,
                ),
                counterText: '',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: underlineEnabled,
                enabledBorder: underlineEnabled,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: primary, width: 1.5),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.errorColor(theme.brightness),
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.errorColor(theme.brightness),
                    width: 1.5,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: _kSheetSectionGap),

            if (showTypeToggle) ...[
              _SegmentedTaskTypeToggle(type: type, onChanged: onTypeChanged),
              const SizedBox(height: _kSheetSectionGap),
            ],

            if (showDateSection) ...[
              _FieldLabel(text: 'Due date'),
              SizedBox(height: _kFieldLabelGap),
              InkWell(
                onTap: onPickDate,
                borderRadius: AppRadius.smAll,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isLight
                        ? AppColors.backgroundLight
                        : AppColors.backgroundDark,
                    borderRadius: AppRadius.smAll,
                    border: Border.all(
                      color: isLight
                          ? AppColors.dividerLight
                          : AppColors.dividerDark,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          date == null
                              ? 'No date (backlog)'
                              : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: date == null
                                ? secondary
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 20,
                        color: secondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: _kSheetSectionGap),
            ],

            _FieldLabel(text: 'Priority'),
            SizedBox(height: _kFieldLabelGap),
            PriorityPicker(value: priority, onChanged: onPriorityChanged),
            const SizedBox(height: _kSheetSectionGap),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(text: 'Labels'),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '${labels.length} / ${AppConstants.maxLabels}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: disabled,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: _kFieldLabelGap),
            LabelChipsInput(labels: labels, onChanged: onLabelsChanged),

            const SizedBox(height: _kSheetSectionGap),

            _FieldLabel(text: 'Notes'),
            SizedBox(height: _kFieldLabelGap),
            _NotesCollapsible(
              expanded: notesExpanded,
              onExpandedChanged: onNotesExpandedChanged,
              controller: notesController,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

/// `.field-label` — 11px, w600, uppercase, letter-spacing ~0.1em, secondary.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).brightness == Brightness.light
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        height: 1.25,
        color: secondary,
      ),
    );
  }
}

/// `build-slides.js` segmented: `.segmented` uses `--bg` track + border; **refresh** +
/// **event** icons (not emoji).
class _SegmentedTaskTypeToggle extends StatelessWidget {
  const _SegmentedTaskTypeToggle({required this.type, required this.onChanged});

  final TaskType type;
  final ValueChanged<TaskType> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final track = isLight
        ? AppColors.backgroundLight
        : AppColors.backgroundDark;
    final divider = isLight ? AppColors.dividerLight : AppColors.dividerDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(text: 'Type'),
        SizedBox(height: _kFieldLabelGap),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: track,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: divider),
          ),
          child: Row(
            children: [
              Expanded(
                child: _TypeSegment(
                  icon: Icons.refresh_rounded,
                  label: 'Daily',
                  selected: type == TaskType.daily,
                  onTap: () => onChanged(TaskType.daily),
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: _TypeSegment(
                  icon: Icons.event_rounded,
                  label: 'One-time',
                  selected: type == TaskType.dated,
                  onTap: () => onChanged(TaskType.dated),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TypeSegment extends StatelessWidget {
  const _TypeSegment({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final fg = theme.colorScheme.onSurface;
    final muted = isLight
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: selected
            ? (isLight ? AppColors.surfaceLight : AppColors.surfaceDark)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: selected
            ? (isLight ? AppTheme.tileShadowLight : AppTheme.tileShadowDark)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: selected ? fg : muted),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? fg : muted,
            ),
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: child,
      ),
    );
  }
}

/// Collapsible notes — body uses `.input-box` treatment when expanded.
class _NotesCollapsible extends StatelessWidget {
  const _NotesCollapsible({
    required this.expanded,
    required this.onExpandedChanged,
    required this.controller,
    required this.theme,
  });

  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final TextEditingController controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final secondary = theme.brightness == Brightness.light
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          borderRadius: AppRadius.smAll,
          onTap: () => onExpandedChanged(!expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: secondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    expanded ? 'Hide notes' : 'Add optional notes',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            maxLength: AppConstants.maxNotesChars,
            maxLines: 5,
            minLines: 3,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Optional notes…',
              filled: true,
              fillColor: theme.brightness == Brightness.light
                  ? AppColors.backgroundLight
                  : AppColors.backgroundDark,
              border: OutlineInputBorder(
                borderRadius: AppRadius.smAll,
                borderSide: BorderSide(
                  color: theme.brightness == Brightness.light
                      ? AppColors.dividerLight
                      : AppColors.dividerDark,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.smAll,
                borderSide: BorderSide(
                  color: theme.brightness == Brightness.light
                      ? AppColors.dividerLight
                      : AppColors.dividerDark,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.smAll,
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
              counterStyle: TextStyle(fontSize: 11, color: secondary),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
