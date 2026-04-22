import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/core/widgets/primary_button.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';
import 'package:todo_tracker/features/tasks/domain/task_type.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_action_provider.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/task_form_body.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/task_sheet_scaffold.dart';

class TaskCreateScreen extends ConsumerStatefulWidget {
  const TaskCreateScreen({super.key});

  @override
  ConsumerState<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends ConsumerState<TaskCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  TaskType _type = TaskType.dated;
  DateTime? _date;
  Priority _priority = Priority.none;
  List<String> _labels = [];
  bool _notesExpanded = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(taskActionsProvider.notifier)
        .createTask(
          title: _titleController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          type: _type,
          date: _type == TaskType.dated ? _date : null,
          priority: _priority,
          labels: _labels,
        );

    if (mounted) context.pop();
  }

  Future<void> _pickDate() async {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = isLight ? AppColors.primary : AppColors.primaryDark;
    final dialogBg = isLight
        ? AppColors.surfaceRaisedLight
        : AppColors.surfaceRaisedDark;
    final onSurface = isLight
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;
    final secondary = isLight
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        final base = Theme.of(context);
        return Theme(
          data: base.copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: dialogBg,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              headerForegroundColor: onSurface,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return isLight
                      ? AppColors.textOnAccentLight
                      : AppColors.textOnAccentDark;
                }
                return onSurface;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return primary;
                return null;
              }),
              todayForegroundColor: WidgetStateProperty.all(primary),
              todayBackgroundColor: WidgetStateProperty.all(
                primary.withValues(alpha: 0.18),
              ),
              yearForegroundColor: WidgetStateProperty.all(onSurface),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: secondary,
                minimumSize: const Size(64, 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                tapTargetSize: MaterialTapTargetSize.padded,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(taskActionsProvider).isLoading;

    return TaskSheetScaffold(
      headerTitle: 'New Task',
      onClose: () => context.pop(),
      onSaveTap: _submit,
      saveEnabled: true,
      isLoading: isLoading,
      body: TaskFormBody(
        formKey: _formKey,
        titleController: _titleController,
        notesController: _notesController,
        type: _type,
        onTypeChanged: (t) => setState(() => _type = t),
        date: _date,
        onPickDate: _pickDate,
        showDateSection: _type == TaskType.dated,
        showTypeToggle: true,
        priority: _priority,
        onPriorityChanged: (p) => setState(() => _priority = p),
        labels: _labels,
        onLabelsChanged: (l) => setState(() => _labels = l),
        notesExpanded: _notesExpanded,
        onNotesExpandedChanged: (v) => setState(() => _notesExpanded = v),
        autofocusTitle: true,
      ),
      bottom: PrimaryButtonDS(
        label: 'Save Task',
        onPressed: isLoading ? null : _submit,
      ),
    );
  }
}
