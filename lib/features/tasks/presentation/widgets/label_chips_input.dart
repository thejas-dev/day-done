import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_tracker/core/constants/app_constants.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_providers.dart';

/// An input field that lets the user type and add label chips.
/// - Max [AppConstants.maxLabels] labels.
/// - Each label max [AppConstants.maxLabelChars] characters.
/// - Suggestions sourced from [distinctLabelsProvider] (case-insensitive prefix match).
/// - Duplicate labels (case-insensitive) are silently ignored.
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
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => _showSuggestions = false);
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
        .where((l) =>
            l.toLowerCase().startsWith(trimmed) &&
            !existing.contains(l.toLowerCase()))
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
    final allLabelsAsync = ref.watch(distinctLabelsProvider);
    final allLabels = allLabelsAsync.valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Existing chips
        if (widget.labels.isNotEmpty) ...[
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: widget.labels.map((label) {
              return Chip(
                label: Text(label),
                labelStyle: Theme.of(context).textTheme.labelMedium,
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () => _removeLabel(label),
                backgroundColor: brightness == Brightness.light
                    ? AppColors.surfaceVariantLight
                    : AppColors.surfaceVariantDark,
                side: BorderSide(
                  color: brightness == Brightness.light
                      ? AppColors.borderLight
                      : AppColors.borderDark,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Text input
        if (!_atLimit)
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLength: AppConstants.maxLabelChars,
            decoration: InputDecoration(
              hintText: 'Add label…',
              counterText: '',
              suffixIcon: _controller.text.trim().isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () => _addLabel(_controller.text),
                    )
                  : null,
            ),
            onChanged: (v) => _onTextChanged(v, allLabels),
            onSubmitted: _addLabel,
          )
        else
          Text(
            'Max ${AppConstants.maxLabels} labels reached',
            style: Theme.of(context).textTheme.bodySmall,
          ),

        // Suggestions dropdown
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.xs),
            decoration: BoxDecoration(
              color: brightness == Brightness.light
                  ? AppColors.surfaceLight
                  : AppColors.surfaceDark,
              border: Border.all(
                color: brightness == Brightness.light
                    ? AppColors.borderLight
                    : AppColors.borderDark,
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
                      child: Text(s,
                          style: Theme.of(context).textTheme.bodyMedium),
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
