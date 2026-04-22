import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_tracker/core/constants/route_constants.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/core/theme/app_theme.dart';
import 'package:todo_tracker/core/utils/bedtime_utils.dart';
import 'package:todo_tracker/core/utils/date_utils.dart';
import 'package:todo_tracker/core/widgets/daydone_bottom_nav.dart';
import 'package:todo_tracker/features/resolution/presentation/resolution_screen.dart';
import 'package:todo_tracker/features/settings/presentation/providers/settings_provider.dart';
import 'package:todo_tracker/features/settings/presentation/settings_screen.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_providers.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/today_summary_provider.dart';
import 'package:todo_tracker/features/tasks/presentation/screens/backlog_screen.dart';
import 'package:todo_tracker/features/tasks/presentation/screens/calendar_screen.dart';
import 'package:todo_tracker/features/tasks/presentation/screens/reports_placeholder_screen.dart';
import 'package:todo_tracker/features/tasks/presentation/screens/today_screen.dart';
import 'package:todo_tracker/features/tasks/presentation/task_create_screen.dart';
import 'package:todo_tracker/features/onboarding/presentation/onboarding_screen.dart';
import 'package:todo_tracker/features/tasks/presentation/task_edit_screen.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/daily_catchup_observer.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Creates the app router. Accepts a Ref so the resolution redirect
/// guard can read providers (settings + unresolved tasks).
GoRouter createAppRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteConstants.today,
    redirect: (context, state) async {
      final path = state.uri.path;

      // Redirect / to /today
      if (path == RouteConstants.home) {
        return RouteConstants.today;
      }

      // Onboarding guard: must complete onboarding before accessing the app.
      // Checked BEFORE the resolution guard.
      if (path != RouteConstants.onboarding) {
        final needsOnboarding = await _checkNeedsOnboarding(ref);
        if (needsOnboarding) {
          return RouteConstants.onboarding;
        }
      }

      // Resolution guard: when navigating to a main tab, check if bedtime
      // has passed with unresolved tasks.
      if (path == RouteConstants.today ||
          path == RouteConstants.calendar ||
          path == RouteConstants.backlog ||
          path == RouteConstants.reports ||
          path == RouteConstants.settings) {
        final needsResolution = await _checkNeedsResolution(ref);
        if (needsResolution) {
          return RouteConstants.resolution;
        }
      }

      return null;
    },
    routes: [
      // The main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => DailyCatchupObserver(child: child),
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                MainShell(navigationShell: navigationShell),
            branches: [
              // Tab 0: Today
              StatefulShellBranch(
                navigatorKey: _shellNavigatorKey,
                routes: [
                  GoRoute(
                    path: RouteConstants.today,
                    builder: (context, state) => const TodayScreen(),
                  ),
                ],
              ),
              // Tab 1: Calendar
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: RouteConstants.calendar,
                    builder: (context, state) => const CalendarScreen(),
                  ),
                ],
              ),
              // Tab 2: Backlog
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: RouteConstants.backlog,
                    builder: (context, state) => const BacklogScreen(),
                  ),
                ],
              ),
              // Tab 3: Reports (Phase 2 — placeholder; nav tab is non-interactive)
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: RouteConstants.reports,
                    builder: (context, state) =>
                        const ReportsPlaceholderScreen(),
                  ),
                ],
              ),
              // Tab 4: Settings
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: RouteConstants.settings,
                    builder: (context, state) => const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Full-screen overlay routes (outside the shell)
      GoRoute(
        path: RouteConstants.taskCreate,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const TaskCreateScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: RouteConstants.taskEdit,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: TaskEditScreen(taskId: id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.06),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
          );
        },
      ),
      GoRoute(
        path: RouteConstants.resolution,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ResolutionScreen(),
      ),
      GoRoute(
        path: RouteConstants.onboarding,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
}

/// Check if onboarding has not been completed yet.
/// Returns true if the user should be redirected to /onboarding.
Future<bool> _checkNeedsOnboarding(Ref ref) async {
  try {
    final settingsDao = ref.read(settingsDaoProvider);
    final settings = await settingsDao.getSettings();
    return !settings.onboardingCompleted;
  } catch (_) {
    return false;
  }
}

/// Check if the user needs to resolve a past day's tasks.
/// Returns true if bedtime has passed and there are unresolved tasks
/// for the logical date determined by [resolveLogicalDate].
Future<bool> _checkNeedsResolution(Ref ref) async {
  try {
    final settingsDao = ref.read(settingsDaoProvider);
    final settings = await settingsDao.getSettings();

    final now = DateTime.now();
    final logicalDate = resolveLogicalDate(
      now,
      settings.bedtime.hour,
      settings.bedtime.minute,
    );

    // null means bedtime hasn't passed — still in active day.
    if (logicalDate == null) return false;

    final taskDao = ref.read(taskDaoProvider);
    final unresolvedDated = await taskDao.getUnresolvedDatedTasks(logicalDate);
    final unresolvedDaily = await taskDao.getUnresolvedDailyInstances(
      logicalDate,
    );

    return unresolvedDated.isNotEmpty || unresolvedDaily.isNotEmpty;
  } catch (_) {
    return false;
  }
}

/// Shell with DayDone bottom nav (5 tabs + FAB), shared create-task FAB.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(todaySummaryProvider);
    final settingsAsync = ref.watch(settingsStreamProvider);
    final now = DateTime.now();

    var eveningFabGlow = false;
    if (settingsAsync.hasValue && summary.pending > 0) {
      final nextBed = nextBedtimeOccurrence(
        now,
        settingsAsync.requireValue.bedtime,
      );
      if (nextBed != null && nextBed.difference(now).inMinutes <= 45) {
        eveningFabGlow = true;
      }
    }
    final fabEvening = navigationShell.currentIndex == 0 && eveningFabGlow;

    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      extendBody: true,
      body: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          navigationShell,
          Positioned(
            left: 0,
            right: 0,
            bottom: safeBottom + 68 + 28,
            child: Center(
              child: _ShellCreateTaskFab(eveningUrgent: fabEvening),
            ),
          ),
        ],
      ),
      bottomNavigationBar: DayDoneBottomNav(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          if (index == 3) return;
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _ShellCreateTaskFab extends StatelessWidget {
  const _ShellCreateTaskFab({required this.eveningUrgent});

  final bool eveningUrgent;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final error = AppColors.errorColor(brightness);

    final glow = eveningUrgent
        ? [
            BoxShadow(
              color: error.withValues(alpha: 0.45),
              blurRadius: 16,
              spreadRadius: 8,
            ),
          ]
        : <BoxShadow>[];

    final baseShadow = brightness == Brightness.light
        ? AppTheme.fabShadowLight
        : AppTheme.fabShadowDark;

    return SizedBox(
      width: 56,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [...glow, ...baseShadow],
        ),
        child: FloatingActionButton(
          onPressed: () => context.push(RouteConstants.taskCreate),
          elevation: 0,
          highlightElevation: 0,
          child: Transform.translate(
            offset: Offset(0, -0.5),
            child: const Icon(Icons.add_rounded, size: 30, color: AppColors.onPrimary,),
          ),
        ),
      ),
    );
  }
}
