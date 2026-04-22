import 'package:flutter/material.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/core/widgets/chip_ds.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';
import 'package:todo_tracker/features/tasks/domain/today_task.dart';

/// Horizontally scrollable row of filter chips for priority levels and labels.
///
/// - AND logic across selected labels (task must have ALL selected labels).
/// - OR logic within priority selection (task must match ANY selected priority).
/// - Hidden when no tasks have a non-none priority or any labels.
///
/// Filter state is transient (local to this widget, not persisted).
class FilterChipBar extends StatefulWidget {
  const FilterChipBar({
    super.key,
    required this.tasks,
    required this.onFilterChanged,
  });

  /// Unfiltered list of today's tasks — used to derive available filters.
  final List<TodayTask> tasks;

  /// Called whenever the filter selection changes.
  final ValueChanged<TaskFilter> onFilterChanged;

  @override
  State<FilterChipBar> createState() => _FilterChipBarState();
}

class _FilterChipBarState extends State<FilterChipBar> {
  final Set<Priority> _selectedPriorities = {};
  final Set<String> _selectedLabels = {};

  @override
  Widget build(BuildContext context) {
    final availablePriorities = _availablePriorities();
    final availableLabels = _availableLabels();

    // Hidden when no tasks have a non-none priority or any labels.
    if (availablePriorities.isEmpty && availableLabels.isEmpty) {
      return const SizedBox.shrink();
    }

    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final allActive = _selectedPriorities.isEmpty && _selectedLabels.isEmpty;

    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          10,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChipDS(
              label: 'All',
              active: allActive,
              colors: isDark && !allActive
                  ? ChipDSColors(
                      background: Colors.transparent,
                      border: AppColors.chipBorderDark.withValues(alpha: 0.7),
                      foreground: AppColors.textSecondaryDark.withValues(
                        alpha: 0.9,
                      ),
                    )
                  : null,
              onTap: () {
                setState(() {
                  _selectedPriorities.clear();
                  _selectedLabels.clear();
                });
                _emitFilter();
              },
            ),
          ),
          for (final priority in availablePriorities)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _PriorityFilterChip(
                priority: priority,
                selected: _selectedPriorities.contains(priority),
                brightness: brightness,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedPriorities.add(priority);
                    } else {
                      _selectedPriorities.remove(priority);
                    }
                  });
                  _emitFilter();
                },
              ),
            ),

          if (availablePriorities.isNotEmpty && availableLabels.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Center(
                child: Container(
                  width: 1,
                  height: 20,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),

          for (final label in availableLabels)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _LabelFilterChip(
                label: label,
                selected: _selectedLabels.contains(label),
                brightness: brightness,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedLabels.add(label);
                    } else {
                      _selectedLabels.remove(label);
                    }
                  });
                  _emitFilter();
                },
              ),
            ),
        ],
      ),
    );
  }

  /// Returns non-none priorities present in today's tasks, sorted urgent-first.
  List<Priority> _availablePriorities() {
    final priorities = <Priority>{};
    for (final task in widget.tasks) {
      if (task.priority != Priority.none) {
        priorities.add(task.priority);
      }
    }
    final sorted = priorities.toList()
      ..sort((a, b) => b.index.compareTo(a.index));
    return sorted;
  }

  /// Returns distinct labels present in today's tasks, sorted alphabetically.
  List<String> _availableLabels() {
    final labels = <String>{};
    for (final task in widget.tasks) {
      labels.addAll(task.labels);
    }
    return labels.toList()..sort();
  }

  void _emitFilter() {
    widget.onFilterChanged(
      TaskFilter(
        priorities: Set.unmodifiable(_selectedPriorities),
        labels: Set.unmodifiable(_selectedLabels),
      ),
    );
  }
}

/// Immutable filter state.
class TaskFilter {
  final Set<Priority> priorities;
  final Set<String> labels;

  const TaskFilter({this.priorities = const {}, this.labels = const {}});

  bool get isEmpty => priorities.isEmpty && labels.isEmpty;

  /// Apply filter to a list of tasks.
  /// - OR within priorities: task matches ANY selected priority.
  /// - AND across labels: task must have ALL selected labels.
  List<TodayTask> apply(List<TodayTask> tasks) {
    if (isEmpty) return tasks;

    return tasks.where((task) {
      if (priorities.isNotEmpty && !priorities.contains(task.priority)) {
        return false;
      }

      if (labels.isNotEmpty) {
        for (final label in labels) {
          if (!task.labels.contains(label)) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }
}

class _PriorityFilterChip extends StatelessWidget {
  const _PriorityFilterChip({
    required this.priority,
    required this.selected,
    required this.brightness,
    required this.onSelected,
  });

  final Priority priority;
  final bool selected;
  final Brightness brightness;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.priorityColors(priority, brightness);
    final colors = selected
        ? ChipDSColors(
            background: c.badge,
            border: c.border,
            foreground: c.icon,
          )
        : null;

    return ChipDS(
      label: _priorityLabel(priority),
      active: selected,
      colors: colors,
      onTap: () => onSelected(!selected),
    );
  }

  static String _priorityLabel(Priority priority) => switch (priority) {
    Priority.none => 'None',
    Priority.low => 'Low',
    Priority.medium => 'Medium',
    Priority.high => 'High',
    Priority.urgent => 'Urgent',
  };
}

class _LabelFilterChip extends StatelessWidget {
  const _LabelFilterChip({
    required this.label,
    required this.selected,
    required this.brightness,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final Brightness brightness;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = brightness == Brightness.dark;
    return ChipDS(
      label: label,
      active: selected,
      colors: isDark && !selected
          ? ChipDSColors(
              background: Colors.transparent,
              border: AppColors.chipBorderDark.withValues(alpha: 0.7),
              foreground: AppColors.textSecondaryDark.withValues(alpha: 0.9),
            )
          : null,
      onTap: () => onSelected(!selected),
    );
  }
}
