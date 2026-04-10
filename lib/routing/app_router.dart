import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_tracker/core/constants/route_constants.dart';
import 'package:todo_tracker/features/resolution/presentation/resolution_screen.dart';
import 'package:todo_tracker/features/settings/presentation/providers/settings_provider.dart';
import 'package:todo_tracker/features/settings/presentation/settings_screen.dart';
import 'package:todo_tracker/core/utils/date_utils.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/task_providers.dart';
import 'package:todo_tracker/features/tasks/presentation/screens/backlog_screen.dart';
import 'package:todo_tracker/features/tasks/presentation/screens/calendar_screen.dart';
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
          path == RouteConstants.backlog) {
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
        builder: (context, state, child) =>
            DailyCatchupObserver(child: child),
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
            ],
          ),
        ],
      ),

      // Full-screen overlay routes (outside the shell)
      GoRoute(
        path: RouteConstants.taskCreate,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TaskCreateScreen(),
      ),
      GoRoute(
        path: RouteConstants.taskEdit,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TaskEditScreen(taskId: id);
        },
      ),
      GoRoute(
        path: RouteConstants.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
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
    final unresolvedDated =
        await taskDao.getUnresolvedDatedTasks(logicalDate);
    final unresolvedDaily =
        await taskDao.getUnresolvedDailyInstances(logicalDate);

    return unresolvedDated.isNotEmpty || unresolvedDaily.isNotEmpty;
  } catch (_) {
    return false;
  }
}

/// Scaffold shell providing BottomNavigationBar for the 3 main tabs.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Backlog',
          ),
        ],
      ),
    );
  }
}
