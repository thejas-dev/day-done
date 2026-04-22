import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_tracker/core/constants/route_constants.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/core/theme/app_theme.dart';
import 'package:todo_tracker/core/widgets/primary_button.dart';
import 'package:todo_tracker/features/notifications/providers/notification_providers.dart';
import 'package:todo_tracker/features/settings/domain/notification_mode.dart';
import 'package:todo_tracker/features/settings/presentation/providers/settings_provider.dart';
import 'package:todo_tracker/features/tasks/domain/priority.dart';
import 'package:todo_tracker/features/tasks/domain/task_type.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_action_provider.dart';

part 'onboarding_screen.g.dart';

@riverpod
class OnboardingPage extends _$OnboardingPage {
  @override
  int build() => 0;

  void setPage(int page) => state = page;
}

@riverpod
class OnboardingBedtimeIndex extends _$OnboardingBedtimeIndex {
  @override
  int build() {
    final slots = generateBedtimeSlots();
    final idx = slots.indexWhere((s) => s.hour == 23 && s.minute == 0);
    return idx >= 0 ? idx : 20;
  }

  void select(int index) => state = index;
}

@riverpod
class OnboardingMorningCheckinIndex extends _$OnboardingMorningCheckinIndex {
  @override
  int build() {
    final slots = generateMorningCheckinSlots();
    final idx = slots.indexWhere((s) => s.hour == 8 && s.minute == 0);
    return idx >= 0 ? idx : 12;
  }

  void select(int index) => state = index;
}

@riverpod
class OnboardingNotificationMode extends _$OnboardingNotificationMode {
  @override
  NotificationMode build() => NotificationMode.standard;

  void select(NotificationMode mode) => state = mode;
}

@riverpod
class OnboardingFirstTaskTitle extends _$OnboardingFirstTaskTitle {
  @override
  String build() => 'Draft retrospective notes';

  void setTitle(String value) => state = value;
}

@riverpod
class OnboardingFirstTaskType extends _$OnboardingFirstTaskType {
  @override
  TaskType build() => TaskType.daily;

  void setType(TaskType value) => state = value;
}

@riverpod
class OnboardingFirstTaskPriority extends _$OnboardingFirstTaskPriority {
  @override
  Priority build() => Priority.high;

  void setPriority(Priority value) => state = value;
}

@riverpod
class OnboardingFirstTaskLabel extends _$OnboardingFirstTaskLabel {
  @override
  String build() => '';

  void setLabel(String value) => state = value;
}

List<DateTime> generateBedtimeSlots() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final slots = <DateTime>[];

  for (var h = 18; h <= 23; h++) {
    for (var m = 0; m < 60; m += 15) {
      slots.add(DateTime(today.year, today.month, today.day, h, m));
    }
  }
  for (var h = 0; h <= 3; h++) {
    for (var m = 0; m < 60; m += 15) {
      if (h == 3 && m > 0) break;
      slots.add(DateTime(tomorrow.year, tomorrow.month, tomorrow.day, h, m));
    }
  }
  return slots;
}

