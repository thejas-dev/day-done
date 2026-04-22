import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/core/widgets/primary_button.dart';
import 'package:todo_tracker/core/widgets/text_link.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';
import 'package:todo_tracker/features/tasks/domain/task_model.dart';
import 'package:todo_tracker/features/tasks/domain/task_type.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_action_provider.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_providers.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/task_form_body.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/task_sheet_scaffold.dart';

part 'task_edit_screen.g.dart';

class TaskEditScreen extends ConsumerStatefulWidget {
  const TaskEditScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends ConsumerState<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  TaskModel? _original;
  DateTime? _date;
  Priority _priority = Priority.none;
  List<String> _labels = [];
  bool _initialized = false;
  bool _notesExpanded = false;

  void _initFrom(TaskModel task) {
    if (_initialized) return;
    _initialized = true;
    _original = task;
    _titleController.text = task.title;
    _notesController.text = task.notes ?? '';
    _date = task.date;
    _priority = task.priority;
    _labels = List.of(task.labels);
    _notesExpanded = (task.notes ?? '').trim().isNotEmpty;
  }

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
        .updateTask(
          id: widget.taskId,
          title: _titleController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          date: _original?.type == TaskType.dated ? _date : null,
          priority: _priority,
          labels: _labels,
          clearNotes: _notesController.text.trim().isEmpty,
          clearDate: _original?.type == TaskType.dated && _date == null,
        );

    ref.invalidate(taskByIdProvider(widget.taskId));
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

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorColor(Theme.of(ctx).brightness),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    await ref.read(taskActionsProvider.notifier).deleteTask(widget.taskId);
    ref.invalidate(taskByIdProvider(widget.taskId));
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final futureTask = ref.watch(taskByIdProvider(widget.taskId));

    return futureTask.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: Text('Error: $e')),
      ),
      data: (task) {
        if (task == null) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Text(
                'Task not found',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }
        _initFrom(task);
        final isLoading = ref.watch(taskActionsProvider).isLoading;

        final type = _original!.type;

        return TaskSheetScaffold(
          headerTitle: 'Edit Task',
          onClose: () => context.pop(),
          onSaveTap: _submit,
          saveEnabled: true,
          isLoading: isLoading,
          body: TaskFormBody(
            formKey: _formKey,
            titleController: _titleController,
            notesController: _notesController,
            type: type,
            onTypeChanged: (_) {},
            date: _date,
            onPickDate: _pickDate,
            showDateSection: type == TaskType.dated,
            showTypeToggle: false,
            priority: _priority,
            onPriorityChanged: (p) => setState(() => _priority = p),
            labels: _labels,
            onLabelsChanged: (l) => setState(() => _labels = l),
            notesExpanded: _notesExpanded,
            onNotesExpandedChanged: (v) => setState(() => _notesExpanded = v),
            autofocusTitle: false,
          ),
          bottom: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButtonDS(
                label: 'Save Task',
                onPressed: isLoading ? null : _submit,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextLinkDS(
                label: 'Delete Task',
                color: AppColors.errorColor(Theme.of(context).brightness),
                onTap: isLoading ? null : _confirmDelete,
              ),
            ],
          ),
        );
      },
    );
  }
}

@riverpod
Future<TaskModel?> taskById(Ref ref, String id) {
  return ref.watch(taskRepositoryProvider).getTaskById(id);
}
