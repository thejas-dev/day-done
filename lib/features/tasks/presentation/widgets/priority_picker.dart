import 'package:flutter/material.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';

/// Priority pills — design ref `styles.css` `.priority-pill` (12px, 1.5px border,
/// filled active state with white label for Low–Urgent; None uses bg + outline).
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
    Priority.medium: 'Medium',
    Priority.high: 'High',
    Priority.urgent: 'Urgent',
  };

  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final divider = isLight ? AppColors.dividerLight : AppColors.dividerDark;
    final bg = isLight ? AppColors.backgroundLight : AppColors.backgroundDark;
    final secondary =
        isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark;
    final primaryText =
        isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark;
    final secondBorder =
        isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark;

    return Wrap(
      spacing: _gap,
      runSpacing: _gap,
      children: Priority.values.map((p) {
        final selected = p == value;
        final pc = AppColors.priorityColors(p, brightness);

        late Color borderC;
        late Color fg;
        Color? fill;

        if (p == Priority.none) {
          if (selected) {
            borderC = secondBorder;
            fg = primaryText;
            fill = bg;
          } else {
            borderC = divider;
            fg = secondary;
            fill = null;
          }
        } else {
          if (selected) {
            borderC = pc.border;
            fg = Colors.white;
            fill = pc.border;
          } else {
            borderC = pc.border;
            fg = pc.border;
            fill = null;
          }
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onChanged(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: fill ?? Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: borderC, width: 1.5),
              ),
              child: Text(
                _labels[p]!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: fg,
                      height: 1.2,
                    ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
