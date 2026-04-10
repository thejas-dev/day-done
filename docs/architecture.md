# Architecture Plan: DayDone

## Executive Summary

DayDone is an offline-first Flutter todo app with end-of-day accountability, quantified tasks, task priority/labels, a read-only reports/analytics screen, and social accountability pods. The architecture uses Drift (SQLite) as the local source of truth, Riverpod (code-gen) for reactive state management, and a phased backend rollout: Phases 1-2 are fully local with no server dependency, while Phase 3 introduces a Node.js microservices backend on GCP Cloud Run backed by Firebase Auth, Firestore (real-time pod data), and MongoDB (analytics/notification logs). Notifications are scheduled locally via `flutter_local_notifications` + `workmanager` in Phases 1-2, transitioning to server-driven FCM/APNs for pod triggers in Phase 3. Task priority (5-level enum) and labels (JSON array, max 5) are stored on the task row with a schema migration (v3→v4); the Reports screen at `/reports` provides per-day completion charts, streak summaries, and priority/label breakdowns over selectable date ranges.

---

## Requirements Analysis

### Functional Requirements
- CRUD tasks with two types: `daily` (recurring) and `dated` (one-off)
- Quantified tasks with numeric targets, progress logging, 80% completion threshold
- End-of-day resolution flow forcing disposition of all unresolved tasks
- Configurable notification schedule relative to user-set bedtime (6 PM - 3 AM range)
- DND bypass via iOS Critical Alerts and Android full-screen intents
- Streaks calculated from daily task resolution history
- Accountability Pods (2-5 members) with privacy-controlled task sharing
- Onboarding flow (4 steps, skippable from step 2)
- Three views: Today, Calendar/Date, All Tasks/Backlog
- Offline-first: full functionality without network in Phases 1-2
- **Task Priority:** user-assigned priority (`none` | `low` | `medium` | `high` | `urgent`) with visual treatment on task tiles and priority-based sorting within status groups
- **Task Labels:** user-defined string tags (max 5 per task, max 30 chars each) stored as JSON array, with inline chip display, suggestion-based input, and filtering across views
- **Reports / Progress screen:** read-only analytics view at `/reports` showing per-day completion bar chart, streak summary, priority breakdown, label breakdown, and filters (by label, priority, task name substring, task type) over a selectable date range (default: last 7 days)

### Non-Functional Requirements
- Cross-platform: iOS, Android, macOS, Windows, Linux, Web (6 targets)
- Local-first data with eventual consistency sync in Phase 3
- Sub-100ms UI response for task actions (local DB operations)
- Battery-efficient background work (midnight rollover, notification scheduling)
- Privacy: task notes and bedtime config never leave the device
- Notification reliability across Android OEM background restrictions

### Assumptions & Open Questions
- **Scale assumption:** 10K-50K users at Phase 3 launch; pod sizes capped at 5 members
- **Single pod per user in v1** simplifies relationship model significantly
- **Web platform:** notifications limited to web push API (no DND bypass, no Critical Alerts); desktop platforms (macOS/Windows/Linux) use system notification APIs without DND bypass
- **Assumption:** midnight daily task instantiation on mobile uses `workmanager`; on desktop/web, it runs on app foreground with catch-up logic

---

## Tech Stack Summary

| Component | Technology | Reason |
|---|---|---|
| UI Framework | Flutter 3.x (Dart 3.x) | Cross-platform targeting all 6 platforms |
| State Management | Riverpod (code-gen: `riverpod_annotation` + `riverpod_generator`) | Compile-safe providers, auto-dispose, testable; code-gen reduces boilerplate |
| Local Database | Drift 2.x (SQLite) | Type-safe SQL, migrations, DAOs, reactive streams, cross-platform SQLite |
| Navigation | go_router | Declarative routing, deep-link support, ShellRoute for tab layouts |
| Networking | Dio 5.x | Interceptors for auth headers, retry, offline queue; widely adopted |
| Push Notifications | `firebase_messaging` (FCM) + `flutter_local_notifications` | FCM for server-driven push (Phase 3); local notifications for Phases 1-2 |
| Background Work | `workmanager` (mobile), foreground catch-up (desktop/web) | Midnight task rollover, notification rescheduling |
| Backend Runtime | Node.js 20 LTS + Fastify | Fastify: faster than Express, built-in schema validation, plugin ecosystem |
| API Gateway | Fastify + `@fastify/rate-limit` + `@fastify/http-proxy` | Lightweight reverse proxy with auth middleware |
| Auth | Firebase Auth (email/password, Apple, Google OAuth) | Managed auth with JWT, no custom password storage |
| Primary Database | Firestore | Real-time listeners for pod data, serverless scaling, Firebase ecosystem |
| Secondary Database | MongoDB Atlas | Complex aggregation queries for notification evaluation, analytics |
| Job Queue | BullMQ + Redis (Cloud Memorystore) | Reliable cron-like scheduling for notification evaluation |
| Push Dispatch | FCM (Android/Web) + APNs (iOS/macOS) via `firebase-admin` | Unified push through Firebase with direct APNs for Critical Alerts |
| CI/CD | GitHub Actions | Flutter build matrix, Node.js service builds, Firebase deploy |
| Container Runtime | GCP Cloud Run | Serverless containers, auto-scaling, pay-per-use |
| Infra-as-Code | Terraform (GCP provider) | Reproducible infrastructure |

---

## Flutter (Mobile) Architecture

### Folder / Module Structure