List<DateTime> generateMorningCheckinSlots() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final slots = <DateTime>[];

  for (var h = 5; h <= 12; h++) {
    for (var m = 0; m < 60; m += 15) {
      if (h == 12 && m > 0) break;
      slots.add(DateTime(today.year, today.month, today.day, h, m));
    }
  }
  return slots;
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  static const _totalPages = 4;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _nextPage() {
    final current = ref.read(onboardingPageProvider);
    if (current < _totalPages - 1) _goToPage(current + 1);
  }

  Future<void> _completeOnboarding() async {
    await ref.read(settingsActionsProvider.notifier).completeOnboarding();
    if (mounted) context.go(RouteConstants.today);
  }

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(onboardingPageProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    final ghost = isLight
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    return Scaffold(
      backgroundColor: isLight
          ? AppColors.backgroundLight
          : AppColors.backgroundDark,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (value) =>
              ref.read(onboardingPageProvider.notifier).setPage(value),
          children: [
            _OnboardStepShell(
              step: 1,
              head: 'When does your day\nend?',
              sub:
                  'DayDone schedules your reminders around your bedtime — so nothing slips.',
              body: const _BedtimeWheelBlock(),
              ctas: [PrimaryButtonDS(label: 'Continue', onPressed: _nextPage)],
              currentPage: page,
            ),
            _OnboardStepShell(
              step: 2,
              head: 'When should we check\nin with you?',
              sub: 'A quick morning summary of what today holds.',
              body: const _MorningWheelBlock(),
              ctas: [
                PrimaryButtonDS(
                  label: 'Continue',
                  onPressed: () async {
                    final idx = ref.read(onboardingMorningCheckinIndexProvider);
                    final slots = generateMorningCheckinSlots();
                    await ref
                        .read(settingsActionsProvider.notifier)
                        .updateMorningCheckin(slots[idx]);
                    _nextPage();
                  },
                ),
                _GhostAction(
                  label: 'Skip for now',
                  color: ghost,
                  onTap: _nextPage,
                ),
              ],
              currentPage: page,
            ),
            _OnboardStepShell(
              step: 3,
              head: 'Add your first task for\ntoday',
              sub: 'Just one thing. You can always add more.',
              body: const _FirstTaskCardPreview(),
              ctas: [
                PrimaryButtonDS(
                  label: 'Add Task',
                  onPressed: () async {
                    final title = ref
                        .read(onboardingFirstTaskTitleProvider)
                        .trim();
                    if (title.isEmpty) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter a task title')),
                        );
                      }
                      return;
                    }

                    final type = ref.read(onboardingFirstTaskTypeProvider);
                    final priority = ref.read(
                      onboardingFirstTaskPriorityProvider,
                    );
                    final label = ref
                        .read(onboardingFirstTaskLabelProvider)
                        .trim();

                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);

                    final created = await ref
                        .read(taskActionsProvider.notifier)
                        .createTask(
                          title: title,
                          type: type,
                          date: type == TaskType.dated ? today : null,
                          priority: priority,
                          labels: label.isEmpty ? const [] : [label],
                        );
                    if (created != null) {
                      _nextPage();
                    }
                  },
                ),
                _GhostAction(label: 'Skip', color: ghost, onTap: _nextPage),
              ],
              bodyAlignment: Alignment.topCenter,
              bodyBottomGap: 0,
              ctaTopGap: 10,
              expandBodyToViewport: true,
              currentPage: page,
            ),
            _OnboardStepShell(
              step: 4,
              head: 'DayDone needs to reach\nyou — even on silent.',
              sub: '',
              body: const _NotificationPermissionBody(),
              ctas: [
                PrimaryButtonDS(
                  label: 'Allow Notifications',
                  onPressed: () async {
                    final service = ref.read(notificationServiceProvider);
                    await service.requestPermissions();
                    await ref
                        .read(settingsActionsProvider.notifier)
                        .updateNotificationPermissionAsked();
                    await _completeOnboarding();
                  },
                ),
                _GhostAction(
                  label: 'Not now',
                  color: ghost,
                  onTap: () async {
                    await ref
                        .read(settingsActionsProvider.notifier)
                        .updateNotificationPermissionAsked();
                    await _completeOnboarding();
                  },
                ),
              ],
              currentPage: page,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardStepShell extends StatelessWidget {
  const _OnboardStepShell({
    required this.step,
    required this.head,
    required this.sub,
    required this.body,
    required this.ctas,
    required this.currentPage,
    this.bodyAlignment = Alignment.topCenter,
    this.bodyBottomGap = 0,
    this.ctaTopGap = 0,
    this.expandBodyToViewport = false,
  });

  final int step;
  final String head;
  final String sub;
  final Widget body;
  final List<Widget> ctas;
  final int currentPage;
  final Alignment bodyAlignment;
  final double bodyBottomGap;
  final double ctaTopGap;
  final bool expandBodyToViewport;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final secondary = isLight
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    Widget headerBlock() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STEP $step OF 4',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.98,
              color: secondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            head,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: -0.56,
            ),
          ),
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              sub,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                height: 1.5,
                color: secondary,
              ),
            ),
          ],
          const SizedBox(height: 28),
        ],
      );
    }

    Widget ctaBlock() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < ctas.length; i++) ...[
            ctas[i],
            if (i != ctas.length - 1) const SizedBox(height: 10),
          ],
        ],
      );
    }

    return Container(
      color: isLight ? AppColors.backgroundLight : AppColors.backgroundDark,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: keyboardInset > 0 ? keyboardInset : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerBlock(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bodyBottomGap),
                    child: LayoutBuilder(
                      builder: (context, bodyConstraints) {
                        final bodyChild = expandBodyToViewport
                            ? ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: bodyConstraints.maxHeight,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: body,
                                ),
                              )
                            : Align(
                                alignment: keyboardInset > 0
                                    ? Alignment.topCenter
                                    : bodyAlignment,
                                child: body,
                              );
                        return SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: bodyConstraints.maxHeight,
                            ),
                            child: bodyChild,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (ctaTopGap > 0) SizedBox(height: ctaTopGap),
                ctaBlock(),
                const SizedBox(height: 16),
                _StepDots(currentPage: currentPage),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final disabled = isLight
        ? AppColors.textDisabledLight
        : AppColors.textDisabledDark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final active = index == currentPage;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active
                  ? (isLight ? AppColors.primary : AppColors.primaryDark)
                  : disabled,
              borderRadius: BorderRadius.circular(active ? 3 : 999),
            ),
          );
        }),
      ),
    );
  }
}

