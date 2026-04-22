import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_tracker/core/constants/app_constants.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/core/widgets/chip_ds.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_providers.dart';

/// Labels row — `styles.css` `.filter-chip` / `.filter-chip.active`; **+ Add label**
/// matches outlined chip (`btn-secondary`-style outline).
class LabelChipsInput extends ConsumerStatefulWidget {
  const LabelChipsInput({
    super.key,
    required this.labels,
    required this.onChanged,
  });

  final List<String> labels;
  final ValueChanged<List<String>> onChanged;

  @override
  ConsumerState<LabelChipsInput> createState() => _LabelChipsInputState();
}

class _LabelChipsInputState extends ConsumerState<LabelChipsInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => _showSuggestions = false);
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _atLimit => widget.labels.length >= AppConstants.maxLabels;

  void _onTextChanged(String value, List<String> allLabels) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final existing = widget.labels.map((l) => l.toLowerCase()).toSet();
    final matches = allLabels
        .where(
          (l) =>
              l.toLowerCase().startsWith(trimmed) &&
              !existing.contains(l.toLowerCase()),
        )
        .toList();

    setState(() {
      _suggestions = matches;
      _showSuggestions = matches.isNotEmpty;
    });
  }

  void _addLabel(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    if (trimmed.length > AppConstants.maxLabelChars) return;
    if (_atLimit) return;

    final lower = trimmed.toLowerCase();
    if (widget.labels.any((l) => l.toLowerCase() == lower)) return;

    widget.onChanged([...widget.labels, trimmed]);
    _controller.clear();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
  }

  void _removeLabel(String label) {
    widget.onChanged(widget.labels.where((l) => l != label).toList());
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final theme = Theme.of(context);
    final isLight = brightness == Brightness.light;
    final primary =
        isLight ? AppColors.primary : AppColors.primaryDark;
    final pcBg =
        isLight ? AppColors.primaryContainer : AppColors.primaryContainerDark;

    final allLabelsAsync = ref.watch(distinctLabelsProvider);
    final allLabels = allLabelsAsync.valueOrNull ?? [];

    final activeChipColors = ChipDSColors(
      background: pcBg,
      border: primary,
      foreground: primary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...widget.labels.map((label) {
              return ChipDS(
                label: label,
                active: true,
                colors: activeChipColors,
                trailing: InkWell(
                  onTap: () => _removeLabel(label),
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '×',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),
                  ),
                ),
              );
            }),
            if (!_atLimit) ...[
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _focusNode.requestFocus(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primary, width: 1),
                    ),
                    child: Text(
                      '+ Add label',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),

        if (!_atLimit) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLength: AppConstants.maxLabelChars,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Type a label, then tap + or Enter',
              hintStyle: theme.textTheme.bodySmall?.copyWith(
                color: isLight
                    ? AppColors.textSecondaryLight
                    : AppColors.textSecondaryDark,
              ),
              counterText: '',
              suffixIcon: _controller.text.trim().isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.add_circle_outline, color: primary),
                      onPressed: () => _addLabel(_controller.text),
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isLight
                      ? AppColors.dividerLight
                      : AppColors.dividerDark,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isLight
                      ? AppColors.dividerLight
                      : AppColors.dividerDark,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: primary, width: 1.5),
              ),
            ),
            onChanged: (v) => _onTextChanged(v, allLabels),
            onSubmitted: _addLabel,
          ),
        ]
        else
          Text(
            'Max ${AppConstants.maxLabels} labels reached',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isLight
                  ? AppColors.textSecondaryLight
                  : AppColors.textSecondaryDark,
            ),
          ),

        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.xs),
            decoration: BoxDecoration(
              color: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
              border: Border.all(
                color: isLight ? AppColors.borderLight : AppColors.borderDark,
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _suggestions.map((s) {
                return InkWell(
                  onTap: () => _addLabel(s),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(s, style: theme.textTheme.bodyMedium),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