```
lib/
├── main.dart                          # Entry point: ProviderScope, GoRouter setup
├── app.dart                           # MaterialApp.router widget, theme config
│
├── core/                              # Shared infrastructure (no feature logic)
│   ├── constants/
│   │   ├── app_constants.dart         # COMPLETION_THRESHOLD = 0.8, etc.
│   │   ├── notification_constants.dart# Channel IDs, category identifiers
│   │   └── route_constants.dart       # Route path strings
│   ├── database/
│   │   ├── app_database.dart          # Drift @DriftDatabase class, migration strategy
│   │   ├── app_database.g.dart        # Generated
│   │   ├── tables/                    # Drift table definitions
│   │   │   ├── tasks_table.dart
│   │   │   ├── daily_instances_table.dart
│   │   │   ├── progress_logs_table.dart
│   │   │   ├── settings_table.dart
│   │   │   ├── streaks_table.dart
│   │   │   ├── sync_queue_table.dart       # Phase 3
│   │   │   ├── pod_members_table.dart      # Phase 3
│   │   │   └── pod_cache_table.dart        # Phase 3
│   │   ├── daos/
│   │   │   ├── task_dao.dart
│   │   │   ├── daily_instance_dao.dart
│   │   │   ├── progress_log_dao.dart
│   │   │   ├── settings_dao.dart
│   │   │   ├── reports_dao.dart            # Aggregate queries for Reports screen
│   │   │   ├── streak_dao.dart
│   │   │   ├── sync_queue_dao.dart         # Phase 3
│   │   │   └── pod_dao.dart                # Phase 3
│   │   └── converters/
│   │       ├── uuid_converter.dart
│   │       └── json_converter.dart
│   ├── extensions/
│   │   ├── date_time_extensions.dart  # localDate, isToday, startOfDay
│   │   └── string_extensions.dart
│   ├── theme/
│   │   ├── app_theme.dart             # Light/dark ThemeData
│   │   ├── app_colors.dart
│   │   └── app_typography.dart
│   ├── utils/
│   │   ├── date_utils.dart            # Timezone-safe date handling
│   │   ├── notification_utils.dart    # Schedule calculation from bedtime
│   │   └── platform_utils.dart        # Platform capability checks
│   └── widgets/                       # Shared reusable widgets
│       ├── progress_bar.dart          # Amber/green/full-green bar
│       ├── task_tile.dart
│       ├── confirmation_dialog.dart
│       └── empty_state.dart
│
├── features/
│   ├── today/                         # Phase 1 — Today View
│   │   ├── presentation/
│   │   │   ├── today_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── today_task_list.dart
│   │   │   │   ├── pending_count_badge.dart
│   │   │   │   └── daily_progress_bar.dart
│   │   │   └── today_screen_controller.dart  # If needed for complex UI logic
│   │   └── providers/
│   │       ├── today_tasks_provider.dart
│   │       └── today_summary_provider.dart
│   │
│   ├── task/                          # Phase 1 — Task CRUD & actions
│   │   ├── domain/
│   │   │   ├── task_model.dart        # Immutable Dart model (not Drift row); includes priority (Priority enum) and labels (List<String>)
│   │   │   ├── task_status.dart       # Enum: pending, done, closed, snoozed
│   │   │   ├── task_type.dart         # Enum: daily, dated
│   │   │   ├── priority.dart          # Enum: none, low, medium, high, urgent (int-mapped for Drift intEnum)
│   │   │   └── task_action.dart       # Sealed class for task mutations
│   │   ├── data/
│   │   │   └── task_repository.dart   # Bridges DAO ↔ domain models
│   │   ├── presentation/
│   │   │   ├── task_create_screen.dart
│   │   │   ├── task_edit_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── task_form.dart
│   │   │   │   ├── priority_picker.dart   # Segmented control / selectable row for none|low|medium|high|urgent
│   │   │   │   ├── label_chips_input.dart # Text field with suggestion dropdown + dismissible chips (max 5, 30 char limit)
│   │   │   │   ├── snooze_picker.dart
│   │   │   │   ├── quantified_input.dart  # Phase 2
│   │   │   │   └── progress_logger.dart   # Phase 2
│   │   │   └── task_action_sheet.dart     # Bottom sheet for Mark Done, Snooze, etc.
│   │   └── providers/
│   │       ├── task_providers.dart         # CRUD providers
│   │       └── task_action_provider.dart   # Action execution provider
│   │
│   ├── calendar/                      # Phase 1 — Calendar/Date View
│   │   ├── presentation/
│   │   │   ├── calendar_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── month_calendar.dart
│   │   │   │   ├── date_indicator.dart
│   │   │   │   └── date_task_list.dart
│   │   └── providers/
│   │       ├── calendar_provider.dart
│   │       └── date_tasks_provider.dart
│   │
│   ├── backlog/                       # Phase 1 — All Tasks/Backlog View
│   │   ├── presentation/
│   │   │   ├── backlog_screen.dart
│   │   │   └── widgets/
│   │   │       └── date_grouped_list.dart
│   │   └── providers/
│   │       └── backlog_provider.dart
│   │
│   ├── reports/                       # Phase 1 — Progress / Reports Screen (read-only analytics)
│   │   ├── data/
│   │   │   └── reports_repository.dart   # Queries ReportsDao, transforms rows → domain models, applies filters
│   │   ├── domain/
│   │   │   ├── report_model.dart         # DailyReportSummary (date, total, done, closed, pending, completionRate)
│   │   │   └── report_filter.dart        # Value object: { dateRange, labels?, priorities?, titleSubstring?, taskType? }
│   │   ├── presentation/
│   │   │   ├── reports_screen.dart        # Top-level read-only screen at /reports
│   │   │   └── widgets/
│   │   │       ├── date_range_picker.dart         # Start/end date selection; default last 7 days
│   │   │       ├── completion_chart.dart           # Bar chart (≤30 days) or sparkline (>30 days); 80% ref line
│   │   │       ├── summary_metrics_card.dart       # Tasks created, completed, closed, pending, overall rate
│   │   │       ├── priority_breakdown_table.dart   # Per-priority: total, completed, missed, rate
│   │   │       ├── label_breakdown_table.dart      # Per-label: total, completed, missed, rate
│   │   │       └── reports_filter_panel.dart       # Filter icon → panel: by label, priority, name, type
│   │   └── providers/
│   │       └── reports_provider.dart     # @riverpod code-gen; family param = ReportFilter; returns ReportData
│   │
│   ├── resolution/                    # Phase 1 — End-of-Day Resolution
│   │   ├── presentation/
│   │   │   ├── resolution_screen.dart
│   │   │   └── widgets/
│   │   │       ├── unresolved_task_card.dart
│   │   │       └── resolution_action_row.dart  # Done | Move | Close
│   │   └── providers/
│   │       └── resolution_provider.dart
│   │
│   ├── notifications/                 # Phase 1 — Local notification scheduling
│   │   ├── services/
│   │   │   ├── notification_scheduler.dart     # Computes schedule from bedtime
│   │   │   ├── notification_service.dart       # flutter_local_notifications wrapper
│   │   │   └── background_service.dart         # workmanager callbacks
│   │   └── providers/
│   │       └── notification_providers.dart
│   │
│   ├── settings/                      # Phase 1 — User settings
│   │   ├── presentation/
│   │   │   ├── settings_screen.dart
│   │   │   └── widgets/
│   │   │       ├── bedtime_picker.dart
│   │   │       ├── morning_checkin_picker.dart
│   │   │       └── notification_mode_selector.dart
│   │   └── providers/
│   │       └── settings_provider.dart
│   │
│   ├── onboarding/                    # Phase 1 — Onboarding flow
│   │   ├── presentation/
│   │   │   ├── onboarding_screen.dart
│   │   │   └── steps/
│   │   │       ├── bedtime_step.dart
│   │   │       ├── morning_checkin_step.dart
│   │   │       ├── first_task_step.dart
│   │   │       └── notification_permission_step.dart
│   │   └── providers/
│   │       └── onboarding_provider.dart
│   │
│   ├── streaks/                       # Phase 2 — Streak tracking
│   │   ├── presentation/
│   │   │   └── streak_badge.dart
│   │   └── providers/
│   │       └── streak_provider.dart
│   │
│   ├── quantified/                    # Phase 2 — Quantified task extensions
│   │   └── providers/
│   │       └── quantified_task_provider.dart
│   │
│   ├── auth/                          # Phase 3 — Authentication
│   │   ├── presentation/
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   └── widgets/
│   │   │       └── social_login_buttons.dart
│   │   ├── data/
│   │   │   └── auth_repository.dart
│   │   └── providers/
│   │       └── auth_providers.dart
│   │
│   ├── sync/                          # Phase 3 — Backend sync
│   │   ├── services/
│   │   │   ├── sync_engine.dart       # Offline queue processing
│   │   │   ├── conflict_resolver.dart # Last-write-wins + progress log merge
│   │   │   └── privacy_filter.dart    # Strips private fields before upload
│   │   └── providers/
│   │       └── sync_providers.dart
│   │
│   └── pods/                          # Phase 3 — Accountability Pods
│       ├── domain/
│       │   ├── pod_model.dart
│       │   └── pod_member_model.dart
│       ├── data/
│       │   └── pod_repository.dart
│       ├── presentation/
│       │   ├── pod_tab_screen.dart
│       │   ├── pod_invite_screen.dart
│       │   ├── pod_settings_screen.dart
│       │   └── widgets/
│       │       ├── member_card.dart
│       │       ├── completion_ring.dart
│       │       └── shared_task_tile.dart
│       └── providers/
│           └── pod_providers.dart
│
├── routing/
│   ├── app_router.dart                # GoRouter configuration
│   └── route_guards.dart              # Auth redirect, onboarding redirect, resolution guard
│
└── services/                          # App-wide singleton services
    ├── dio_client.dart                # Phase 3: Dio instance with interceptors
    ├── interceptors/
    │   ├── auth_interceptor.dart      # Phase 3: Attach JWT
    │   ├── retry_interceptor.dart     # Phase 3: Exponential backoff
    │   └── offline_queue_interceptor.dart  # Phase 3: Queue when offline
    └── fcm_service.dart               # Phase 3: FCM token registration
```

### Feature Breakdown by Phase

| Phase | Features | Modules |
|---|---|---|
| **Phase 1 (MVP)** | Task CRUD (with priority & labels), Today View, Calendar View, Backlog View, Reports/Progress Screen, End-of-Day Resolution, Local Notifications, Settings, Onboarding | `task`, `today`, `calendar`, `backlog`, `reports`, `resolution`, `notifications`, `settings`, `onboarding` |
| **Phase 2 (Hardening)** | Quantified Tasks (numeric targets, progress logging, 80% rule), Streaks, Skip Today for daily tasks | `quantified`, `streaks` + extensions in `task` |
| **Phase 3 (Scale)** | Auth, Backend Sync, Accountability Pods, Server-driven notifications, FCM push, Pod triggers | `auth`, `sync`, `pods` + `services/dio_client.dart`, `services/fcm_service.dart` |

### Local Data Layer (Drift)

#### Schema Design

```dart
// ============================================================
// lib/core/database/tables/tasks_table.dart
// ============================================================

class Tasks extends Table {
  TextColumn get id => text()();                           // UUID v4, primary key
  TextColumn get title => text().withLength(max: 200)();
  TextColumn get notes => text().nullable().withLength(max: 1000)();
  IntColumn get type => intEnum<TaskType>()();             // 0=daily, 1=dated
  DateTimeColumn get date => dateTime().nullable()();      // Local date stored as midnight UTC
  IntColumn get status => intEnum<TaskStatus>()();         // 0=pending, 1=done, 2=closed, 3=snoozed
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get snoozeUntil => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isQuantified => boolean().withDefault(const Constant(false))();
  RealColumn get targetValue => real().nullable()();
  TextColumn get targetUnit => text().nullable().withLength(max: 12)();
  RealColumn get progressValue => real().withDefault(const Constant(0.0))();
  TextColumn get targetHistory => text().nullable()();     // JSON: [{target_value, changed_at}]
  BoolColumn get podVisible => boolean().withDefault(const Constant(false))();
  IntColumn get priority => intEnum<Priority>()();           // 0=none, 1=low, 2=medium, 3=high, 4=urgent; default none
  TextColumn get labels => text().withDefault(const Constant('[]'))(); // JSON array of strings, max 5 items, each max 30 chars; uses json_converter
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))(); // Soft delete
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();    // Phase 3

  @override
  Set<Column> get primaryKey => {id};
}

// NOTE on label storage strategy:
// Labels are stored denormalized as a JSON array on the task row rather than in a
// separate labels/task_labels junction table. Rationale:
//   1. Phase 1 simplicity — no join queries, no foreign key maintenance.
//   2. Max 5 labels per task keeps the JSON payload trivially small.
//   3. The suggestion list is derived on-demand via a DISTINCT scan over the tasks
//      table's labels column — no separate lookup table to keep in sync.
//   4. Avoids sync complexity in Phase 3 (no extra table to reconcile).
// Trade-off: querying "all tasks with label X" requires a JSON LIKE/contains scan.
// At Phase 1 local-only scale (< 1000 tasks) this is negligible. If it becomes a
// bottleneck, a generated column + index or a junction table can be introduced in a
// future migration.

// ============================================================
// lib/core/database/tables/daily_instances_table.dart
// ============================================================
// Tracks per-day instantiation of daily tasks.
// A daily task has one row in `tasks` (the template) and one row
// per day in `daily_instances` (the actual resolved state).

class DailyInstances extends Table {
  TextColumn get id => text()();                           // UUID v4
  TextColumn get taskId => text().references(Tasks, #id)();
  DateTimeColumn get date => dateTime()();                 // The date this instance is for
  IntColumn get status => intEnum<TaskStatus>()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  RealColumn get progressValue => real().withDefault(const Constant(0.0))();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();
  IntColumn get priority => intEnum<Priority>().nullable()(); // Overrides template priority for this instance; null = inherit from template
  TextColumn get labels => text().nullable()();               // Overrides template labels for this instance; null = inherit from template; JSON array

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// lib/core/database/tables/progress_logs_table.dart
// ============================================================

class ProgressLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get taskId => text()();                       // References tasks.id or daily_instances.id
  RealColumn get value => real()();
  DateTimeColumn get recordedAt => dateTime()();

  @override
  List<Set<Column>>? get uniqueKeys => [{taskId, recordedAt}]; // Dedup key
}

// ============================================================
// lib/core/database/tables/settings_table.dart
// ============================================================
// Single-row table for user preferences.

class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  DateTimeColumn get bedtime => dateTime()();              // Time-of-day stored as DateTime (date part ignored)
  DateTimeColumn get morningCheckin => dateTime()();
  IntColumn get notificationMode => intEnum<NotificationMode>()(); // 0=minimal, 1=standard, 2=persistent
  BoolColumn get onboardingCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get notificationPermissionAsked => boolean().withDefault(const Constant(false))();
  IntColumn get notificationBannerDismissals => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastBannerDismissedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// lib/core/database/tables/streaks_table.dart
// ============================================================
// Precomputed streak data, updated nightly.

class Streaks extends Table {
  DateTimeColumn get date => dateTime()();                 // The date
  BoolColumn get allResolved => boolean()();               // Were all tasks resolved?
  BoolColumn get hasExcusedOnly => boolean().withDefault(const Constant(false))(); // All skipped = excused
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {date};
}

// ============================================================
// lib/core/database/tables/sync_queue_table.dart (Phase 3)
// ============================================================

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();                   // 'task', 'daily_instance', 'progress_log'
  TextColumn get entityId => text()();
  TextColumn get action => text()();                       // 'create', 'update', 'delete'
  TextColumn get payload => text()();                      // JSON serialized change
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}
```

