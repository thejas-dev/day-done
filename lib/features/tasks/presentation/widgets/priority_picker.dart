import 'package:flutter/material.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';

/// A 5-segment horizontal control for selecting [Priority].
/// Fires [onChanged] when the user taps a segment.
class PriorityPicker extends StatelessWidget {
  const PriorityPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Priority value;
  final ValueChanged<Priority> onChanged;

  static const _labels = {
    Priority.none: 'None',
    Priority.low: 'Low',
    Priority.medium: 'Med',
    Priority.high: 'High',
    Priority.urgent: 'Urgent',
  };

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      children: Priority.values.map((p) {
        final selected = p == value;
        final colors = AppColors.priorityColors(p, brightness);
        final borderColor = p == Priority.none
            ? (brightness == Brightness.light
                ? AppColors.borderLight
                : AppColors.borderDark)
            : colors.border;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 36,
                decoration: BoxDecoration(
                  color: selected
                      ? (p == Priority.none
                          ? (brightness == Brightness.light
                              ? AppColors.surfaceVariantLight
                              : AppColors.surfaceVariantDark)
                          : colors.badge)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected ? borderColor : borderColor.withValues(alpha: 0.4),
                    width: selected ? 1.5 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: Text(
                  _labels[p]!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: selected
                            ? (p == Priority.none
                                ? (brightness == Brightness.light
                                    ? AppColors.textSecondaryLight
                                    : AppColors.textSecondaryDark)
                                : colors.icon)
                            : (brightness == Brightness.light
                                ? AppColors.textMutedLight
                                : AppColors.textMutedDark),
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
