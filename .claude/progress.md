# DayDone — Development Progress

## Phase 1: MVP (Weeks 1–6)

### Week 1 — Foundation ✅
- Drift schema: Tasks table, DailyInstances table, migrations
- AppDatabase with all DAOs wired
- Core theme: AppColors, AppTypography, AppTheme
- AppConstants (completionThreshold, maxLabels, maxLabelChars)
- Priority, TaskStatus, TaskType enums

### Week 2 — Task Data Layer + CRUD Screens ✅ (2026-04-05)

**Data layer**
- `TaskDao` — full DAO with all query/mutation methods
- `TaskModel` — immutable domain model, `fromRow`, `copyWith` with null-clearing flags
- `TaskRepository` — bridges TaskDao ↔ TaskModel

**Providers**
- `task_providers.dart` — appDatabase, taskDao, taskRepository (keepAlive), allTasks, tasksForDate, distinctLabels streams/futures
- `task_action_provider.dart` — `TaskActions` notifier: createTask, updateTask, deleteTask, markDone, markClosed, snooze, undoDone, updatePriority, updateLabels + daily-instance variants

**Screens & Widgets**
- `TaskCreateScreen` — title, type toggle, date picker, PriorityPicker, LabelChipsInput, notes
- `TaskEditScreen` — pre-populated form, updates via taskActionsProvider
- `PriorityPicker` — 5-segment animated chip row using AppColors.priorityColors
- `LabelChipsInput` — autocomplete from distinctLabels, enforces maxLabels/maxLabelChars
- `TaskActionSheet` — context-sensitive actions (done, undo, snooze, close)

**Routing**
- `route_constants.dart` — home, taskCreate, taskEdit path helpers
- `app_router.dart` — GoRouter with all 3 routes wired
- `app.dart` — switched to `MaterialApp.router`

**Quality**
- `dart analyze`: 0 errors, 0 warnings, 4 pre-existing infos (withOpacity deprecations in Week 1 theme)
- `build_runner` ran clean twice