#### Key Indices

```dart
// In tasks table
@TableIndex(name: 'idx_tasks_type_status', columns: {#type, #status})
@TableIndex(name: 'idx_tasks_date', columns: {#date})
@TableIndex(name: 'idx_tasks_is_deleted', columns: {#isDeleted})
@TableIndex(name: 'idx_tasks_priority', columns: {#priority})          // For priority-based queries and reports breakdown

// In daily_instances table
@TableIndex(name: 'idx_daily_task_date', columns: {#taskId, #date}, unique: true)
@TableIndex(name: 'idx_daily_date', columns: {#date})

// In progress_logs table — unique key on {taskId, recordedAt} handles dedup

// In sync_queue table
@TableIndex(name: 'idx_sync_unsynced', columns: {#synced, #createdAt})
```

#### DAO Interfaces

```dart
// lib/core/database/daos/task_dao.dart
@DriftAccessor(tables: [Tasks, DailyInstances])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  // --- Queries ---
  Stream<List<Task>> watchTodayTasks(DateTime today);          // daily instances + dated for today
  Stream<List<Task>> watchTasksForDate(DateTime date);
  Stream<List<Task>> watchAllDatedTasks();                     // Backlog
  Future<List<Task>> getUnresolvedTasks(DateTime date);        // For resolution screen
  Stream<int> watchPendingCount(DateTime today);

  // --- Mutations ---
  Future<void> insertTask(TasksCompanion task);
  Future<void> updateTask(String id, TasksCompanion updates);
  Future<void> softDeleteTask(String id);
  Future<void> markDone(String id, DateTime resolvedAt);
  Future<void> undoDone(String id);                            // Revert to pending if before midnight
  Future<void> snoozeTask(String id, DateTime snoozeUntil);
  Future<void> closeTask(String id, DateTime resolvedAt);
  Future<void> skipDailyInstance(String instanceId);
  Future<void> reschedule(String id, DateTime newDate);        // Dated only

  // --- Priority & Label queries ---
  Stream<List<Task>> watchTasksByPriority(Priority priority);  // All non-deleted tasks at a given priority
  Stream<List<Task>> watchTasksByLabel(String label);          // All non-deleted tasks whose labels JSON contains the given string
  Future<List<String>> getDistinctLabels();                    // Derived suggestion list: SELECT DISTINCT across all task label arrays

  // --- Daily instantiation ---
  Future<void> instantiateDailyTasks(DateTime today);          // Create DailyInstance rows
}

// lib/core/database/daos/progress_log_dao.dart
@DriftAccessor(tables: [ProgressLogs])
class ProgressLogDao extends DatabaseAccessor<AppDatabase> with _$ProgressLogDaoMixin {
  Future<void> logProgress(String taskId, double value, DateTime recordedAt);
  Stream<List<ProgressLog>> watchLogsForTask(String taskId);
  Future<void> mergeProgressLogs(String taskId, List<ProgressLog> incoming); // Phase 3 sync
}

// lib/core/database/daos/settings_dao.dart
@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  Stream<Setting> watchSettings();
  Future<void> updateBedtime(DateTime bedtime);
  Future<void> updateMorningCheckin(DateTime time);
  Future<void> updateNotificationMode(NotificationMode mode);
  Future<void> completeOnboarding();
}

// lib/core/database/daos/reports_dao.dart
// Dedicated DAO for aggregate read queries used by the Reports screen.
// Separated from TaskDao to keep action/mutation concerns out of analytics code.
@DriftAccessor(tables: [Tasks, DailyInstances])
class ReportsDao extends DatabaseAccessor<AppDatabase> with _$ReportsDaoMixin {
  /// Returns per-day task counts (total, done, closed, pending/overdue) for each
  /// day in [startDate..endDate]. Combines dated tasks and daily instances.
  Future<List<DailyReportRow>> getTasksPerDayInRange(DateTime startDate, DateTime endDate);

  /// Returns completion counts grouped by priority level within [startDate..endDate].
  /// Each row: { priority, total, completed, missed }.
  Future<List<PriorityBreakdownRow>> getCompletionByPriority(DateTime startDate, DateTime endDate);

  /// Returns completion counts grouped by label within [startDate..endDate].
  /// A task with N labels contributes to N rows. Each row: { label, total, completed, missed }.
  Future<List<LabelBreakdownRow>> getCompletionByLabel(DateTime startDate, DateTime endDate);

  /// Returns the raw task list for [startDate..endDate] matching the given filters,
  /// used by the reports repository to compute summary metrics client-side.
  Future<List<Task>> getFilteredTasksInRange({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? labels,           // OR within labels
    List<Priority>? priorities,     // OR within priorities
    String? titleSubstring,         // Case-insensitive LIKE
    TaskType? taskType,             // daily, dated, or null for both
  });
}
```

#### Migration Strategy

```dart
// lib/core/database/app_database.dart
@DriftDatabase(
  tables: [Tasks, DailyInstances, ProgressLogs, Settings, Streaks, SyncQueue, PodMembers, PodCache],
  daos: [TaskDao, DailyInstanceDao, ProgressLogDao, SettingsDao, ReportsDao, StreakDao, SyncQueueDao, PodDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;  // Bump per phase; v4 adds priority + labels

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v1 → v2: Add streaks table, add targetHistory to tasks
      if (from < 2) {
        await m.createTable(streaks);
        await m.addColumn(tasks, tasks.targetHistory);
      }
      // v2 → v3: Add sync_queue, pod_members, pod_cache; add syncVersion to tasks
      if (from < 3) {
        await m.createTable(syncQueue);
        await m.createTable(podMembers);
        await m.createTable(podCache);
        await m.addColumn(tasks, tasks.syncVersion);
      }
      // v3 → v4: Add priority and labels columns to tasks and daily_instances
      // Existing tasks default to priority=none (0) and labels='[]'.
      // Existing daily_instances default to null (inherit from template).
      if (from < 4) {
        await m.addColumn(tasks, tasks.priority);
        await m.addColumn(tasks, tasks.labels);
        await m.addColumn(dailyInstances, dailyInstances.priority);
        await m.addColumn(dailyInstances, dailyInstances.labels);
      }
    },
  );
}
```

#### Daily Task Instantiation at Midnight

**Mobile (iOS/Android):** `workmanager` periodic task registered at app startup with `Workmanager().registerPeriodicTask('daily-rollover', 'dailyRollover', frequency: Duration(hours: 1))`. The callback:

1. Opens the Drift database in the background isolate.
2. Calls `taskDao.instantiateDailyTasks(DateTime.now().localDate)`.
3. Recalculates and reschedules all local notifications for the new day via `notificationScheduler.rescheduleAll()`.
4. Updates streak data for the previous day.

**Desktop/Web:** No reliable background execution. On `AppLifecycleState.resumed` (foreground), check if today's daily instances exist. If not, run instantiation. This catch-up mechanism also handles the case where `workmanager` was killed by the OS on mobile.

**Edge case -- timezone change:** On foreground resume, compare the device's current local date against the last-known local date stored in `Settings`. If they differ (DST shift, travel), re-run instantiation for the correct date and reschedule notifications.

---

### State Management (Riverpod)

All providers use the code-generation variant (`@riverpod` annotation). The naming convention below omits the `Provider` suffix that code-gen appends automatically.

#### Provider Inventory

| Provider Name | Type | Dependencies | Purpose |
|---|---|---|---|
| `appDatabase` | `Provider<AppDatabase>` | None | Singleton database instance |
| `taskDao` | `Provider<TaskDao>` | `appDatabase` | Task DAO accessor |
| `progressLogDao` | `Provider<ProgressLogDao>` | `appDatabase` | Progress log DAO accessor |
| `settingsDao` | `Provider<SettingsDao>` | `appDatabase` | Settings DAO accessor |
| `taskRepository` | `Provider<TaskRepository>` | `taskDao`, `progressLogDao` | Domain-level task operations |
| `settings` | `StreamProvider<Setting>` | `settingsDao` | Reactive settings stream |
| `todayTasks` | `StreamProvider<List<TaskModel>>` | `taskRepository` | Today view task list, grouped & sorted |
| `pendingCount` | `StreamProvider<int>` | `taskDao` | Badge count for pending tasks |
| `todaySummary` | `Provider<TodaySummary>` | `todayTasks` | Derived: progress bar %, completion state |
| `tasksForDate` | `StreamProvider.family<List<TaskModel>, DateTime>` | `taskRepository` | Tasks for a specific date (calendar) |
| `allDatedTasks` | `StreamProvider<List<TaskModel>>` | `taskRepository` | Backlog view |
| `unresolvedTasks` | `FutureProvider<List<TaskModel>>` | `taskRepository` | Resolution screen |
| `taskActions` | `NotifierProvider<TaskActionsNotifier, void>` | `taskRepository` | Executes task mutations (mark done, snooze, etc.) |
| `calendarIndicators` | `StreamProvider<Map<DateTime, CalendarDayInfo>>` | `taskDao` | Month calendar dot indicators |
| `distinctLabels` | `FutureProvider<List<String>>` | `taskDao` | All distinct label strings for suggestion list |
| `reportData` | `FutureProvider.family<ReportData, ReportFilter>` | `reportsRepository` | Reports screen: aggregated analytics for the given filter (date range, label, priority, name, type) |
| `reportsDao` | `Provider<ReportsDao>` | `appDatabase` | Reports DAO accessor |
| `reportsRepository` | `Provider<ReportsRepository>` | `reportsDao`, `streakDao` | Domain-level report data composition |
| `currentStreak` | `StreamProvider<int>` | `streakDao` | Current streak count |
| `notificationScheduler` | `Provider<NotificationScheduler>` | `settings` | Computes notification times from bedtime |
| `onboardingState` | `NotifierProvider<OnboardingNotifier, OnboardingStep>` | `settingsDao` | Onboarding flow state machine |
| `quantifiedTaskProgress` | `StreamProvider.family<QuantifiedProgress, String>` | `progressLogDao` | Phase 2: live progress for a quantified task |
| `authState` | `StreamProvider<AuthUser?>` | `authRepository` | Phase 3: Firebase Auth state |
| `syncEngine` | `Provider<SyncEngine>` | `syncQueueDao`, `dioClient` | Phase 3: offline sync processor |
| `podData` | `StreamProvider<PodView>` | `podRepository` | Phase 3: pod member data |
| `podMembers` | `StreamProvider<List<PodMemberView>>` | `podRepository` | Phase 3: pod member list with status |

