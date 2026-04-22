import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_tracker/core/constants/route_constants.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/core/utils/date_utils.dart';
import 'package:todo_tracker/core/widgets/progress_bar.dart';
import 'package:todo_tracker/features/resolution/providers/resolution_provider.dart';
import 'package:todo_tracker/features/settings/presentation/providers/settings_provider.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';
import 'package:todo_tracker/features/tasks/domain/today_task.dart';

/// Navigates after the current frame so [GoRouter] / element tree are stable
/// (avoids `_elements.contains(element)` during inherited widget updates).
void _deferNavigateToToday(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    context.go(RouteConstants.today);
  });
}

/// End-of-day resolution — `docs/design/build-slides.js` `sheetD_EndOfDay` +
/// `styles.css` `.eod-row` / `.eod-actions` / `.eod-btn`.
///
/// Blocks back via [PopScope]; primary exit is **All done** when every task
/// has been acted on.
class ResolutionScreen extends ConsumerStatefulWidget {
  const ResolutionScreen({super.key});

  @override
  ConsumerState<ResolutionScreen> createState() => _ResolutionScreenState();
}

class _ResolutionScreenState extends ConsumerState<ResolutionScreen> {
  /// Optimistic ids — reconciles with provider refreshes.
  final Set<String> _resolvedIds = {};

  /// Avoid queueing multiple [addPostFrameCallback] navigations while empty.
  bool _scheduledEmptyExit = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final settingsAsync = ref.watch(settingsStreamProvider);

    final date = settingsAsync.whenOrNull(
      data: (settings) => resolveLogicalDate(
        now,
        settings.bedtime.hour,
        settings.bedtime.minute,
      ),
    );

    final resolveDate = date ??
        DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 1));

    final unresolvedAsync = ref.watch(unresolvedTasksProvider(resolveDate));

    final isLight = Theme.of(context).brightness == Brightness.light;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor:
            isLight ? AppColors.backgroundLight : AppColors.backgroundDark,
        body: unresolvedAsync.when(
          data: (tasks) {
            if (tasks.isNotEmpty) {
              _scheduledEmptyExit = false;
            }

            final remaining =
                tasks.where((t) => !_resolvedIds.contains(t.id)).toList();
            final resolved = _resolvedIds.length;
            final total = resolved + remaining.length;

            if (tasks.isEmpty && _resolvedIds.isEmpty) {
              if (!_scheduledEmptyExit) {
                _scheduledEmptyExit = true;
                _deferNavigateToToday(context);
              }
              return const SizedBox.shrink();
            }

            return _ResolutionBody(
              remaining: remaining,
              resolved: resolved,
              total: total,
              onResolved: (id) => setState(() => _resolvedIds.add(id)),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
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
      ),
    );
  }
}

class _ResolutionBody extends ConsumerWidget {
  const _ResolutionBody({
    required this.remaining,
    required this.resolved,
    required this.total,
    required this.onResolved,
  });

  final List<TodayTask> remaining;
  final int resolved;
  final int total;
  final void Function(String id) onResolved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final pct = total > 0 ? (resolved / total) * 100.0 : 0.0;
    final secondary =
        isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark;
    final primaryText =
        isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark;
    final chipBg =
        isLight ? const Color(0xFFF0F1F3) : const Color(0xFF262626);