class _GhostAction extends StatelessWidget {
  const _GhostAction({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _BedtimeWheelBlock extends ConsumerWidget {
  const _BedtimeWheelBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = generateBedtimeSlots();
    final index = ref.watch(onboardingBedtimeIndexProvider);

    return Column(
      children: [
        _OnboardingWheelPicker(
          slots: slots,
          initialIndex: index,
          onChanged: (i) =>
              ref.read(onboardingBedtimeIndexProvider.notifier).select(i),
        ),
        const SizedBox(height: 12),
        Text(
          '6:00 PM  —  3:00 AM  ·  15-min steps',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.textSecondaryLight
                : AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }
}

class _MorningWheelBlock extends ConsumerWidget {
  const _MorningWheelBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = generateMorningCheckinSlots();
    final index = ref.watch(onboardingMorningCheckinIndexProvider);

    return _OnboardingWheelPicker(
      slots: slots,
      initialIndex: index,
      periodScrollable: false,
      onChanged: (i) =>
          ref.read(onboardingMorningCheckinIndexProvider.notifier).select(i),
    );
  }
}

class _OnboardingWheelPicker extends StatefulWidget {
  const _OnboardingWheelPicker({
    required this.slots,
    required this.initialIndex,
    required this.onChanged,
    this.periodScrollable = true,
  });

  final List<DateTime> slots;
  final int initialIndex;
  final ValueChanged<int> onChanged;
  final bool periodScrollable;

  @override
  State<_OnboardingWheelPicker> createState() => _OnboardingWheelPickerState();
}

class _OnboardingWheelPickerState extends State<_OnboardingWheelPicker> {
  static const _hours = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  static const _minutes = <int>[0, 15, 30, 45];
  static const _periods = <String>['AM', 'PM'];

  static const _loopCount = 10000;
  static const _loopMid = 5000;

  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minuteCtrl;
  late FixedExtentScrollController _periodCtrl;

  late int _selectedIndex;
  late int _hourVisible;
  late int _minuteVisible;
  late int _periodVisible;
  bool _syncingControllers = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, widget.slots.length - 1);
    final d = widget.slots[_selectedIndex];
    final h = _hourTo12(d.hour) - 1;
    final m = _minutes.indexOf(d.minute);
    final p = d.hour >= 12 ? 1 : 0;

    _hourVisible = _loopMid + h;
    _minuteVisible = _loopMid + m;
    _periodVisible = p;

    _hourCtrl = FixedExtentScrollController(initialItem: _hourVisible);
    _minuteCtrl = FixedExtentScrollController(initialItem: _minuteVisible);
    _periodCtrl = FixedExtentScrollController(initialItem: _periodVisible);
  }

  @override
  void didUpdateWidget(covariant _OnboardingWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final clamped = widget.initialIndex.clamp(0, widget.slots.length - 1);
    if (clamped == _selectedIndex) return;

    _selectedIndex = clamped;
    final d = widget.slots[_selectedIndex];
    final h = _hourTo12(d.hour) - 1;
    final m = _minutes.indexOf(d.minute);
    final p = d.hour >= 12 ? 1 : 0;

    setState(() {
      _hourVisible = _loopMid + h;
      _minuteVisible = _loopMid + m;
      _periodVisible = p;
    });

    _hourCtrl.jumpToItem(_hourVisible);
    _minuteCtrl.jumpToItem(_minuteVisible);
    _periodCtrl.jumpToItem(_periodVisible);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    _periodCtrl.dispose();
    super.dispose();
  }

  int _hourTo12(int h24) {
    if (h24 == 0) return 12;
    if (h24 > 12) return h24 - 12;
    return h24;
  }

  int _to24(int h12, String period) {
    if (period == 'AM') return h12 == 12 ? 0 : h12;
    return h12 == 12 ? 12 : h12 + 12;
  }

  DateTime _candidateFromParts({
    required int h12,
    required int minute,
    required String period,
  }) {
    final selected = widget.slots[_selectedIndex];
    final h24 = _to24(h12, period);
    var dt = DateTime(selected.year, selected.month, selected.day, h24, minute);

    if (selected.day != widget.slots.first.day) {
      if (h24 >= 18) dt = dt.subtract(const Duration(days: 1));
    } else {
      if (h24 <= 3) dt = dt.add(const Duration(days: 1));
    }
    return dt;
  }

  int _nearestSlotIndex(DateTime target) {
    var best = 0;
    var bestDelta =
        (widget.slots.first.millisecondsSinceEpoch -
                target.millisecondsSinceEpoch)
            .abs();
    for (var i = 1; i < widget.slots.length; i++) {
      final delta =
          (widget.slots[i].millisecondsSinceEpoch -
                  target.millisecondsSinceEpoch)
              .abs();
      if (delta < bestDelta) {
        bestDelta = delta;
        best = i;
      }
    }
    return best;
  }

  void _recenterIfNeeded(
    FixedExtentScrollController ctrl,
    int visible,
    int modBase,
  ) {
    if (visible > 9000 || visible < 1000) {
      final recentered = _loopMid + (visible % modBase);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ctrl.jumpToItem(recentered);
      });
    }
  }