#### Today View Reactivity

The Today View rebuilds reactively through this chain:

```
tasks table (SQLite) 
  → TaskDao.watchTodayTasks() emits Stream<List<TaskRow>>
    → taskRepository transforms to Stream<List<TaskModel>> (includes priority + labels)
      → todayTasks StreamProvider exposes to UI (sorted: status group → priority desc → sort_order)
        → TodayScreen ConsumerWidget rebuilds (priority visual treatment, label chips on tiles)
          → todaySummary derived provider recomputes progress bar
```

When a user marks a task done:
1. `taskActions.markDone(taskId)` is called.
2. `TaskActionsNotifier` calls `taskRepository.markDone()`.
3. Repository calls `taskDao.markDone()` which updates SQLite.
4. The `watchTodayTasks()` stream emits a new list (Drift's reactive queries detect the change).
5. `todayTasks` provider propagates the update.
6. `todaySummary` recomputes (pending count, progress %).
7. If all tasks are now resolved, `notificationScheduler` cancels remaining reminders and fires "You're done!" notification.

---

### Notification Architecture

#### Scheduling Strategy

All local notifications are rescheduled as a batch at these trigger points:
- **Midnight** (via `workmanager` callback or foreground catch-up)
- **Bedtime change** (user edits in settings)
- **Notification mode change**
- **Task completion** (check if all done → suppress remaining)

The scheduler computes up to 8 notification slots per day relative to bedtime `T`:

```dart
class NotificationScheduler {
  /// Returns list of ScheduledNotification based on current settings and task state.
  List<ScheduledNotification> computeSchedule({
    required DateTime bedtime,        // T
    required DateTime morningCheckin,
    required NotificationMode mode,
    required int pendingCount,
  }) {
    if (pendingCount == 0) return [];  // No tasks, no notifications.

    final schedule = <ScheduledNotification>[];

    // Morning check-in — all modes
    schedule.add(ScheduledNotification(
      id: NotificationIds.morningCheckin,
      time: morningCheckin,
      type: NotificationType.summary,
      channel: NotificationChannels.standard,
    ));

    // T-4h — standard, persistent only
    if (mode != NotificationMode.minimal) {
      schedule.add(ScheduledNotification(
        id: NotificationIds.tMinus4h,
        time: bedtime.subtract(Duration(hours: 4)),
        type: NotificationType.pendingCount,
        channel: NotificationChannels.standard,
      ));
    }

    // T-2h — standard, persistent
    if (mode != NotificationMode.minimal) {
      schedule.add(ScheduledNotification(
        id: NotificationIds.tMinus2h,
        time: bedtime.subtract(Duration(hours: 2)),
        type: NotificationType.pendingCountWithPreview,
        channel: NotificationChannels.standard,
      ));
    }

    // T-1h — all modes (different content per mode)
    schedule.add(ScheduledNotification(
      id: NotificationIds.tMinus1h,
      time: bedtime.subtract(Duration(hours: 1)),
      type: mode == NotificationMode.minimal
          ? NotificationType.pendingReminder
          : NotificationType.urgentList,
      channel: NotificationChannels.standard,
    ));

    // T-30m — all modes
    schedule.add(ScheduledNotification(
      id: NotificationIds.tMinus30m,
      time: bedtime.subtract(Duration(minutes: 30)),
      type: mode == NotificationMode.minimal
          ? NotificationType.urgentList
          : NotificationType.finalPush,
      channel: NotificationChannels.standard,
    ));

    // T-10m — persistent only, DND bypass
    if (mode == NotificationMode.persistent) {
      schedule.add(ScheduledNotification(
        id: NotificationIds.tMinus10m,
        time: bedtime.subtract(Duration(minutes: 10)),
        type: NotificationType.lastCall,
        channel: NotificationChannels.critical,  // DND bypass
      ));
    }

    // T (bedtime) — standard, persistent; DND bypass
    if (mode != NotificationMode.minimal) {
      schedule.add(ScheduledNotification(
        id: NotificationIds.bedtime,
        time: bedtime,
        type: NotificationType.daySummary,
        channel: NotificationChannels.critical,  // DND bypass
      ));
    }

    return schedule;
  }
}
```

#### Notification Channel Setup

**Android:**
```dart
// Standard channel
AndroidNotificationChannel(
  id: 'daydone_standard',
  name: 'Task Reminders',
  description: 'Regular task reminder notifications',
  importance: Importance.high,
)

// Critical/DND bypass channel
AndroidNotificationChannel(
  id: 'daydone_critical',
  name: 'End-of-Day Alerts',
  description: 'Critical bedtime reminders that bypass Do Not Disturb',
  importance: Importance.max,
  // Full-screen intent for lock screen display
)
```

**iOS:**
- Standard notifications: default `UNAuthorizationOptions` (alert, sound, badge).
- Critical Alerts: request `.criticalAlert` authorization separately. Requires Apple entitlement (granted via developer portal for accountability/health apps).
- The `flutter_local_notifications` iOS configuration sets `DarwinNotificationCategory` with `critical` sound for the DND bypass channel.

**Android OEM Background Restrictions:**
- On first launch, detect OEM (Xiaomi, Samsung, Huawei, Oppo) via `device_info_plus`.
- If known restrictive OEM, show a one-time prompt with instructions to disable battery optimization for DayDone.
- Use `android_alarm_manager_plus` for exact alarm scheduling where `SCHEDULE_EXACT_ALARM` permission is granted; fall back to `workmanager` inexact alarms otherwise.

#### Deep-Link Tap Handling

Notification payloads include a `route` field:
- Morning check-in → `/today`
- Pending reminders → `/today`
- Bedtime summary → `/resolution` (if unresolved tasks exist)
- Pod notifications (Phase 3) → `/pods`

`go_router`'s `refreshListenable` is wired to a `notificationTapStream` so that tapping a notification navigates to the correct screen even if the app was cold-started.

---

### Navigation (go_router)

#### Route Tree

```dart
GoRouter(
  navigatorKey: _rootNavigatorKey,
  refreshListenable: notificationTapNotifier,
  redirect: (context, state) {
    final onboarded = ref.read(settingsProvider).valueOrNull?.onboardingCompleted ?? false;
    final hasUnresolved = ref.read(unresolvedTasksProvider).valueOrNull?.isNotEmpty ?? false;
    final isLoggedIn = ref.read(authStateProvider).valueOrNull != null; // Phase 3

    // Onboarding guard
    if (!onboarded && !state.matchedLocation.startsWith('/onboarding')) {
      return '/onboarding';
    }
    // Resolution guard: force resolution screen if unresolved tasks from yesterday
    if (hasUnresolved && state.matchedLocation == '/today') {
      return '/resolution';
    }
    // Auth guard (Phase 3): redirect to login for pod routes
    if (state.matchedLocation.startsWith('/pods') && !isLoggedIn) {
      return '/auth/login';
    }
    return null;
  },
  routes: [
    // --- Onboarding ---
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),

    // --- Main shell with bottom navigation ---
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => MainShell(navigationShell: shell),
      branches: [
        // Tab 0: Today
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/today',
            builder: (_, __) => const TodayScreen(),
          ),
        ]),
        // Tab 1: Calendar
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/calendar',
            builder: (_, __) => const CalendarScreen(),
            routes: [
              GoRoute(
                path: 'date/:date',  // /calendar/date/2026-04-03
                builder: (_, state) => DateTasksScreen(
                  date: DateTime.parse(state.pathParameters['date']!),
                ),
              ),
            ],
          ),
        ]),
        // Tab 2: Backlog
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/backlog',
            builder: (_, __) => const BacklogScreen(),
          ),
        ]),
        // Tab 3: Reports (Progress / Analytics)
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/reports',
            builder: (_, __) => const ReportsScreen(),
          ),
        ]),
        // Tab 4: Pods (Phase 3)
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/pods',
            builder: (_, __) => const PodTabScreen(),
            routes: [
              GoRoute(path: 'invite', builder: (_, __) => const PodInviteScreen()),
              GoRoute(path: 'settings', builder: (_, __) => const PodSettingsScreen()),
            ],
          ),
        ]),
      ],
    ),

    // --- Full-screen routes (outside shell) ---
    GoRoute(
      path: '/resolution',
      builder: (_, __) => const ResolutionScreen(),
    ),
    GoRoute(
      path: '/task/create',
      builder: (_, __) => const TaskCreateScreen(),
    ),
    GoRoute(
      path: '/task/:id/edit',
      builder: (_, state) => TaskEditScreen(taskId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsScreen(),
    ),

    // --- Auth (Phase 3) ---
    GoRoute(
      path: '/auth/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/signup',
      builder: (_, __) => const SignupScreen(),
    ),

    // --- Deep link: pod invite ---
    GoRoute(
      path: '/invite/:token',  // Universal link
      redirect: (_, state) => '/pods/invite?token=${state.pathParameters['token']}',
    ),
  ],
);
```

#### All Screens by Phase

| Phase | Route | Screen | Description |
|---|---|---|---|
| 1 | `/onboarding` | OnboardingScreen | 4-step onboarding flow |
| 1 | `/today` | TodayScreen | Default home, daily + dated tasks |
| 1 | `/calendar` | CalendarScreen | Month calendar with indicators |
| 1 | `/calendar/date/:date` | DateTasksScreen | Tasks for a specific date |
| 1 | `/backlog` | BacklogScreen | All dated tasks grouped by date |
| 1 | `/reports` | ReportsScreen | Read-only analytics: completion chart, streak summary, priority & label breakdowns, filters |
| 1 | `/resolution` | ResolutionScreen | End-of-day forced disposition |
| 1 | `/task/create` | TaskCreateScreen | New task form |
| 1 | `/task/:id/edit` | TaskEditScreen | Edit existing task |
| 1 | `/settings` | SettingsScreen | Bedtime, morning check-in, notification mode |
| 3 | `/auth/login` | LoginScreen | Email/password + social login |
| 3 | `/auth/signup` | SignupScreen | Account creation |
| 3 | `/pods` | PodTabScreen | Pod member list with status |
| 3 | `/pods/invite` | PodInviteScreen | Generate/share invite link |
| 3 | `/pods/settings` | PodSettingsScreen | Mute, leave pod |
| 3 | `/invite/:token` | (redirect) | Deep link for pod invites |

---

### Phase 3 Client Additions

#### Auth Screens
- `LoginScreen`: email/password fields + "Sign in with Apple" / "Sign in with Google" buttons.
- `SignupScreen`: email, password, confirm password + social options.
- Uses `firebase_auth` package directly. `AuthRepository` wraps Firebase Auth calls and exposes `Stream<AuthUser?>`.

#### Dio Interceptors

```dart
// lib/services/interceptors/auth_interceptor.dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, handler) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

// lib/services/interceptors/retry_interceptor.dart
class RetryInterceptor extends Interceptor {
  static const maxRetries = 3;
  // Exponential backoff: 1s, 2s, 4s
  // Retries on 429, 500, 502, 503, 504 and network errors
}

// lib/services/interceptors/offline_queue_interceptor.dart
class OfflineQueueInterceptor extends Interceptor {
  // If no connectivity, writes request to SyncQueue table instead of failing.
  // SyncEngine processes the queue when connectivity returns.
}
```

#### Conflict Resolution (Client-Side)
- **Task completion state:** Last-write-wins by `resolvedAt` timestamp. If server has a newer `resolvedAt`, server wins. If client is newer, client wins.
- **Progress logs:** Merge by `{taskId, recordedAt}`. Append-only: entries are never discarded. Client sends its log entries; server deduplicates and returns the merged set.
- **Sort order:** Client-authoritative (sort order is a local preference).

#### FCM Push Registration
- On login, register FCM device token via `POST /api/identity/devices`.
- On token refresh (`FirebaseMessaging.instance.onTokenRefresh`), update via `PUT /api/identity/devices/:token`.
- On logout, delete token via `DELETE /api/identity/devices/:token`.

---

## Backend Architecture (Node.js)

### Service Breakdown

All services use **Fastify 5.x** with TypeScript. Each service is a separate npm workspace in a monorepo.

```
backend/
├── packages/
│   ├── gateway/           # API Gateway
│   ├── identity/          # Identity Service
│   ├── relationships/     # User-Relationship Service
│   ├── task-sync/         # Task-Sync Service
│   ├── notifications/     # Notification Service
│   └── shared/            # Shared types, validators, Firebase admin init
├── package.json           # Workspaces root
├── tsconfig.base.json
├── Dockerfile             # Multi-stage build
└── docker-compose.yml     # Local dev
```

---

#### 1. API Gateway

**Responsibilities:** Single entry point for all client requests. JWT validation, rate limiting, request routing to internal services.

**Framework:** Fastify + `@fastify/http-proxy` + `@fastify/rate-limit`

| Method | Path | Routes To | Description |
|---|---|---|---|
| `*` | `/api/identity/*` | Identity Service | Auth, profile, device tokens |
| `*` | `/api/pods/*` | User-Relationship Service | Pod CRUD, membership |
| `*` | `/api/sync/*` | Task-Sync Service | Task state sync |
| `*` | `/api/notifications/*` | Notification Service | Notification preferences (future) |

**Auth Middleware:**
```typescript
// gateway/src/plugins/auth.ts
import { FastifyRequest } from 'fastify';
import { getAuth } from 'firebase-admin/auth';

async function verifyToken(request: FastifyRequest) {
  const header = request.headers.authorization;
  if (!header?.startsWith('Bearer ')) throw { statusCode: 401, message: 'Missing token' };

  const token = header.slice(7);
  const decoded = await getAuth().verifyIdToken(token);
  request.user = { uid: decoded.uid, email: decoded.email };
}
```

Routes exempt from auth: `POST /api/identity/auth/signup`, `POST /api/identity/auth/login`.

**Rate Limiting:**
- Global: 100 requests/minute per IP.
- Auth endpoints: 10 requests/minute per IP (brute force protection).
- Sync endpoints: 30 requests/minute per user (prevent sync storms).

Uses `@fastify/rate-limit` with Redis backend (Cloud Memorystore) for distributed rate limit state across Cloud Run instances.

---

#### 2. Identity Service

**Responsibilities:** Wraps Firebase Auth; manages user profiles and device tokens for FCM.

**Database:** Firestore

| Collection | Document ID | Schema |
|---|---|---|
| `users` | Firebase UID | `{ uid, email, displayName, createdAt, updatedAt }` |
| `devices` | auto | `{ uid, fcmToken, platform, createdAt, updatedAt }` |

**Endpoints:**

| Method | Path | Description |
|---|---|---|
| `POST` | `/api/identity/auth/signup` | Create Firebase Auth user + Firestore user doc |
| `POST` | `/api/identity/auth/login` | Validate credentials via Firebase Auth (client-side SDK handles this; server just verifies token) |
| `GET` | `/api/identity/profile` | Get user profile |
| `PUT` | `/api/identity/profile` | Update display name |
| `POST` | `/api/identity/devices` | Register FCM device token |
| `PUT` | `/api/identity/devices/:token` | Update device token |
| `DELETE` | `/api/identity/devices/:token` | Remove device token (logout) |

**Firebase Auth Integration Flow:**
1. Client calls Firebase Auth SDK directly for signup/login (email+password or OAuth).
2. Client receives Firebase ID token (JWT).
3. Client sends JWT in `Authorization: Bearer <token>` header to API Gateway.
4. Gateway calls `firebase-admin` `verifyIdToken()` to validate.
5. On first login, Identity Service creates a Firestore `users` document if it doesn't exist (upsert pattern).
6. JWT contains `uid`, `email`, and custom claims if needed.
7. Token refresh is handled client-side by Firebase SDK; gateway always validates the current token.

**Why Firestore for Identity:** User profiles are simple key-value documents with no complex queries. Firestore's real-time listeners and Firebase Auth integration make it the natural choice. No benefit from MongoDB here.

---

#### 3. User-Relationship Service

**Responsibilities:** Pod CRUD, membership management, invite links, mute preferences.

**Database:** Firestore

| Collection | Document ID | Schema |
|---|---|---|
| `pods` | auto-generated | `{ name, createdBy, createdAt, memberCount, status: 'active'\|'dissolved' }` |
| `pods/{podId}/members` | user UID | `{ uid, displayName, joinedAt, role: 'owner'\|'member', mutedMembers: [uid] }` |
| `invites` | token (UUID) | `{ podId, createdBy, createdAt, expiresAt, maxUses, useCount }` |

**Indices (Firestore composite):**
- `invites`: `expiresAt` (for TTL cleanup) + `podId`
- `pods`: `status` + `createdAt`

**Endpoints:**

| Method | Path | Description |
|---|---|---|
| `POST` | `/api/pods` | Create a new pod (creator becomes owner) |
| `GET` | `/api/pods` | Get user's pod (single pod per user in v1) |
| `GET` | `/api/pods/:podId` | Get pod details + member list |
| `DELETE` | `/api/pods/:podId` | Dissolve pod (owner only) |
| `POST` | `/api/pods/:podId/invite` | Generate invite link (UUID token, 48h expiry, single-use) |
| `POST` | `/api/pods/join/:token` | Join pod via invite token |
| `POST` | `/api/pods/:podId/leave` | Leave pod; dissolves if <2 members remain |
| `PUT` | `/api/pods/:podId/mute/:memberId` | Mute a member |
| `DELETE` | `/api/pods/:podId/mute/:memberId` | Unmute a member |

**Invite Link Generation:**
```typescript
async function createInvite(podId: string, createdBy: string): Promise<string> {
  const token = crypto.randomUUID();
  await db.collection('invites').doc(token).set({
    podId,
    createdBy,
    createdAt: FieldValue.serverTimestamp(),
    expiresAt: Timestamp.fromDate(addHours(new Date(), 48)),
    maxUses: 1,
    useCount: 0,
  });
  return `https://daydone.app/invite/${token}`;
}
```

**Pod Lifecycle:**
- **Create:** Owner creates pod → pod status `active`, memberCount 1.
- **Join:** Validate invite token (not expired, useCount < maxUses, pod has <5 members, user not already in a pod). Atomic transaction: increment useCount, add member subcollection doc, increment memberCount.
- **Leave:** Remove member doc, decrement memberCount. If memberCount < 2 after leave, set pod status to `dissolved`, notify remaining member.
- **Dissolve:** Owner action. Set status `dissolved`, notify all members.

**Why Firestore for Relationships:** Pod data is naturally hierarchical (pod → members). Firestore subcollections model this well. Real-time listeners enable future live pod status updates. Member count is small (max 5), so no fan-out concerns.

---

#### 4. Task-Sync Service

**Responsibilities:** Receives task state changes from clients, persists privacy-filtered views for pod consumption, serves pod-visible task data.

**Database:** MongoDB Atlas

| Collection | Schema | Indices |
|---|---|---|
| `task_states` | `{ _id, userId, taskId, title, type, date, status, resolvedAt, isQuantified, targetValue, progressValue, progressLog: [{value, recordedAt}], podVisible, priority, labels: [String], syncVersion, updatedAt }` | `{ userId: 1, date: -1 }`, `{ userId: 1, taskId: 1 }` unique, `{ userId: 1, podVisible: 1 }`, `{ userId: 1, priority: 1 }` |
| `sync_cursors` | `{ _id, userId, lastSyncVersion, lastSyncAt }` | `{ userId: 1 }` unique |

**Why MongoDB for Task-Sync:** Task sync involves complex queries (aggregations for pod views, date-range queries, progress log merging with dedup). MongoDB's aggregation pipeline and flexible document model handle this better than Firestore. Progress log arrays with dedup-by-timestamp benefit from MongoDB's `$addToSet` and array update operators.

**Endpoints:**

| Method | Path | Description |
|---|---|---|
| `POST` | `/api/sync/push` | Client pushes task state changes (batch) |
| `GET` | `/api/sync/pull?since=<version>` | Client pulls changes since last sync |
| `GET` | `/api/sync/pod-view/:podId` | Get pod-visible task data for all pod members |

**Privacy Filtering Logic:**

```typescript
// task-sync/src/services/privacy-filter.ts