    final canFinish = remaining.isEmpty && total > 0;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Before you sleep 💤',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 26,
                    letterSpacing: -0.52,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  canFinish
                      ? "You're all caught up. Tap below when you're ready to "
                          'finish.'
                      : 'These tasks are still unresolved. Give each one a '
                          'final decision.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    height: 1.5,
                    color: secondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ProgressBarDS(
                        pct: pct,
                        height: 4,
                        color:
                            isLight ? AppColors.primary : AppColors.primaryDark,
                        trackColor: isLight
                            ? AppColors.dividerLight
                            : AppColors.dividerDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$resolved of $total resolved',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: primaryText,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: remaining.length,
              itemBuilder: (context, index) => _EodTaskRow(
                task: remaining[index],
                onResolved: onResolved,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: _AllDoneCta(
              enabled: canFinish,
              label: 'All done ($resolved / $total)',
              onPressed: () => _deferNavigateToToday(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Primary footer — matches `sheetD_EndOfDay` disabled control (`opacity: 0.55`
/// on teal), not the grey slab from generic disabled primary buttons.
class _AllDoneCta extends StatelessWidget {
  const _AllDoneCta({
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final fill = isLight ? AppColors.primary : AppColors.primaryDark;
    final bg = enabled ? fill : fill.withValues(alpha: 0.55);
    final fg = enabled
        ? Colors.white
        : Colors.white.withValues(alpha: 0.85);
    final shadow = enabled && isLight
        ? const [
            BoxShadow(
              color: Color(0x2E00796B),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ]
        : null;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: enabled ? onPressed : null,
          child: Ink(
            height: 48,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadius.mdAll,
              boxShadow: shadow,
            ),
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _EodFlash { done, tomorrow, close }

class _EodTaskRow extends ConsumerStatefulWidget {
  const _EodTaskRow({
    required this.task,
    required this.onResolved,
  });

  final TodayTask task;
  final void Function(String id) onResolved;

  @override
  ConsumerState<_EodTaskRow> createState() => _EodTaskRowState();
}

class _EodTaskRowState extends ConsumerState<_EodTaskRow> {
  _EodFlash? _flash;

  Color _stripColor(Brightness b) {
    switch (widget.task.priority) {
      case Priority.none:
        return b == Brightness.light
            ? AppColors.textDisabledLight
            : AppColors.textDisabledDark;
      case Priority.low:
        return b == Brightness.light
            ? AppColors.priorityLowLight
            : AppColors.priorityLowDark;
      case Priority.medium:
        return b == Brightness.light
            ? AppColors.priorityMediumLight
            : AppColors.priorityMediumDark;
      case Priority.high:
        return b == Brightness.light
            ? AppColors.priorityHighLight
            : AppColors.priorityHighDark;
      case Priority.urgent:
        return b == Brightness.light
            ? AppColors.priorityUrgentLight
            : AppColors.priorityUrgentDark;
    }
  }

  Future<void> _run(_EodFlash flash, Future<void> Function() fn) async {
    setState(() => _flash = flash);
    await Future<void>.delayed(const Duration(milliseconds: 160));
    try {
      await fn();
      widget.onResolved(widget.task.id);
    } finally {
      if (mounted) setState(() => _flash = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = theme.brightness;
    final isLight = b == Brightness.light;

    /// Cards use **surface** on **background** — dark cards read lighter than page.
    final cardBg =
        isLight ? AppColors.surfaceLight : AppColors.surfaceRaisedDark;
    final divider =
        isLight ? AppColors.dividerLight : AppColors.dividerDark;
    final strip = _stripColor(b);
    final task = widget.task;

    final success = AppColors.successColor(b);
    final info = AppColors.infoColor(b);
    final secondary =
        isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: ClipRRect(
        borderRadius: AppRadius.mdAll,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(child: ColoredBox(color: cardBg)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: divider, width: 1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kPriorityStripWidth + 14,
                12,
                14,
                12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 14,
                      fontWeight: task.priority == Priority.urgent
                          ? FontWeight.w700
                          : FontWeight.w600,
                      height: 1.3,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _EodSegmentButton(
                          flash: _flash,
                          variant: _EodFlash.done,
                          label: 'Done',
                          icon: Icons.check,
                          idleFill: Colors.transparent,
                          idleBorder: divider,
                          idleFg: secondary,
                          selFill: success,
                          selFg: Colors.white,
                          selBorder: success,
                          onTap: () => _run(
                            _EodFlash.done,
                            () => ref
                                .read(resolutionActionsProvider.notifier)
                                .markDone(task),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _EodSegmentButton(
                          flash: _flash,
                          variant: _EodFlash.tomorrow,
                          label: 'Tomorrow',
                          icon: Icons.east,
                          idleFill: Colors.transparent,
                          idleBorder: divider,
                          idleFg: secondary,
                          selFill: info,
                          selFg: Colors.white,
                          selBorder: info,
                          onTap: () => _run(
                            _EodFlash.tomorrow,
                            () => ref
                                .read(resolutionActionsProvider.notifier)
                                .moveToTomorrow(task),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _EodSegmentButton(
                          flash: _flash,
                          variant: _EodFlash.close,
                          label: 'Close',
                          icon: Icons.close,
                          idleFill: Colors.transparent,
                          idleBorder: divider,
                          idleFg: secondary,
                          selFill: secondary,
                          selFg: Colors.white,
                          selBorder: secondary,
                          onTap: () => _run(
                            _EodFlash.close,
                            () => ref
                                .read(resolutionActionsProvider.notifier)
                                .close(task),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: kPriorityStripWidth,
              child: ColoredBox(color: strip),
            ),
          ],
        ),
      ),
    );
  }
}

/// `.eod-btn` / `.eod-btn.sel.*` — `styles.css` (solid fills when active).
class _EodSegmentButton extends StatelessWidget {
  const _EodSegmentButton({
    required this.flash,
    required this.variant,
    required this.label,
    required this.icon,
    required this.idleFill,
    required this.idleBorder,
    required this.idleFg,
    required this.selFill,
    required this.selFg,
    required this.selBorder,
    required this.onTap,
  });

  final _EodFlash? flash;
  final _EodFlash variant;
  final String label;
  final IconData icon;
  final Color idleFill;
  final Color idleBorder;
  final Color idleFg;
  final Color selFill;
  final Color selFg;
  final Color selBorder;
  final VoidCallback onTap;

  bool get _selected => flash == variant;

  @override
  Widget build(BuildContext context) {
    final fill = _selected ? selFill : idleFill;
    final fg = _selected ? selFg : idleFg;
    final borderColor = _selected ? selBorder : idleBorder;

    return SizedBox(
      height: 44,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smAll,
          child: Ink(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: AppRadius.smAll,
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18, color: fg),
                    const SizedBox(width: 3),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