  int _closestLoopItem({
    required int current,
    required int modulo,
    required int desiredMod,
  }) {
    final n = ((current - desiredMod) / modulo).round();
    return desiredMod + (n * modulo);
  }

  void _syncVisibleToSelected({required bool animated}) {
    final d = widget.slots[_selectedIndex];
    final desiredHourMod = _hourTo12(d.hour) - 1;
    final desiredMinuteMod = _minutes.indexOf(d.minute);
    final desiredPeriod = d.hour >= 12 ? 1 : 0;

    final nextHour = _closestLoopItem(
      current: _hourVisible,
      modulo: _hours.length,
      desiredMod: desiredHourMod,
    );
    final nextMinute = _closestLoopItem(
      current: _minuteVisible,
      modulo: _minutes.length,
      desiredMod: desiredMinuteMod,
    );

    if (_hourVisible == nextHour &&
        _minuteVisible == nextMinute &&
        _periodVisible == desiredPeriod) {
      return;
    }

    _syncingControllers = true;
    _hourVisible = nextHour;
    _minuteVisible = nextMinute;
    _periodVisible = desiredPeriod;

    Future<void> move(FixedExtentScrollController c, int item) async {
      if (animated) {
        await c.animateToItem(
          item,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
        );
      } else {
        c.jumpToItem(item);
      }
    }

    Future.wait([
      move(_hourCtrl, _hourVisible),
      move(_minuteCtrl, _minuteVisible),
      move(_periodCtrl, _periodVisible),
    ]).whenComplete(() {
      if (!mounted) return;
      _syncingControllers = false;
      setState(() {});
    });
  }

