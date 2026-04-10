# DayDone — Claude Code Context

## Project Structure

This is a monorepo with two independent roots:

```
daydone/                        ← Flutter project root (you are here)
├── lib/                        ← All Flutter/Dart source code
├── pubspec.yaml
├── CLAUDE.md                   ← This file
└── backend/                    ← Node.js backend server (Phase 3)
    ├── package.json
    ├── src/
    └── ...
```

**Flutter and backend are separate projects with separate dependency systems.**
- Flutter: `pubspec.yaml` at root
- Backend: `package.json` inside `backend/`
- Never install npm packages at the Flutter root. Never add Dart dependencies inside `backend/`.
- When asked to work on backend code, `cd backend/` first.
- **Phase 1 and 2: backend/ folder does not exist yet. Do not create it or reference it.**

---

## What This App Is

DayDone is an **offline-first Flutter todo app** with end-of-day accountability.

Core mechanic: every task must be explicitly resolved before the user's configured bedtime — **tasks are never silently rolled over**. The app escalates reminders as bedtime approaches and blocks app resumption until all tasks are consciously resolved.

---

## Design
All UI must follow .claude/design.md exactly.
Theme files: lib/core/theme/app_colors.dart, app_typography.dart, app_theme.dart.
Never hardcode colours, spacing, or text styles inlin

## Architecture Rules (NON-NEGOTIABLE)

- **State management:** Riverpod with code-gen ONLY (`riverpod_annotation` + `riverpod_generator`). Never use `setState`, `Provider`, or `Bloc`.
- **Local DB:** Drift 2.x (SQLite) ONLY. Never use Hive, Isar, or SharedPreferences for task data.
- **Navigation:** `go_router` ONLY. Never use `Navigator.push` or `Navigator.pushNamed`.
- **DAO layer is mandatory:** All DB access goes through DAOs. No direct Drift table access from UI or providers.
- **After any Drift schema or Riverpod annotation change**, run:
  ```
  dart run build_runner build --delete-conflicting-outputs
  ```
  and confirm it compiles clean before proceeding.

---

## Key Domain Rules

### Task Model
- Task `type` enum: `daily` | `dated`
- Task `status` enum: `pending` | `done` | `closed` | `snoozed`
- Task `priority` enum: `none` | `low` | `medium` | `high` | `urgent` — default `none`
- Task `labels`: JSON array, max 5 items, each max 30 chars — default empty

### Quantified Tasks
- `COMPLETION_THRESHOLD = 0.8` — hardcoded in `lib/core/constants/app_constants.dart`. Never hardcode `0.8` inline anywhere else.
- `progress_value` is **cumulative** (always the total, never an increment)
- `progress_log` is **append-only** — never mutate or delete existing entries
- `is_quantified` cannot be toggled after the first progress log entry is written
- At or above 80%: treated as resolved for streaks and metrics, status stays `pending` visually marked "on track"
- At or above 100%: status → `done`

### Daily Tasks
- Use **template + DailyInstances table** pattern. Never rewrite the template row's status.
- A new `DailyInstance` row is created at midnight (or on foreground catch-up). Historical instances are preserved for streak calculation.
- Changing `priority` on a `daily` template changes it for all future instances. Changing it on a specific instance changes only that instance.

### Priority & Labels
- Priority sorts tasks within each status group: urgent → high → medium → low → none, then by `sort_order`.
- Manual drag-to-reorder overrides sort within the same priority tier.
- Labels are stored as a JSON array on the task row — not a separate table.
- The app derives the list of previously used label strings from the task table on demand (no separate labels table).
- Labels are case-preserved on storage; suggestions are case-insensitive prefix-matched.
- Labels and priority are editable from **any** task status (`pending`, `done`, `closed`, `snoozed`) without triggering a status change.
- Filter bar on Today View: AND logic across label chips, OR logic within priority selection.
- Filter bar is hidden when no tasks today have a non-`none` priority or any labels.

### Notifications
- All notification windows are relative to the user's configured bedtime `T` (range: 6:00 PM – 3:00 AM, 15-minute increments, default 11:00 PM).
- Changing bedtime immediately reschedules all pending notifications for the day.
- If 0 tasks pending: no reminder notifications sent.
- If all tasks resolved before T−1h: send "You're done for the day!" and suppress remaining reminders.

### End-of-Day Resolution Screen
- Triggered on next app open after bedtime if any tasks are `pending` or `snoozed`.
- **Must not dismiss until every task has a resolution** (Done / Move to Tomorrow / Close).
- `daily` tasks are never deleted — only the day's instance is resolved.

---

## Folder Structure

```
lib/
├── main.dart                          # Entry point: ProviderScope, GoRouter setup
├── app.dart                           # MaterialApp.router, theme config
├── core/
│   ├── constants/
│   │   ├── app_constants.dart         # COMPLETION_THRESHOLD = 0.8, MAX_LABELS = 5, etc.
│   │   ├── notification_constants.dart
│   │   └── route_constants.dart
│   ├── database/
│   │   ├── app_database.dart          # @DriftDatabase class, migration strategy
│   │   ├── tables/                    # One file per table
│   │   ├── daos/                      # One file per DAO
│   │   └── converters/
│   ├── extensions/
│   ├── theme/
│   └── utils/
└── features/
    ├── tasks/
    │   ├── data/                      # DAOs, repositories
    │   ├── domain/                    # Models, use-case logic
    │   └── presentation/              # Screens, widgets, providers
    ├── notifications/
    ├── settings/
    ├── onboarding/
    ├── streaks/
    └── pods/                          # Phase 3 only
```

---

## Current Phase

**Phase 1 — MVP (Weeks 1–6).** Fully local, no network, no backend.

- ✅ In scope: Task CRUD, Today/Calendar/Backlog views, notifications, end-of-day resolution, onboarding, priority & labels (added in spec v1.2)
- ❌ Out of scope right now: quantified tasks (Phase 2), streaks (Phase 2), pods (Phase 3), sync (Phase 3), any backend code

**Do not create or reference the `backend/` folder until Phase 3 begins.**

---

## Explicit Non-Goals (v1 + v2)

Do not implement, suggest, or scaffold any of the following:

- AI-generated task suggestions
- Google Calendar / Apple Calendar integration
- Time-blocking or time estimation per task
- Sub-tasks or checklists within a task
- Public pods or stranger-visible social feeds
- Free-text comments within pods (reactions only)
- Label colour-coding (deferred to v2 — requires label management screen)
- Global label management screen

---

## Common Mistakes to Avoid

| Mistake | Correct approach |
|---|---|
| Hardcoding `0.8` for the completion threshold | Use `AppConstants.completionThreshold` |
| Writing directly to a Drift table from a provider | Always go through a DAO method |
| Creating a separate table for labels | Labels are a JSON column on the tasks table |
| Rewriting the daily task template's status | Only write to the `DailyInstances` table |
| Mutating a `progress_log` entry | Append only — never update or delete log entries |
| Running `npm install` at the Flutter root | Backend deps live in `backend/package.json` |
| Adding Phase 3 pod/sync code during Phase 1 | Keep Phase 3 tables in the schema but leave them unused |