interface TaskStatePublic {
  userId: string;
  taskId: string;
  status: 'pending' | 'done' | 'closed' | 'snoozed';
  // Always visible to pod:
  resolvedAt: Date | null;
}

interface TaskStatePodVisible extends TaskStatePublic {
  // Only when task.podVisible = true:
  title: string;
  isQuantified: boolean;
  targetValue: number | null;
  progressValue: number;
}

function filterForPod(task: TaskState): TaskStatePublic | TaskStatePodVisible {
  const base: TaskStatePublic = {
    userId: task.userId,
    taskId: task.taskId,
    status: task.status,
    resolvedAt: task.resolvedAt,
  };

  if (task.podVisible) {
    return {
      ...base,
      title: task.title,
      isQuantified: task.isQuantified,
      targetValue: task.targetValue,
      progressValue: task.progressValue,
    };
  }

  return base;
  // NEVER include: notes, snoozeUntil, targetHistory, sortOrder
}
```

**Fields persisted server-side (in `task_states`):**
- `userId`, `taskId`, `title`, `type`, `date`, `status`, `resolvedAt`
- `isQuantified`, `targetValue`, `progressValue`, `progressLog`
- `priority`, `labels`
- `podVisible`, `syncVersion`, `updatedAt`

**Fields NEVER sent to server:**
- `notes` (private)
- `snoozeUntil` (private)
- `sortOrder` (local preference)
- `targetHistory` (local tracking)

**Idempotent Sync Endpoint Design:**

```typescript
// POST /api/sync/push
// Body: { changes: TaskStateChange[] }
// Each change has: { taskId, syncVersion, ...fields }