  void _applySelection() {
    final h12 = _hours[_hourVisible % _hours.length];
    final minute = _minutes[_minuteVisible % _minutes.length];
    final resolvedPeriod = widget.periodScrollable
        ? _periods[_periodVisible]
        : (h12 == 12 ? 'PM' : 'AM');

    if (!widget.periodScrollable) {
      _periodVisible = resolvedPeriod == 'PM' ? 1 : 0;
    }

    final candidate = _candidateFromParts(
      h12: h12,
      minute: minute,
      period: resolvedPeriod,
    );
    final nearest = _nearestSlotIndex(candidate);
    if (nearest != _selectedIndex) {
      _selectedIndex = nearest;
      widget.onChanged(_selectedIndex);
    }

    _syncVisibleToSelected(animated: true);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = isLight
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;
    final disabled = isLight
        ? AppColors.textDisabledLight
        : AppColors.textDisabledDark;
    final divider = isLight ? AppColors.dividerLight : AppColors.dividerDark;

    final selectedStyle = TextStyle(
      fontSize: 58,
      fontWeight: FontWeight.w700,
      color: primary,
      letterSpacing: -1.04,
      height: 1,
    );

    final ghostStyle = TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w600,
      color: disabled.withValues(alpha: 0.35),
      height: 1,
    );

