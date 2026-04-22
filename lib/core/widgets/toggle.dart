import 'package:flutter/material.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';

/// 40×24 pill toggle — design ref `primitives.jsx:290 Toggle`.
///
/// Uses Material's gesture/animation primitives directly rather than
/// `Switch`, since `Switch` can't render this exact 40×24 footprint.
class ToggleDS extends StatelessWidget {
  const ToggleDS({
    super.key,
    required this.value,
    this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final on = value;
    final disabled = onChanged == null;

    final trackOn = isLight ? AppColors.primary : AppColors.primaryDark;
    final trackOff =
        isLight ? const Color(0xFFD0D4D9) : const Color(0xFF3A3A3A);

    return GestureDetector(
      onTap: disabled ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        width: 40,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: on ? trackOn : trackOff,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment:
              on ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: const [
            _Knob(),
          ],
        ),
      ),
    );
  }
}

class _Knob extends StatelessWidget {
  const _Knob();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