async function pushChanges(userId: string, changes: TaskStateChange[]) {
  const operations = changes.map(change => ({
    updateOne: {
      filter: {
        userId,
        taskId: change.taskId,
        syncVersion: { $lt: change.syncVersion },  // Only apply if newer
      },
      update: {
        $set: { ...change, userId, updatedAt: new Date() },
        $addToSet: change.progressLog
          ? { progressLog: { $each: change.progressLog } }
          : {},
      },
      upsert: true,
    },
  }));

  await db.collection('task_states').bulkWrite(operations, { ordered: false });
}
```

**Progress Log Dedup:** MongoDB `$addToSet` with custom equality on `{taskId, recordedAt}`. The progress log array in MongoDB stores `{value, recordedAt}` objects. On sync push, new entries are added via `$addToSet` which prevents duplicates. The `recordedAt` timestamp (ISO string with millisecond precision) serves as the dedup key.

---

#### 5. Notification Service

**Responsibilities:** Evaluates pod notification triggers on a schedule, dispatches FCM/APNs push notifications, manages notification batching.

**Database:** MongoDB Atlas

| Collection | Schema | Indices |
|---|---|---|
| `notification_log` | `{ _id, recipientId, type, podId, triggeredBy, sentAt, batchId }` | `{ recipientId: 1, sentAt: -1 }`, `{ recipientId: 1, sentAt: 1, type: 1 }` (for 2/day cap) |
| `user_timezones` | `{ _id: <userId>, timezone, bedtime, morningCheckin, notificationMode }` | `{ bedtime: 1 }` (for scheduled evaluation) |

**Why MongoDB for Notifications:** Notification evaluation requires aggregation queries (count notifications sent in last 24h, check completion rates across date ranges for streak calculation, compute pacing at T-1h). MongoDB's aggregation pipeline is significantly more capable than Firestore for these use cases.

**BullMQ + Redis Scheduler Design:**

```typescript
// notifications/src/workers/trigger-evaluator.ts
import { Queue, Worker } from 'bullmq';

// Cron job runs every 15 minutes, evaluates triggers for users
// whose bedtime falls within the next window.
const triggerQueue = new Queue('pod-triggers', { connection: redis });

// Schedule repeatable job
await triggerQueue.add('evaluate', {}, {
  repeat: { every: 15 * 60 * 1000 },  // Every 15 minutes
});

const worker = new Worker('pod-triggers', async (job) => {
  const now = new Date();
  const windowEnd = addMinutes(now, 15);

  // Find users whose bedtime is between now and now+15min (timezone-adjusted)
  const users = await db.collection('user_timezones').find({
    // bedtime stored as minutes-since-midnight; compare against current time in each user's timezone
  }).toArray();

  for (const user of users) {
    await evaluateTriggersForUser(user, now);
  }
}, { connection: redis });
```

**Pod Trigger Evaluation Logic:**

```typescript
async function evaluateTriggersForUser(user: UserTimezone, now: Date) {
  const podId = await getPodForUser(user._id);
  if (!podId) return;

  const podMembers = await getPodMembers(podId);
  const bedtimeToday = getUserBedtimeToday(user);

  // 1. Bedtime missed check (+15min after bedtime)
  if (isAfter(now, addMinutes(bedtimeToday, 15))) {
    const unresolvedCount = await getUnresolvedCount(user._id, getLocalDate(now, user.timezone));
    if (unresolvedCount > 0) {
      await notifyPodMembers(podMembers, user._id, 'bedtime_missed', {
        memberName: user.displayName,
        unresolvedCount,
      });
    }
  }

  // 2. Streak broken check (7+ day streak)
  const streakBroken = await checkStreakBroken(user._id);
  if (streakBroken && streakBroken.previousStreak >= 7) {
    await notifyPodMembers(podMembers, user._id, 'streak_broken', {
      memberName: user.displayName,
      streakLength: streakBroken.previousStreak,
    });
  }

  // 3. Quantified pacing check (<50% at T-1h for shared tasks)
  const oneHourBefore = subHours(bedtimeToday, 1);
  if (isWithinInterval(now, { start: oneHourBefore, end: addMinutes(oneHourBefore, 15) })) {
    const behindTasks = await getQuantifiedBehindTasks(user._id, getLocalDate(now, user.timezone));
    for (const task of behindTasks) {
      if (task.podVisible && task.progressValue < 0.5 * task.targetValue) {
        await notifyPodMembers(podMembers, user._id, 'quantified_behind', {
          memberName: user.displayName,
          taskTitle: task.title,
          progress: task.progressValue,
          target: task.targetValue,
        });
      }
    }
  }

  // 4. Notable completion (<60% prior 7-day rate)
  const notableCompletion = await checkNotableCompletion(user._id);
  if (notableCompletion) {
    await notifyPodMembers(podMembers, user._id, 'notable_completion', {
      memberName: user.displayName,
    });
  }
}
```

**Notification Batching (2/day cap per recipient):**

```typescript
async function notifyPodMembers(
  members: PodMember[],
  triggeringUserId: string,
  type: string,
  payload: Record<string, unknown>,
) {
  const batchId = crypto.randomUUID();

  for (const member of members) {
    if (member.uid === triggeringUserId) continue;  // Don't notify self
    if (member.mutedMembers?.includes(triggeringUserId)) continue;  // Muted

    // Check 24h cap
    const recentCount = await db.collection('notification_log').countDocuments({
      recipientId: member.uid,
      sentAt: { $gte: subHours(new Date(), 24) },
      type: { $in: ['bedtime_missed', 'streak_broken', 'quantified_behind', 'notable_completion'] },
    });

    if (recentCount >= 2) continue;  // Cap reached

    // Dispatch
    await sendPush(member.uid, type, payload);

    // Log
    await db.collection('notification_log').insertOne({
      recipientId: member.uid,
      type,
      podId: member.podId,
      triggeredBy: triggeringUserId,
      sentAt: new Date(),
      batchId,
    });
  }
}
```

**APNs vs FCM Dispatch:**

```typescript
async function sendPush(userId: string, type: string, payload: Record<string, unknown>) {
  const devices = await getDeviceTokens(userId);

  for (const device of devices) {
    if (device.platform === 'ios' || device.platform === 'macos') {
      // Use firebase-admin messaging which routes through APNs for Apple devices
      // For Critical Alerts (bedtime_missed at T-10m, T), set:
      //   apns.payload.aps.sound = { critical: 1, name: 'default', volume: 1.0 }
      await admin.messaging().send({
        token: device.fcmToken,
        notification: { title: formatTitle(type), body: formatBody(type, payload) },
        apns: {
          payload: {
            aps: {
              sound: isCritical(type) ? { critical: 1, name: 'default', volume: 1.0 } : 'default',
            },
          },
        },
        data: { route: getRouteForType(type) },
      });
    } else {
      // Android and Web: FCM directly
      await admin.messaging().send({
        token: device.fcmToken,
        notification: { title: formatTitle(type), body: formatBody(type, payload) },
        android: {
          priority: isCritical(type) ? 'high' : 'normal',
          notification: {
            channelId: isCritical(type) ? 'daydone_critical' : 'daydone_standard',
          },
        },
        data: { route: getRouteForType(type) },
      });
    }
  }
}
```

**Correction Notification for Offline Retroactive Completion:**

When a sync push arrives and changes a task from `pending` → `done` with `resolvedAt` before the user's bedtime:
1. Check if a `bedtime_missed` notification was already sent for this user today.
2. If yes, send a correction notification to pod members: "Update: [MemberName] actually completed their tasks on time."
3. Update `notification_log` with a `correction` type entry.

**Timezone Handling:**

- `user_timezones` collection stores each user's IANA timezone string (e.g., `America/New_York`).
- Client sends timezone on login and on every sync push (in case of travel).
- Bedtime is stored as minutes-since-midnight (e.g., 23:00 = 1380 minutes). The notification service converts this to an absolute UTC timestamp using the user's timezone for each evaluation cycle.
- DST transitions: the 15-minute evaluation window naturally handles DST shifts (bedtime might be evaluated in the wrong window once, but the next cycle catches it).

---

### Database Design Summary

| Service | Database | Justification |
|---|---|---|
| Identity | Firestore | Simple user docs, Firebase Auth native integration, real-time listeners |
| User-Relationship | Firestore | Hierarchical pod→member model, subcollections, real-time pod status |
| Task-Sync | MongoDB | Complex aggregation for pod views, progress log array operations, date-range queries |
| Notification | MongoDB | Aggregation for 24h cap counting, streak calculation, pacing evaluation, time-window queries |

---

### Deployment Topology

```
                          ┌──────────────────────┐
                          │   Firebase Auth       │
                          │   (managed)           │
                          └──────────┬────────────┘
                                     │ JWT validation
                    ┌────────────────┴────────────────┐
                    │         API Gateway              │
                    │   (Cloud Run, auto-scale 1-10)   │
                    │   Port 8080                       │
                    └─┬──────┬──────────┬──────────┬──┘
                      │      │          │          │
              ┌───────┘  ┌───┘    ┌─────┘    ┌─────┘
              ▼          ▼        ▼          ▼
        ┌──────────┐ ┌────────┐ ┌─────────┐ ┌──────────────┐
        │ Identity │ │ Rels.  │ │ Task    │ │ Notification │
        │ Service  │ │Service │ │ Sync    │ │ Service      │
        │ (CR)     │ │ (CR)   │ │ (CR)    │ │ (CR)         │
        └────┬─────┘ └───┬────┘ └────┬────┘ └──────┬───────┘
             │            │           │             │
             ▼            ▼           ▼             ▼
        ┌─────────┐  ┌─────────┐ ┌────────┐  ┌────────────┐
        │Firestore│  │Firestore│ │MongoDB │  │MongoDB     │
        │         │  │         │ │Atlas   │  │Atlas       │
        └─────────┘  └─────────┘ └────────┘  └────────────┘
                                                    │
                                              ┌─────┴─────┐
                                              │   Redis    │
                                              │MemoryStore │
                                              └───────────┘
