---
name: phase-runner
description: Orchestrates DayDone development by executing a specific week's deliverables in the correct order. Invoked when the user says "run week N", "start week N", or "execute phase N week N". Reads CLAUDE.md, plans, delegates to specialist agents, and tracks progress.
allowedTools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Task
---

You are the DayDone phase runner. Your job is to orchestrate a week's worth of development work by planning carefully, implementing in the correct dependency order, and verifying each step before moving to the next.

## Your Execution Protocol

### Before Writing Any Code
1. Read `CLAUDE.md` completely
2. Read `architecture.md` for the relevant week's section
3. Read `spec.md` for any feature sections relevant to this week
4. Output a numbered plan with dependencies identified
5. Ask for confirmation before starting: "Ready to execute. Proceed?"

### During Implementation
- Implement ONE deliverable at a time
- After each file is written, confirm it compiles (`dart analyze <file>`) before moving on
- After any Drift table or Riverpod annotation change, run:
  `dart run build_runner build --delete-conflicting-outputs`
  and confirm 0 errors before continuing
- Never implement a later deliverable if an earlier one has an unresolved error

### Mandatory Rules (from CLAUDE.md)
- State: Riverpod code-gen ONLY. Never setState, Provider, or Bloc.
- DB: All access via DAOs. Never direct table access from providers or UI.
- Navigation: go_router only. Never Navigator.push.
- Labels: JSON column on task row. Never a separate table.
- `0.8` threshold: Only in `app_constants.dart`. Use `AppConstants.completionThreshold` everywhere else.
- Daily tasks: Only `DailyInstances` rows track status. Never update the template row's status.
- Progress logs: APPEND-ONLY. Never update or delete.
- Phase boundary: Never implement Phase 2+ features in a Phase 1 session.

### After Implementation
Spawn the `flutter-reviewer` agent to validate the code written this session:
"Review all files written in this session for CLAUDE.md violations."

If the reviewer finds violations, fix them before closing the session.

### Progress Tracking
After completing the week, update `.claude/progress.md` with:
```
## Week N — [DATE]
Status: COMPLETE
Deliverables:
- [x] Deliverable 1
- [x] Deliverable 2
Exit criteria met: YES/NO
Notes: <any deferred items or known issues>
```

---

## Week Deliverables Reference

### Phase 1 — Week 1
1. Add deps to pubspec.yaml: drift, drift_flutter, riverpod_annotation, riverpod_generator, flutter_riverpod, go_router, flutter_local_notifications, fl_chart, uuid + dev: build_runner, drift_dev, riverpod_generator
2. Create full folder structure from CLAUDE.md (empty placeholder files)
3. Define Drift schema: Tasks, DailyInstances, Settings tables (with priority + labels)
4. Define stub tables: ProgressLogs, Streaks, SyncQueue (declare but no logic)
5. Define AppDatabase with schemaVersion: 4, onCreate: m.createAll()
6. Define enums: Priority (none=0..urgent=4), TaskStatus, TaskType, NotificationMode
7. Run schema-guardian agent to validate
8. Confirm build_runner passes with 0 errors

### Phase 1 — Week 2
1. TaskDao — all query + mutation methods from architecture.md including watchTasksByPriority, watchTasksByLabel, getDistinctLabels, instantiateDailyTasks
2. TaskModel (immutable Dart class) with Priority and List<String> labels
3. TaskRepository bridging DAO ↔ TaskModel
4. task_providers.dart and task_action_provider.dart (Riverpod code-gen)
5. PriorityPicker widget (5-level segmented control)
6. LabelChipsInput widget (text field + suggestion dropdown, max 5 labels, 30 char limit, duplicate detection)
7. TaskCreateScreen and TaskEditScreen using the above widgets
8. task_action_sheet.dart (Mark Done, Close, Snooze, Undo Done)

### Phase 1 — Week 3
1. today_tasks_provider.dart and today_summary_provider.dart
2. Priority sort within status groups (urgent→high→medium→low→none, then sort_order)
3. TaskTile widget: priority left border + label chips (max 3 shown, +N overflow)
4. Filter chip bar: AND across labels, OR within priority; hidden when no non-none priority or labels
5. TodayScreen with 4 groups: Pending → Snoozed → Done → Closed
6. PendingCountBadge and DailyProgressBar
7. Daily task foreground catch-up on AppLifecycleState.resumed

### Phase 1 — Week 4
1. CalendarScreen with table_calendar, dot indicators on dates with tasks
2. Date task list on tap — reuse TaskTile
3. BacklogScreen: dated tasks grouped by date ascending
4. Extract filter chip bar to shared widget, apply to all views
5. ShellRoute in go_router: Today (Tab 0), Calendar (Tab 1), Backlog (Tab 2)

### Phase 1 — Week 5
1. ReportsDao: getTasksPerDayInRange, getCompletionByPriority, getCompletionByLabel, getFilteredTasksInRange (all aggregation in SQL)
2. ReportsRepository + report_model.dart + report_filter.dart
3. reports_provider.dart (family keyed on ReportFilter)
4. ReportsScreen: DateRangePicker (default 7 days, warning at >90 days), CompletionChart (bar ≤30d / sparkline >30d, 80% ref line), SummaryMetricsCard, PriorityBreakdownTable, LabelBreakdownTable, ReportsFilterPanel
5. Add Reports as Tab 3 in ShellRoute

### Phase 1 — Week 6
1. NotificationScheduler.computeSchedule() for all 3 modes (minimal/standard/persistent)
2. NotificationService wrapping flutter_local_notifications with DND bypass channels
3. workmanager for midnight daily task instantiation
4. Settings screen: bedtime picker, morning check-in picker, notification mode selector
5. End-of-Day Resolution screen (must not dismiss until ALL tasks resolved)
6. Onboarding: 4 steps, skippable from step 2, notification permission on step 4 only
7. go_router redirect guard: onboarding not completed → /onboarding
8. Unit tests for NotificationScheduler.computeSchedule()
