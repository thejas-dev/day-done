import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_providers.dart';

/// A widget that observes [AppLifecycleState] and ensures today's daily
/// instances exist whenever the app is resumed from background.
///
/// Place this near the root of the widget tree (e.g., wrapping the shell).
/// It renders its [child] unchanged.
class DailyCatchupObserver extends ConsumerStatefulWidget {
  const DailyCatchupObserver({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DailyCatchupObserver> createState() =>
      _DailyCatchupObserverState();
}

class _DailyCatchupObserverState extends ConsumerState<DailyCatchupObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Also run on initial launch.
    _instantiateDailyTasks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _instantiateDailyTasks();
    }
  }

  Future<void> _instantiateDailyTasks() async {
    final repo = ref.read(taskRepositoryProvider);
    final today = DateTime.now();
    await repo.instantiateDailyTasks(today);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
