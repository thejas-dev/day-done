import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_tracker/core/constants/route_constants.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/features/notifications/providers/notification_providers.dart';
import 'package:todo_tracker/features/settings/domain/notification_mode.dart';
import 'package:todo_tracker/features/settings/presentation/providers/settings_provider.dart';

part 'onboarding_screen.g.dart';

// ── Providers for onboarding UI state ───────────────────────────────────────

/// Tracks the current onboarding page index.
@riverpod
class OnboardingPage extends _$OnboardingPage {
  @override
  int build() => 0;

  void setPage(int page) {
    state = page;
  }
}

/// Tracks the selected bedtime slot index during onboarding.
/// Default: index of 11:00 PM in the bedtime slots list (= index 20).
@riverpod
class OnboardingBedtimeIndex extends _$OnboardingBedtimeIndex {
  @override
  int build() {
    final slots = generateBedtimeSlots();
    final idx = slots.indexWhere((s) => s.hour == 23 && s.minute == 0);
    return idx >= 0 ? idx : 20;
  }

  void select(int index) {
    state = index;
  }
}

/// Tracks the selected notification mode during onboarding.
@riverpod
class OnboardingNotificationMode extends _$OnboardingNotificationMode {
  @override
  NotificationMode build() => NotificationMode.standard;

  void select(NotificationMode mode) {
    state = mode;
  }
}

// ── Bedtime slots helper ────────────────────────────────────────────────────

/// Generates bedtime slots: 6:00 PM to 3:00 AM, 15-min increments.
List<DateTime> generateBedtimeSlots() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final slots = <DateTime>[];

  // 18:00 to 23:45 today
  for (var h = 18; h <= 23; h++) {
    for (var m = 0; m < 60; m += 15) {
      slots.add(DateTime(today.year, today.month, today.day, h, m));
    }
  }
  // 00:00 to 03:00 tomorrow
  for (var h = 0; h <= 3; h++) {
    for (var m = 0; m < 60; m += 15) {
      if (h == 3 && m > 0) break;
      slots.add(DateTime(tomorrow.year, tomorrow.month, tomorrow.day, h, m));
    }
  }
  return slots;
}

String formatTimeSlot(DateTime dt) {
  final hour = dt.hour;
  final minute = dt.minute;
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour == 0
      ? 12
      : hour > 12
          ? hour - 12
          : hour;
  return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
}

// ── Main OnboardingScreen ───────────────────────────────────────────────────

/// 4-step onboarding flow.
/// Step 1: Welcome (not skippable)
/// Step 2: Bedtime setup (skippable)
/// Step 3: Notification mode (skippable)
/// Step 4: Notification permission (skippable)
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    final current = ref.read(onboardingPageProvider);
    if (current < _totalPages - 1) {
      _goToPage(current + 1);
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(settingsActionsProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go(RouteConstants.today);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(onboardingPageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (visible on steps 2-4, top-right)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (currentPage > 0 && currentPage < _totalPages - 1)
                    TextButton(
                      onPressed: _nextPage,
                      child: Text(
                        'Skip',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 44),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  ref.read(onboardingPageProvider.notifier).setPage(page);
                },
                children: [
                  _WelcomePage(onGetStarted: _nextPage),
                  _BedtimePage(onNext: _nextPage),
                  _NotificationModePage(onNext: _nextPage),
                  _PermissionPage(onComplete: _completeOnboarding),
                ],
              ),
            ),

            // Page indicator dots
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalPages, (index) {
                  final isActive = index == currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    width: isActive ? 24.0 : 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      borderRadius: AppRadius.fullAll,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 1: Welcome ─────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.xl2),
          Text(
            'DayDone',
            style: theme.textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Every task resolved before bedtime.\nNo silent rollovers. No forgotten todos.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 3),
          ElevatedButton(
            onPressed: onGetStarted,
            child: const Text('Get Started'),
          ),
          const SizedBox(height: AppSpacing.xl2),
        ],
      ),
    );
  }
}

// ── Step 2: Bedtime Setup ───────────────────────────────────────────────────

class _BedtimePage extends ConsumerWidget {
  const _BedtimePage({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedIndex = ref.watch(onboardingBedtimeIndexProvider);
    final slots = generateBedtimeSlots();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(
            'When does your day end?',
            style: theme.textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'DayDone will remind you to resolve all tasks before bedtime.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl3),
          // Time grid
          Expanded(
            flex: 3,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2.2,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
              ),
              itemCount: slots.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(onboardingBedtimeIndexProvider.notifier)
                        .select(index);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Text(
                      formatTimeSlot(slots[index]),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () async {
              if (selectedIndex >= 0 && selectedIndex < slots.length) {
                await ref
                    .read(settingsActionsProvider.notifier)
                    .updateBedtime(slots[selectedIndex]);
              }
              onNext();
            },
            child: const Text('Continue'),
          ),
          const SizedBox(height: AppSpacing.xl2),
        ],
      ),
    );
  }
}

// ── Step 3: Notification Mode ───────────────────────────────────────────────

class _NotificationModePage extends ConsumerWidget {
  const _NotificationModePage({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selected = ref.watch(onboardingNotificationModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(
            'How should we remind you?',
            style: theme.textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Choose a notification style that works for you. '
            'You can change this later in Settings.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl3),
          ...NotificationMode.values.map((mode) {
            final isSelected = mode == selected;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdAll,
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    ref
                        .read(onboardingNotificationModeProvider.notifier)
                        .select(mode);
                  },
                  borderRadius: AppRadius.mdAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _modeIcon(mode),
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _modeTitle(mode),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _modeDescription(mode),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(flex: 2),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(settingsActionsProvider.notifier)
                  .updateNotificationMode(selected);
              onNext();
            },
            child: const Text('Continue'),
          ),
          const SizedBox(height: AppSpacing.xl2),
        ],
      ),
    );
  }

  IconData _modeIcon(NotificationMode mode) => switch (mode) {
        NotificationMode.minimal => Icons.notifications_off_outlined,
        NotificationMode.standard => Icons.notifications_outlined,
        NotificationMode.persistent => Icons.notifications_active_outlined,
      };

  String _modeTitle(NotificationMode mode) => switch (mode) {
        NotificationMode.minimal => 'Minimal',
        NotificationMode.standard => 'Standard',
        NotificationMode.persistent => 'Persistent',
      };

  String _modeDescription(NotificationMode mode) => switch (mode) {
        NotificationMode.minimal => 'Bedtime reminder only',
        NotificationMode.standard =>
          'Morning check-in, 2h & 1h before bedtime',
        NotificationMode.persistent =>
          'Morning + frequent reminders as bedtime approaches',
      };
}

// ── Step 4: Notification Permission ─────────────────────────────────────────

class _PermissionPage extends ConsumerWidget {
  const _PermissionPage({required this.onComplete});

  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 2),
          Icon(
            Icons.notifications_active_outlined,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.xl2),
          Text(
            'Stay on track',
            style: theme.textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Allow notifications so DayDone can remind you before bedtime. '
            'You can adjust this anytime in Settings.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 3),
          ElevatedButton(
            onPressed: () async {
              final service = ref.read(notificationServiceProvider);
              await service.requestPermissions();
              await ref
                  .read(settingsActionsProvider.notifier)
                  .updateNotificationPermissionAsked();
              onComplete();
            },
            child: const Text('Allow Notifications'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () async {
              await ref
                  .read(settingsActionsProvider.notifier)
                  .updateNotificationPermissionAsked();
              onComplete();
            },
            child: const Text('Not now'),
          ),
          const SizedBox(height: AppSpacing.xl2),
        ],
      ),
    );
  }
}