### Week 3 — Today View + Filtering (2026-04-05)
Status: COMPLETE
Deliverables:
- [x] today_tasks_provider.dart — StreamProvider combining dated+daily tasks, sorted by status group > priority > sort_order
- [x] today_summary_provider.dart — Derived provider computing total/pending/done/closed/snoozed counts and completion fraction
- [x] TaskTile widget — Priority left border, title styling (bold urgent, strikethrough done), label chips (max 3 + overflow), status icon
- [x] FilterChipBar widget — Horizontal scroll, priority chips (OR) + label chips (AND), hidden when no filters available
- [x] TodayScreen — 4 grouped sections (Pending/Snoozed/Done/Closed), filter bar, empty states
- [x] PendingCountBadge + DailyProgressBar — Summary UI widgets driven by today_summary_provider
- [x] DailyCatchupObserver — AppLifecycleState.resumed triggers instantiateDailyTasks, wired via ShellRoute
Exit criteria met: YES
Notes:
- TodayTask domain model created to unify dated tasks and daily instances
- No rxdart dependency added; used StreamController-based combiner instead
- Router updated: ShellRoute wraps DailyCatchupObserver around all routes
- 0 new warnings/errors; only pre-existing 4 withOpacity infos from Week 1 theme
### Week 4 — Calendar, Backlog & Shell Navigation (2026-04-05)
Status: COMPLETE
Deliverables:
- [x] Added `table_calendar: ^3.1.2` dependency
- [x] TaskDao: `watchAllDatedTasks()` and `watchTaskCountsForMonth(year, month)` for calendar dots
- [x] TaskRepository: bridge methods for new DAO queries
- [x] `calendar_provider.dart` — family provider keyed on (year, month) for dot indicators
- [x] `backlog_provider.dart` — stream provider for all dated tasks
- [x] CalendarScreen — TableCalendar with month nav, dot indicators, inline date task list with combined dated+daily tasks
- [x] BacklogScreen — future dated tasks grouped by date ascending, empty state, date headers (Today/Tomorrow/formatted)
- [x] FilterChipBar wired into both CalendarScreen date list and BacklogScreen
- [x] ShellRoute rewritten: StatefulShellRoute.indexedStack with MainShell (BottomNavigationBar)
- [x] 3 tabs: Today (Tab 0), Calendar (Tab 1), Backlog (Tab 2)
- [x] Task create/edit routes outside shell as full-screen overlays
- [x] DailyCatchupObserver wraps the shell
- [x] RouteConstants updated with /today, /calendar, /backlog + redirect from / to /today
Exit criteria met: YES
Notes:
- 0 new warnings/errors; only pre-existing 4 withOpacity infos from Week 1 theme
- Calendar date list reuses TodayTask/TaskTile/FilterChipBar from Week 3
- build_runner ran clean after new providers added
### Week 5 — Notifications, Settings, Resolution (2026-04-05)
Status: COMPLETE
Deliverables:
- [x] SettingsDao — already existed with all required methods (watchSettings, getSettings, updateBedtime, updateMorningCheckin, updateNotificationMode, completeOnboarding, updateNotificationPermissionAsked)
- [x] Settings providers — settingsDao, settingsStream (StreamProvider), SettingsActions notifier (Riverpod code-gen)
- [x] notification_constants.dart — NotificationIds, NotificationChannels, NotificationContent templates, NotificationType enum, NotificationModeConfig
- [x] NotificationScheduler — pure-logic computeSchedule() with bedtime resolution, mode filtering, time-based pruning
- [x] NotificationService — wraps flutter_local_notifications, init, requestPermissions, createChannels (standard + critical), scheduleNotification, cancelAll, cancelById, showImmediate
- [x] notification_utils.dart — orchestration: reschedule, handleAllTasksResolved (all-done-early logic), onBedtimeChanged
- [x] Notification providers — notificationService, notificationScheduler, notificationUtils, notificationRescheduleTrigger (watches settings + today summary)
- [x] Settings screen — bedtime picker (6PM-3AM, 15-min), morning check-in picker (5AM-12PM), notification mode selector (minimal/standard/persistent), follows design system
- [x] Resolution DAO + Provider — TaskDao: getUnresolvedDatedTasks, getUnresolvedDailyInstances, rescheduleTask; TaskRepository bridge methods; unresolvedTasks provider, ResolutionActions notifier
- [x] Resolution screen — lists unresolved tasks, Done/Tomorrow/Close per task, PopScope blocks dismissal, daily instances resolved correctly, navigates to /today on completion
- [x] Route updates + resolution guard — RouteConstants: /settings, /resolution; createAppRouter with Ref; resolution redirect guard checks bedtime + unresolved tasks; settings icon on TodayScreen; appRouter Riverpod provider in app.dart
- [x] Unit tests for NotificationScheduler — 16 tests: all 3 modes, 0 pending, past filtering, bedtime after midnight, singular/plural content, sort order, edge cases — all passing
Exit criteria met: YES
Notes:
- Added timezone ^0.10.0 as explicit dependency (was transitive via flutter_local_notifications)
- Router refactored: appRouter is now a Riverpod provider (via code-gen) to support resolution guard reading providers
- No workmanager for midnight instantiation yet (Week 6 deliverable)
- 0 new warnings/errors; only pre-existing dead_code in settings_dao and 4 withOpacity infos from Week 1 theme
### Week 6 — Workmanager, Onboarding & Final Wiring (2026-04-05)
Status: COMPLETE
Deliverables:
- [x] Added `workmanager: ^0.5.2` dependency to pubspec.yaml
- [x] `workmanager_service.dart` — background callback with isolated DB + TaskDao for midnight daily task instantiation, periodic 24h registration with initial delay to next midnight
- [x] Wired `WorkmanagerService.init()` into `main.dart`
- [x] Added `/onboarding` route constant to `route_constants.dart`
- [x] `OnboardingScreen` — 4-step PageView flow: Welcome (not skippable), Bedtime setup (skippable), Notification mode (skippable), Notification permission (skippable). All UI state via Riverpod code-gen notifiers (OnboardingPage, OnboardingBedtimeIndex, OnboardingNotificationMode). Settings persisted via settingsActionsProvider. Design system compliant (AppSpacing, AppRadius, theme.textTheme).
- [x] Onboarding route + redirect guard in `app_router.dart` — checks `settings.onboardingCompleted` BEFORE resolution guard; GoRoute for `/onboarding` pointing to OnboardingScreen
- [x] build_runner passes with 0 errors
- [x] `dart analyze`: 0 errors, 0 new warnings (only pre-existing dead_code + withOpacity infos)
- [x] Flutter reviewer: 0 violations found
Exit criteria met: YES
Notes:
- Most Week 6 deliverables (notifications, settings, resolution, unit tests) were completed during Week 5
- Remaining items (workmanager, onboarding, onboarding guard) completed in this session
- No new Drift schema changes required

## Phase 1 — COMPLETE
All 6 weeks of Phase 1 MVP delivered. Features implemented:
- Task CRUD with priority and labels
- Today/Calendar/Backlog views with filtering
- Notification scheduling (3 modes) with flutter_local_notifications
- Settings screen (bedtime, morning check-in, notification mode)
- End-of-day resolution screen with dismissal blocking
- Onboarding flow (4 steps)
- Background daily task instantiation via workmanager
- Router guards (onboarding + resolution)
- Full Riverpod code-gen state management, Drift DAOs, go_router navigation
