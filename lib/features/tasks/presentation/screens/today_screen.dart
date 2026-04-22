import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/core/widgets/section_header.dart';
import 'package:todo_tracker/core/utils/bedtime_utils.dart';
import 'package:todo_tracker/features/settings/presentation/providers/settings_provider.dart';
import 'package:todo_tracker/features/tasks/domain/task_status.dart';
import 'package:todo_tracker/features/tasks/domain/today_task.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/today_summary_provider.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/today_tasks_provider.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/filter_chip_bar.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/task_tile.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/today_header.dart';

/// Today view — Figma "Today" frames: hero header, optional urgent banner, grouped tasks.
/// The create-task FAB is owned by the tab shell (`lib/routing/app_router.dart`).
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  TaskFilter _filter = const TaskFilter();

  @override
  Widget build(BuildContext context) {
    final todayTasksAsync = ref.watch(todayTasksProvider);
    final summary = ref.watch(todaySummaryProvider);
    final settingsAsync = ref.watch(settingsStreamProvider);
    final now = DateTime.now();

    return todayTasksAsync.when(
      data: (tasks) {
        DateTime? nextBed;
        Duration? untilBed;
        if (settingsAsync.hasValue) {
          nextBed = nextBedtimeOccurrence(
            now,
            settingsAsync.requireValue.bedtime,
          );
          if (nextBed != null) {
            untilBed = nextBed.difference(now);
          }
        }

        var urgency = TodayCountdownUrgency.calm;
        if (untilBed != null) {
          if (untilBed.inMinutes <= 45) {
            urgency = TodayCountdownUrgency.red;
          } else if (untilBed.inMinutes <= 120) {
            urgency = TodayCountdownUrgency.amber;
          }
        }

        final eveningAccent =
            summary.pending > 0 && untilBed != null && untilBed.inMinutes <= 45;

        final celebration =
            summary.total > 0 && summary.pending == 0 && summary.snoozed == 0;

        final resolved = summary.done + summary.closed;

        String? countdownLabel;
        if (!celebration && summary.total > 0 && untilBed != null) {
          countdownLabel = '${formatDurationCompact(untilBed)} to bedtime';
        }

        if (celebration) {
          final bottomInset =
              MediaQuery.paddingOf(context).bottom +
              68 +
              28 +
              56 +
              AppSpacing.md;
          return Scaffold(
            extendBody: true,
            body: SafeArea(
              top: true,
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AllDoneHeader(now: now),
                    const Expanded(child: _AllDoneCelebration()),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          extendBody: true,
          body: SafeArea(
            top: true,
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: settingsAsync.when(
                    data: (_) => TodayHeader(
                      dateLine: formatTodayDatestamp(now),
                      greetingLine: celebration
                          ? 'All done for today.'
                          : greetingForHour(now),
                      pendingCount: summary.pending,
                      totalCount: summary.total,
                      resolvedCount: resolved,
                      countdownLabel: countdownLabel,
                      countdownUrgency: urgency,
                      celebrateAll: celebration,
                      onSettings: null,
                    ),
                    loading: () => const SizedBox(height: 120),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ),
                if (eveningAccent)
                  SliverToBoxAdapter(
                    child: _UrgentBanner(
                      minutesRemaining: untilBed.inMinutes,
                      pending: summary.pending,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: FilterChipBar(
                    tasks: tasks,
                    onFilterChanged: (filter) {
                      setState(() => _filter = filter);
                    },
                  ),
                ),
                ..._buildTaskSections(context, tasks, eveningAccent),
                SliverPadding(
                  padding: EdgeInsets.only(
                    bottom:
                        MediaQuery.paddingOf(context).bottom +
                        68 +
                        28 +
                        56 +
                        AppSpacing.md,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Failed to load tasks: $error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTaskSections(
    BuildContext context,
    List<TodayTask> allTasks,
    bool eveningAccent,
  ) {
    if (allTasks.isEmpty) {
      return const [
        SliverFillRemaining(hasScrollBody: false, child: _TodayEmpty()),
      ];
    }

    final filtered = _filter.apply(allTasks);

    final pending = filtered
        .where((t) => t.status == TaskStatus.pending)
        .toList();
    final snoozed = filtered
        .where((t) => t.status == TaskStatus.snoozed)
        .toList();
    final done = filtered.where((t) => t.status == TaskStatus.done).toList();
    final closed = filtered
        .where((t) => t.status == TaskStatus.closed)
        .toList();

    final slivers = <Widget>[];

    if (pending.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: SectionHeaderDS(label: 'Pending · ${pending.length}'),
        ),
      );
      slivers.add(
        _TaskSliverList(tasks: pending, eveningAccent: eveningAccent),
      );
    }
    if (snoozed.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: SectionHeaderDS(label: 'Snoozed · ${snoozed.length}'),
        ),
      );
      slivers.add(
        _TaskSliverList(tasks: snoozed, eveningAccent: eveningAccent),
      );
    }
    if (done.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: SectionHeaderDS(label: 'Done · ${done.length}'),
        ),
      );
      slivers.add(_TaskSliverList(tasks: done, eveningAccent: eveningAccent));
    }
    if (closed.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: SectionHeaderDS(label: 'Closed · ${closed.length}'),
        ),
      );
      slivers.add(_TaskSliverList(tasks: closed, eveningAccent: eveningAccent));
    }

    if (filtered.isEmpty && allTasks.isNotEmpty) {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_alt_off_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No tasks match current filters',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return slivers;
  }
}

/// Urgent pre-bedtime banner — Figma `TodayUrgent`:
/// tinted background + error border + bold error-coloured copy (softer than solid red).
class _UrgentBanner extends StatelessWidget {
  const _UrgentBanner({required this.minutesRemaining, required this.pending});

  final int minutesRemaining;
  final int pending;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final error = AppColors.errorColor(brightness);
    final tint = isLight ? AppColors.errorTintLight : AppColors.errorTintDark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: error.withValues(alpha: 0.33)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: error, size: 20),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Text(
                '$minutesRemaining minutes until bedtime — $pending task${pending == 1 ? '' : 's'} remaining',
                style: TextStyle(
                  color: error,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "All done for today" screen — Figma `TodayEmpty` (not the zero-tasks case,
/// but the celebrate-everything-resolved case).
///
/// Large successTint circle with a check, display-size title, subtitle.
/// Streak pill is omitted in Phase 1 (streaks ship in Phase 2).
class _AllDoneCelebration extends StatefulWidget {
  const _AllDoneCelebration();

  @override
  State<_AllDoneCelebration> createState() => _AllDoneCelebrationState();
}

class _AllDoneCelebrationState extends State<_AllDoneCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final success = AppColors.successColor(brightness);
    final secondary = brightness == Brightness.light
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl3,
          0,
          AppSpacing.xl3,
          AppSpacing.xl3,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _pulseScale,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: success.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.task_alt, size: 56, color: success),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'All clear.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 30,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Great work. All tasks resolved before bedtime.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: secondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AllDoneHeader extends StatelessWidget {
  const _AllDoneHeader({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryText = isLight
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;
    final secondary = isLight
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 2, AppSpacing.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatAllDoneDatestamp(now),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: secondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'All done for today.',
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(color: primaryText),
          ),
          const SizedBox(height: 6),
          Text(
            'Enjoy your evening.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: secondary),
          ),
        ],
      ),
    );
  }

  static String _formatAllDoneDatestamp(DateTime date) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${days[date.weekday - 1]} · ${months[date.month - 1]} ${date.day}';
  }
}

/// "Your day is empty" — Figma `TodayFirstTime`. Shown when zero tasks exist for today.
class _TodayEmpty extends StatelessWidget {
  const _TodayEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt,
              size: 96,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 22),
            Text(
              'Your day is empty',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(
                'Add your first task using the + button below.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),
            Column(
              children: [
                Container(
                  width: 2,
                  height: 40,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 6),
                Icon(
                  Icons.arrow_downward_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskSliverList extends StatelessWidget {
  const _TaskSliverList({required this.tasks, required this.eveningAccent});

  final List<TodayTask> tasks;
  final bool eveningAccent;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) =>
          TaskTile(task: tasks[index], eveningUrgencyActive: eveningAccent),
    );
  }
}