    Widget wheel({
      required FixedExtentScrollController controller,
      required int count,
      required String Function(int) label,
      required ValueChanged<int> onSelected,
      required bool Function(int) selectedPredicate,
      required double width,
      bool scrollable = true,
      double diameterRatio = 2.8,
      TextStyle? selectedTextStyle,
      TextStyle? ghostTextStyle,
    }) {
      return SizedBox(
        width: width,
        height: 164,
        child: ListWheelScrollView.useDelegate(
          controller: controller,
          physics: scrollable
              ? const FixedExtentScrollPhysics(parent: BouncingScrollPhysics())
              : const NeverScrollableScrollPhysics(),
          itemExtent: 52,
          diameterRatio: diameterRatio,
          perspective: 0.003,
          overAndUnderCenterOpacity: 1,
          squeeze: 1,
          onSelectedItemChanged: onSelected,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: count,
            builder: (context, index) {
              if (index < 0 || index >= count) return null;
              final selected = selectedPredicate(index);
              return Center(
                child: Text(
                  label(index),
                  style: selected
                      ? (selectedTextStyle ?? selectedStyle)
                      : (ghostTextStyle ?? ghostStyle),
                ),
              );
            },
          ),
        ),
      );
    }

    final selectedSlot = widget.slots[_selectedIndex];
    final resolvedPeriod = selectedSlot.hour >= 12 ? 'PM' : 'AM';

    Widget staticPeriodColumn() {
      final ghost = resolvedPeriod == 'AM' ? 'PM' : 'AM';
      return SizedBox(
        width: 116,
        height: 164,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(ghost, style: ghostStyle.copyWith(fontSize: 36)),
            Text(resolvedPeriod, style: selectedStyle.copyWith(fontSize: 52)),
            Text(' ', style: ghostStyle.copyWith(fontSize: 36)),
          ],
        ),
      );
    }

    return SizedBox(
      height: 164,
      width: double.infinity,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              wheel(
                controller: _hourCtrl,
                count: _loopCount,
                width: 84,
                label: (i) =>
                    _hours[i % _hours.length].toString().padLeft(2, '0'),
                onSelected: (i) {
                  if (_syncingControllers) return;
                  setState(() => _hourVisible = i);
                  _applySelection();
                  _recenterIfNeeded(_hourCtrl, i, _hours.length);
                },
                selectedPredicate: (i) => i == _hourVisible,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  ':',
                  style: selectedStyle.copyWith(
                    color: disabled.withValues(alpha: 0.55),
                    fontSize: 52,
                  ),
                ),
              ),
              wheel(
                controller: _minuteCtrl,
                count: _loopCount,
                width: 84,
                label: (i) =>
                    _minutes[i % _minutes.length].toString().padLeft(2, '0'),
                onSelected: (i) {
                  if (_syncingControllers) return;
                  setState(() => _minuteVisible = i);
                  _applySelection();
                  _recenterIfNeeded(_minuteCtrl, i, _minutes.length);
                },
                selectedPredicate: (i) => i == _minuteVisible,
              ),
              const SizedBox(width: 12),
              if (widget.periodScrollable)
                wheel(
                  controller: _periodCtrl,
                  count: _periods.length,
                  width: 116,
                  scrollable: true,
                  diameterRatio: 100,
                  selectedTextStyle: selectedStyle.copyWith(fontSize: 52),
                  ghostTextStyle: ghostStyle.copyWith(fontSize: 36),
                  label: (i) => _periods[i],
                  onSelected: (i) {
                    if (_syncingControllers) return;
                    setState(() => _periodVisible = i);
                    _applySelection();
                  },
                  selectedPredicate: (i) => i == _periodVisible,
                )
              else
                staticPeriodColumn(),
            ],
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 56),
                child: FractionallySizedBox(
                  widthFactor: 0.62,
                  child: Container(height: 1, color: divider),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 52),
                child: FractionallySizedBox(
                  widthFactor: 0.62,
                  child: Container(height: 1, color: divider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FirstTaskCardPreview extends ConsumerStatefulWidget {
  const _FirstTaskCardPreview();

  @override
  ConsumerState<_FirstTaskCardPreview> createState() =>
      _FirstTaskCardPreviewState();
}

class _FirstTaskCardPreviewState extends ConsumerState<_FirstTaskCardPreview> {
  late final TextEditingController _titleController;
  late final TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: ref.read(onboardingFirstTaskTitleProvider),
    );
    _labelController = TextEditingController(
      text: ref.read(onboardingFirstTaskLabelProvider),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final surface = isLight ? AppColors.surfaceLight : AppColors.surfaceDark;
    final divider = isLight ? AppColors.dividerLight : AppColors.dividerDark;
    final bg = isLight ? AppColors.backgroundLight : AppColors.backgroundDark;
    final secondary = isLight
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;
    final disabled = isLight
        ? AppColors.textDisabledLight
        : AppColors.textDisabledDark;
    final primaryText = isLight
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

    final type = ref.watch(onboardingFirstTaskTypeProvider);
    final priority = ref.watch(onboardingFirstTaskPriorityProvider);
    final title = ref.watch(onboardingFirstTaskTitleProvider);
    final label = ref.watch(onboardingFirstTaskLabelProvider);

    if (_titleController.text != title) {
      _titleController.value = TextEditingValue(
        text: title,
        selection: TextSelection.collapsed(offset: title.length),
      );
    }
    if (_labelController.text != label) {
      _labelController.value = TextEditingValue(
        text: label,
        selection: TextSelection.collapsed(offset: label.length),
      );
    }

    Widget prio(String labelText, Priority value, Color color) {
      final active = value == priority;
      return InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => ref
            .read(onboardingFirstTaskPriorityProvider.notifier)
            .setPriority(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Text(
            labelText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : color,
            ),
          ),
        ),
      );
    }

    Widget typeOption({
      required String labelText,
      required IconData icon,
      required TaskType value,
    }) {
      final active = type == value;
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () =>
            ref.read(onboardingFirstTaskTypeProvider.notifier).setType(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active && isLight
                ? const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: secondary),
              const SizedBox(width: 4),
              Text(
                labelText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? primaryText : secondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isLight ? AppTheme.tileShadowLight : AppTheme.tileShadowDark,
        border: Border.all(color: divider, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'TASK',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.8,
              color: secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isLight ? AppColors.primary : AppColors.primaryDark,
                  width: 1.5,
                ),
              ),
            ),
            child: TextField(
              controller: _titleController,
              onChanged: ref
                  .read(onboardingFirstTaskTitleProvider.notifier)
                  .setTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                isDense: true,
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'TYPE',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.8,
              color: secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: typeOption(
                    labelText: 'Daily',
                    icon: Icons.refresh,
                    value: TaskType.daily,
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: typeOption(
                    labelText: 'One-time',
                    icon: Icons.event,
                    value: TaskType.dated,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'PRIORITY',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.8,
              color: secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => ref
                    .read(onboardingFirstTaskPriorityProvider.notifier)
                    .setPriority(Priority.none),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: priority == Priority.none
                        ? divider.withValues(alpha: 0.4)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: divider, width: 1.5),
                  ),
                  child: Text(
                    'None',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: secondary,
                    ),
                  ),
                ),
              ),
              prio(
                'Low',
                Priority.low,
                isLight
                    ? AppColors.priorityLowLight
                    : AppColors.priorityLowDark,
              ),
              prio(
                'Medium',
                Priority.medium,
                isLight
                    ? AppColors.priorityMediumLight
                    : AppColors.priorityMediumDark,
              ),
              prio(
                'High',
                Priority.high,
                isLight
                    ? AppColors.priorityHighLight
                    : AppColors.priorityHighDark,
              ),
              prio(
                'Urgent',
                Priority.urgent,
                isLight
                    ? AppColors.priorityUrgentLight
                    : AppColors.priorityUrgentDark,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'LABEL (OPTIONAL)',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.8,
              color: secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isLight
                  ? AppColors.backgroundLight
                  : const Color(0xFF181818),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: divider),
            ),
            child: TextField(
              controller: _labelController,
              onChanged: ref
                  .read(onboardingFirstTaskLabelProvider.notifier)
                  .setLabel,
              style: TextStyle(fontSize: 13, color: primaryText),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                hintText: '+ Add label',
                hintStyle: TextStyle(fontSize: 13, color: disabled),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationPermissionBody extends StatelessWidget {
  const _NotificationPermissionBody();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final secondary = isLight
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;
    final primary = isLight ? AppColors.primary : AppColors.primaryDark;
    final container = isLight
        ? AppColors.primaryContainer
        : AppColors.primaryContainerDark;

    final bodyStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontSize: 13,
      color: secondary,
      height: 1.6,
    );

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: container,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.notifications_active,
                  size: 64,
                  color: primary,
                ),
              ),
            ),
            Positioned(
              right: 14,
              top: 12,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.errorColor(Theme.of(context).brightness),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You'll get a morning summary, a two-hour bedtime warning, and a final resolution prompt at lights-out.",
                style: bodyStyle,
              ),
              const SizedBox(height: 10),
              Text(
                'Reminders fire on your schedule — never random pings.',
                style: bodyStyle,
              ),
              const SizedBox(height: 10),
              Text(
                'DND bypass is why the end-of-day mechanic works. Off means reminders are silent.',
                style: bodyStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