```

**Cloud Run Configuration:**
- Each service: min 0 instances (scale to zero), max 10 instances.
- Notification Service: min 1 instance (must run cron jobs). Alternatively, use Cloud Scheduler to invoke the evaluation endpoint every 15 minutes, allowing scale-to-zero.
- CPU: 1 vCPU, 512MB RAM per instance (sufficient for Node.js services).
- Concurrency: 80 requests per instance.

**Environment Variable Management:**
- Secrets (Firebase service account, MongoDB connection string, Redis URL): Google Secret Manager, mounted as env vars in Cloud Run.
- Non-secret config (rate limits, feature flags): Cloud Run environment variables set via Terraform.

**CI/CD Pipeline (GitHub Actions):**

```yaml
# .github/workflows/backend.yml
name: Backend CI/CD
on:
  push:
    branches: [main]
    paths: ['backend/**']
  pull_request:
    paths: ['backend/**']

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      redis:
        image: redis:7
        ports: ['6379:6379']
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
        working-directory: backend
      - run: npm run lint
        working-directory: backend
      - run: npm test
        working-directory: backend

  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: [gateway, identity, relationships, task-sync, notifications]
    steps:
      - uses: actions/checkout@v4
      - uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}
      - uses: google-github-actions/deploy-cloudrun@v2
        with:
          service: daydone-${{ matrix.service }}
          source: backend/packages/${{ matrix.service }}
```

```yaml
# .github/workflows/flutter.yml
name: Flutter CI
on:
  push:
    branches: [main]
    paths: ['lib/**', 'test/**', 'pubspec.*']
  pull_request:
    paths: ['lib/**', 'test/**', 'pubspec.*']

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.x', channel: stable }
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter analyze
      - run: flutter test --coverage

  build-android:
    needs: analyze-and-test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release

  build-ios:
    needs: analyze-and-test
    if: github.ref == 'refs/heads/main'
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build ios --release --no-codesign

  build-web:
    needs: analyze-and-test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build web --release
      # Deploy to Firebase Hosting
```

---

## Cross-Cutting Concerns

### Security

**JWT Validation at Gateway:**
- Every request (except signup/login) passes through `verifyToken` middleware.
- Firebase Admin SDK `verifyIdToken()` checks signature, expiration, and issuer.
- User UID from decoded token is injected into request context; downstream services trust this UID without re-verification (internal network).

**Data Scrubbed Before Leaving Device:**
- `notes` field: NEVER included in sync payloads. The `PrivacyFilter` in `sync/services/privacy_filter.dart` strips it before serialization.
- `snoozeUntil`: excluded from sync (local scheduling concern).
- `sortOrder`: excluded (local UI preference).
- `targetHistory`: excluded (local tracking).
- Bedtime config: stored only in `user_timezones` on notification service; never exposed to other users or pod endpoints.

**HTTPS Enforcement:**
- Cloud Run enforces HTTPS by default (HTTP→HTTPS redirect).
- Dio client configured with `baseUrl: 'https://api.daydone.app'`.

**Firebase Security Rules (for direct Firestore access):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own profile
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }

    // Pod members can read their pod
    match /pods/{podId} {
      allow read: if request.auth != null &&
        exists(/databases/$(database)/documents/pods/$(podId)/members/$(request.auth.uid));
      allow create: if request.auth != null;
      allow update, delete: if false;  // Only via backend

      match /members/{memberId} {
        allow read: if request.auth != null &&
          exists(/databases/$(database)/documents/pods/$(podId)/members/$(request.auth.uid));
        allow write: if false;  // Only via backend
      }
    }

    // Invites: read-only for validation; writes via backend
    match /invites/{token} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // Deny everything else
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**Input Validation:**
- Fastify JSON schema validation on all endpoints (built-in).
- Task title: max 200 chars, sanitized (no HTML).
- Notes: max 1000 chars.
- Target unit: max 12 chars.
- Labels: max 5 per task, each max 30 chars, trimmed, blank-after-trim rejected, duplicate detection (case-insensitive).
- Priority: validated against enum values (0-4).
- UUIDs validated with regex.

---

### Offline-First Guarantee

**Sync Queue Design:**

```
User Action → TaskRepository → Drift DB (immediate) → SyncQueue (append)
                                      ↓
                              UI updates instantly (Drift stream)
                                      
                              SyncEngine (background) → reads SyncQueue 
                              → batches changes → POST /api/sync/push
                              → on success: mark synced=true in SyncQueue
                              → on failure: increment retryCount, exponential backoff
