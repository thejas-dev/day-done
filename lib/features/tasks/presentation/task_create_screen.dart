import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_tracker/core/constants/app_constants.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';
import 'package:todo_tracker/features/tasks/domain/task_type.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_action_provider.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/label_chips_input.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/priority_picker.dart';

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

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(taskActionsProvider.notifier).createTask(
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(taskActionsProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _submit,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              maxLength: AppConstants.maxTitleChars,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'What do you need to do?',
              ),
              autofocus: true,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Title is required';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Task type toggle
            Row(
              children: [
                Text('Type', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: AppSpacing.lg),
                ChoiceChip(
                  label: const Text('One-time'),
                  selected: _type == TaskType.dated,
                  onSelected: (_) => setState(() => _type = TaskType.dated),
                ),
                const SizedBox(width: AppSpacing.sm),
                ChoiceChip(
                  label: const Text('Daily'),
                  selected: _type == TaskType.daily,
                  onSelected: (_) => setState(() => _type = TaskType.daily),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Date picker (dated only)
            if (_type == TaskType.dated) ...[
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due date',
                    suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                  child: Text(
                    _date == null
                        ? 'No date (backlog)'
                        : '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _date == null
                              ? (Theme.of(context).brightness ==
                                      Brightness.light
                                  ? AppColors.textMutedLight
                                  : AppColors.textMutedDark)
                              : null,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Priority
            Text('Priority', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            PriorityPicker(
              value: _priority,
              onChanged: (p) => setState(() => _priority = p),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Labels
            Text('Labels', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            LabelChipsInput(
              labels: _labels,
              onChanged: (l) => setState(() => _labels = l),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLength: AppConstants.maxNotesChars,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Optional notes…',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