```

**What happens if sync fails mid-batch:**
- The sync push endpoint is idempotent (syncVersion-based upsert). Re-sending the same batch is safe.
- SyncQueue entries are only marked `synced=true` after server confirms receipt.
- If the app is killed mid-sync, unsynced entries remain in the queue and are retried on next app launch.
- Entries with `retryCount > 10` are flagged for manual review (logged, not discarded).

**Eventual Consistency Model:**
- Local Drift DB is the source of truth for the user's own task data.
- Server holds a derived, privacy-filtered view for pod consumption.
- Pod members see data that is eventually consistent (seconds to minutes lag depending on network).
- No real-time WebSocket in v1; pod data refreshes on app foreground + pull-to-refresh.

---

### Timezone Handling (End-to-End)

1. **Device:** All dates stored as `YYYY-MM-DD` local date (no timezone attached). The `date` column in Drift stores midnight UTC of the local date.
2. **Notification scheduling:** `NotificationScheduler` computes absolute `DateTime` from the user's bedtime + current local timezone. Scheduled via `flutter_local_notifications` `zonedSchedule()` which handles DST.
3. **Foreground resume check:** On `AppLifecycleState.resumed`, compare `DateTime.now().localDate` against last-known date. If different:
   - Re-instantiate daily tasks for the new date.
   - Reschedule all notifications.
   - Check for missed end-of-day (overdue tasks from yesterday).
4. **Backend:** Client sends IANA timezone string on every sync push. Notification Service uses this to convert bedtime (minutes-since-midnight) to absolute UTC for trigger evaluation.
5. **DST edge case:** If a user's bedtime is 11 PM and clocks spring forward, the 15-minute evaluation window may fire the bedtime trigger at 12 AM instead (shifted by 1 hour). The next evaluation cycle self-corrects. This is acceptable given the 15-minute granularity.

---

### Scalability

**Per-Service Scaling:**

| Service | Scaling Concern | Strategy |
|---|---|---|
| API Gateway | Request routing throughput | Cloud Run auto-scale; stateless; Redis-backed rate limiting |
| Identity | Low write volume, moderate reads | Single Cloud Run instance handles 10K+ users easily |
| User-Relationship | Low volume (pod CRUD is infrequent) | Single instance sufficient for early scale |
| Task-Sync | Highest write volume (every task action syncs) | Cloud Run auto-scale; MongoDB connection pooling; batch writes |
| Notification | Cron-driven, bursty (bedtime windows cluster around 10-11 PM per timezone) | Scale up during peak windows; BullMQ handles backpressure |

**Firestore at Scale:**
- Natural sharding by document ID (user UID, pod ID).
- Pod subcollections have max 5 members — no hot-spot risk.
- Read-heavy pod queries benefit from Firestore's caching.

**MongoDB at Scale:**
- `task_states` collection grows linearly with users x tasks. Index on `{userId, taskId}` keeps per-user queries fast.
- Progress log arrays capped practically (one task rarely has >100 log entries/day).
- Notification log: TTL index on `sentAt` to auto-expire entries older than 30 days.

**Notification Fan-Out:**
- Pod size capped at 5 → max 4 notifications per trigger event.
- 2/day cap per recipient limits total outbound.
- At 50K users, assuming 20% in pods = 10K pod users, peak bedtime window (10-11 PM EST) might evaluate ~3K users in 15 minutes. Each evaluation is a few MongoDB queries — well within a single Cloud Run instance's capacity.

---

### Testing Strategy

#### Flutter (Client)

| Test Type | What to Test | Tools |
|---|---|---|
| **Unit** | `NotificationScheduler.computeSchedule()` logic, `PrivacyFilter` field stripping, `TaskModel` domain logic (80% threshold, streak calculation), date utilities, `ReportFilter` validation, `Priority` enum ordering | `flutter_test`, `mocktail` |
| **Unit (Drift)** | DAO queries: `watchTodayTasks`, `instantiateDailyTasks`, progress log dedup, soft delete filtering, `watchTasksByPriority`, `watchTasksByLabel`, `getDistinctLabels`, `ReportsDao.getTasksPerDayInRange`, `ReportsDao.getCompletionByPriority`, `ReportsDao.getCompletionByLabel`, schema migration v3→v4 (priority/labels column addition with defaults) | `drift`'s in-memory database (`NativeDatabase.memory()`) |
| **Unit (Riverpod)** | Provider outputs given mocked DAOs; dependency graph correctness; `TaskActionsNotifier` state transitions | `riverpod_test` or manual `ProviderContainer` |
| **Widget** | `TodayScreen` renders correct groups (pending/snoozed/done/closed), `ResolutionScreen` blocks dismiss until all resolved, `OnboardingScreen` step flow, progress bar colors (amber/green), priority visual treatment on task tiles, label chips rendering (3 inline + overflow), `ReportsScreen` empty states, `priority_picker` selection, `label_chips_input` max-5 enforcement and suggestion dropdown, `completion_chart` bar vs sparkline switching at 30-day threshold | `flutter_test` `WidgetTester`, `mocktail` for providers |
| **Integration** | Full flow: create task with priority and labels → mark done → verify today view updates with correct sort order → verify notification rescheduled → resolution screen behavior; Reports flow: create tasks across multiple days → open reports → verify chart, summary metrics, priority and label breakdowns match expected aggregates → apply filters → verify filtered results | `integration_test` package, real Drift DB |

#### Backend (Node.js)

| Test Type | What to Test | Tools |
|---|---|---|
| **Unit** | Privacy filter logic, invite token validation, notification trigger conditions, 24h cap logic, timezone conversion | `vitest`, mocked DB |
| **Integration** | API endpoints with real Firestore emulator + MongoDB in-memory (`mongodb-memory-server`), auth flow with Firebase Auth emulator | `vitest`, `supertest`, Firebase emulator suite |
| **E2E** | Full sync flow: client pushes → server persists → pod view reflects change; notification trigger fires and dispatches FCM | Firebase emulator suite, `testcontainers` for Redis |

---

## Key Architectural Decisions (ADRs)

| Decision | Options Considered | Chosen | Rationale |
|---|---|---|---|
| State management | setState, Provider, Bloc, Riverpod | Riverpod (code-gen) | Type-safe, auto-dispose, testable, no BuildContext dependency; code-gen eliminates provider boilerplate; good migration path from current setState |
| Local database | Hive, Isar, SharedPreferences, Drift | Drift (SQLite) | Type-safe SQL, reactive streams, migration support, complex queries (joins for today view), cross-platform; outperforms NoSQL alternatives for relational task data |
| Navigation | Navigator 2.0, auto_route, go_router | go_router | First-party (Flutter team), declarative, deep-link support, ShellRoute for tab layouts, redirect guards |
| Backend framework | Express, Fastify, NestJS | Fastify | 2-3x faster than Express, built-in JSON schema validation, TypeScript-first, lightweight plugin system |
| Primary backend DB | Firestore only, MongoDB only, hybrid | Hybrid (Firestore + MongoDB) | Firestore for real-time user/pod data (natural fit); MongoDB for aggregation-heavy sync and notification logic |
| Notification scheduler | Node-cron, Agenda, BullMQ | BullMQ + Redis | Persistent job queue, repeatable jobs, concurrency control, retry/backoff, battle-tested in production |
| Sync strategy | Firebase Realtime DB, custom REST sync, CRDTs | Custom REST sync (last-write-wins) | Simple, predictable, sufficient for single-user task data; CRDTs are overkill for a personal task app; REST keeps the protocol transparent |
| Pod data delivery | WebSocket, SSE, polling | Polling (foreground + pull-to-refresh) | v1 simplicity; pods are 2-5 members with infrequent updates; WebSocket overhead not justified until usage patterns warrant it |
| DND bypass | Skip on unsupported platforms, always attempt | Always attempt with graceful degradation | Core product feature; Critical Alerts on iOS + full-screen intent on Android; degrade gracefully to regular notification if permission denied |
| Daily task storage | Single row with date rewrite, template + instances | Template + DailyInstances table | Preserves historical state for streaks; template row defines the recurring task; instance rows track per-day status without mutating the original |
| Label storage | Separate labels table + junction table, JSON array on task row, comma-separated string | JSON array on task row (denormalized) | Max 5 labels/task keeps payload trivial; avoids join complexity and sync overhead in Phase 3; suggestion list derived on-demand from task table; if query performance degrades (>1K tasks), migrate to junction table via Drift migration |
| Reports charting | `fl_chart`, `syncfusion_flutter_charts`, `graphic` | `fl_chart` | MIT-licensed, lightweight, supports bar chart + sparkline + tooltips; no licensing complexity (Syncfusion requires commercial license at scale); well-maintained with Flutter 3.x support |
| Deployment | Firebase Functions, AWS Lambda, Cloud Run | GCP Cloud Run | Container flexibility (not locked to function runtime), pairs with Firebase ecosystem, auto-scaling with scale-to-zero, predictable pricing |

---

## Phased Implementation Roadmap

### Phase 1 -- MVP (Weeks 1-6)

**Goal:** Fully functional local todo app with end-of-day accountability.

| Week | Deliverables |
|---|---|
| 1 | Project setup: add Drift, Riverpod, go_router, flutter_local_notifications, fl_chart to pubspec. Create folder structure. Define Drift schema (Tasks with priority & labels columns, DailyInstances with priority & labels overrides, Settings). Run `build_runner`. |
| 2 | Task CRUD: TaskDao (including `watchTasksByPriority`, `watchTasksByLabel`, `getDistinctLabels`), TaskRepository, task_providers. TaskCreateScreen, TaskEditScreen with priority picker and label chips input, task actions (mark done, close, snooze, undo done). Priority enum + domain model updates. |
| 3 | Today View: TodayScreen with grouped list (pending → snoozed → done → closed), priority-based sorting within groups, priority visual treatment on task tiles, label chips display on tiles, pending count badge, progress bar. Filter chip bar (priority + label filters). Daily task instantiation logic (foreground catch-up). |
| 4 | Calendar View + Backlog View. Month calendar with indicators. Date task list. Backlog grouped by date with filter chip bar. |
| 5 | Reports screen: ReportsDao, ReportsRepository, reports_provider (family by ReportFilter). ReportsScreen with date_range_picker, completion_chart (bar/sparkline via fl_chart), summary_metrics_card, priority_breakdown_table, label_breakdown_table, reports_filter_panel. Wire `/reports` as Tab 3 in ShellRoute. Settings "View Progress" link. |
| 6 | Notifications: NotificationScheduler, notification channels, workmanager setup for midnight rollover. DND bypass channel config. Settings screen (bedtime, morning check-in, notification mode). End-of-Day Resolution screen. Onboarding flow. Edge cases: timezone handling, notification permission denied banner, overdue task handling. Schema migration v3→v4 tested. |

**Exit criteria:** A user can create daily and dated tasks, receive bedtime reminders, and resolve all tasks at end of day -- entirely offline.

### Phase 2 -- Hardening (Weeks 7-10)

**Goal:** Quantified tasks, streaks, polish.

| Week | Deliverables |
|---|---|
| 7 | Quantified task support: `is_quantified`, `target_value`, `target_unit`, `progress_value` fields active. Progress logging UI. 80% threshold logic. Progress bar visual (amber/green). |
| 8 | Streaks table and calculation. Streak badge UI. Skip Today for daily tasks. Target history tracking. Drift schema migration v1→v2. |
| 9 | Polish: large task warning (50+), delete confirmation for daily with pending instance, Android OEM battery optimization prompt, sort order drag-and-drop. |
| 10 | Testing: unit tests for all domain logic, widget tests for core screens, integration test for full task lifecycle. Performance profiling on low-end Android device. |

**Exit criteria:** Quantified tasks work end-to-end. Streaks are tracked. Test coverage >70% on domain logic.

### Phase 3 -- Scale (Weeks 11-18)

**Goal:** Backend, auth, sync, accountability pods.

| Week | Deliverables |
|---|---|
| 11 | Backend monorepo setup. API Gateway with auth middleware. Identity Service with Firebase Auth integration. Deploy to Cloud Run. |
| 12 | Task-Sync Service: push/pull endpoints, MongoDB schema, privacy filtering. Flutter: auth screens, Dio client with interceptors, sync engine. |
| 13 | User-Relationship Service: pod CRUD, invite links, join/leave/dissolve. Flutter: pod creation and invite UI. |
| 14 | Pod data flow: Task-Sync pod-view endpoint. Flutter: pod tab screen, member cards, completion rings, shared task tiles. |
| 15 | Notification Service: BullMQ scheduler, trigger evaluation (bedtime missed, streak broken, quantified pacing, notable completion). FCM dispatch. |
| 16 | Notification batching (2/day cap), correction notifications for retroactive completion, mute preferences. Flutter: FCM push registration, pod notification handling. |
| 17 | Drift schema migration v2→v3 (sync_queue, pod tables). Offline sync queue. Conflict resolution (last-write-wins, progress log merge). |
| 18 | Integration testing: full sync flow, pod triggers, notification dispatch. Load testing notification evaluation at simulated scale. Security audit of privacy filtering. |

**Exit criteria:** Pods are functional with privacy-respecting sync. Notifications fire correctly across timezones. Offline completions sync and correct pod state.

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| iOS Critical Alert entitlement rejected by Apple | Medium | High (DND bypass is a core feature) | Apply early with clear accountability/wellness justification. Fallback: standard notification with max priority; user education to whitelist app in Focus mode. |
| Android OEM background kill prevents midnight rollover | High | Medium (daily tasks not instantiated until app opened) | Foreground catch-up on resume. `workmanager` with inexact alarm fallback. Battery optimization prompt for known OEMs. Worst case: tasks appear on open. |
| Firestore costs scale unexpectedly with real-time listeners | Low | Medium | Pod data uses REST polling, not Firestore listeners, in v1. Direct Firestore access limited to Identity/Relationship (low volume). Monitor read/write counts. |
| MongoDB progress log arrays grow unbounded | Low | Low | Practical cap: daily tasks reset daily; dated tasks are one-off. A task with 100 log entries/day for a year = 36K entries -- still within MongoDB's 16MB document limit. Add archival if needed. |
| Timezone edge cases cause wrong notification timing | Medium | Medium | 15-minute evaluation granularity absorbs most DST/travel shifts. Client-side reschedule on foreground resume. Extensive unit tests for timezone conversion. |
| Sync conflicts cause data loss | Low | High | Local DB is source of truth; server never overwrites local data. Sync is push-only for user's own tasks. Progress logs are append-only, never discarded. Last-write-wins only applies to completion state. |
| Team unfamiliar with Riverpod code-gen | Medium | Low | Code-gen variant reduces manual error. Good documentation. Riverpod has strong community + docs. Initial learning curve is 1-2 days. |
| Single pod per user feels limiting | Medium | Medium (user retention) | v1 constraint simplifies data model and UI. Track user requests for multiple pods. Schema supports it (no hardcoded single-pod assumption in DB); only enforced at join-validation layer. |
| JSON label column query performance on large datasets | Low | Low | SQLite JSON LIKE scan is O(n) over tasks. At Phase 1 scale (<1K tasks per user, local only) this is negligible (<10ms). If it becomes measurable, introduce a junction table via Drift migration. |
| Reports screen slow on large date ranges (>90 days) | Low | Medium (UX) | Soft warning shown at >90 days per spec. ReportsDao queries use indexed date columns. Aggregate computation is done in SQL, not Dart. Test performance up to 365 days during Phase 2 hardening. |
| fl_chart rendering jank on low-end devices | Low | Low | Bar chart renders max 30 bars (sparkline for larger ranges). fl_chart uses Canvas painting, not widgets — minimal widget tree overhead. Profile during Phase 2. |
