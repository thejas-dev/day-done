# Product Requirements Document — DayDone: Daily Todo Tracker

**Document Version:** 1.3  
**Date:** 2026-04-04  
**Status:** Draft — Features Expanded  
**Author:** Senior Product Manager  

---

## SECTION 1 — WORKING BACKWARDS: PRESS RELEASE

### FOR IMMEDIATE RELEASE

**Introducing DayDone — The App That Refuses to Let Your Day End Without Getting Things Done**

*A personal accountability companion that ensures every todo you set for the day is completed before you go to bed.*

People write todos. They don't finish them. There is an entire graveyard of productivity apps filled with tasks that were added with good intention and quietly forgotten by noon. DayDone is different. It is not a passive list. It is an active accountability partner that escalates reminders as your bedtime approaches, ensures nothing slips through to tomorrow without a conscious decision, and celebrates the days when you close everything out.

With DayDone, users set their day's tasks — one-time items tied to a date, or recurring daily habits — and the app works alongside them throughout the day, gently at first and urgently toward the end, to close the loop before sleep. Every morning starts with a clear view of what today holds. Every night ends with a resolved list — completed, closed, or consciously rescheduled — never silently ignored.

DayDone is available for iOS and Android.

---

### PRESS RELEASE FAQ

**Q: Isn't this just another todo app?**  
No. Most todo apps optimise for capture. DayDone optimises for *closure*. The core mechanic is end-of-day accountability, not list management.

**Q: What about tasks I only partially completed — like running 3km when I meant to run 5?**  
DayDone supports quantified tasks. Set a numeric target ("Run 5km") and log your actual progress ("3km done"). The app shows honest progress, not a fake binary. 80% or more counts as success for your streak.

**Q: Can I do this with friends?**  
Yes. Accountability Pods let you join a small group (up to 5 people). If a pod member doesn't finish their shared tasks before their bedtime, the rest of the group gets notified. Your private tasks stay private — you choose which tasks your pod can see.

**Q: What if I genuinely can't finish a task today?**  
You can explicitly "close" a task (acknowledging it won't be done without rescheduling) or reschedule it to tomorrow or a future date. The app requires a conscious action — it will not silently carry tasks forward.

**Q: What makes the notifications different from standard reminders?**  
The notification system is time-contextual. Early in the day, reminders are light — one check-in. As bedtime approaches, frequency increases. In the last 30 minutes of the user's configured "end of day", all pending tasks are surfaced simultaneously as a final accountability push.

**Q: How does the app know when my "end of day" is?**  
Users configure their own personal end-of-day time during onboarding, chosen from a time range picker (selectable in 15-minute increments, any time from 6:00 PM to 3:00 AM). Everyone's bedtime is different — this is a first-class setting, not an afterthought. All notification windows are calculated relative to this time.

---

## SECTION 2 — PROBLEM STATEMENT

Most people maintain a mental or written list of things to do today. The failure mode is not forgetting to write tasks down — it is the absence of accountability when those tasks are not completed. Tasks drift silently into tomorrow, and tomorrow, and the week after. There is no moment of reckoning.

The specific problem DayDone solves: **the gap between task creation and task completion on the same day.**

Secondary problems:

1. Users have both recurring daily habits (e.g., "Exercise", "Read 20 pages") and one-off dated tasks (e.g., "Submit tax return by Friday"). Both need to be supported in a unified interface.
2. Notification fatigue is real. A reminder system that sends too many notifications at the wrong time will be disabled by users. The system must be tunable and feel earned.
3. End-of-day unresolved tasks need a deliberate resolution path — not silent rollover.

---

## SECTION 3 — USER PERSONAS

### Persona 1 — Samir, The Overwhelmed Professional (Primary)

- Age: 31, software engineer, works from home
- Has 6–12 tasks per day across work and personal domains
- Starts days with good intentions, gets derailed by context switching
- **Core need:** A system that holds him accountable without requiring constant manual checking
- **Frustration:** Wakes up and sees 5 undone tasks from yesterday that rolled over silently. Demoralising.

### Persona 2 — Priya, The Habit Builder (Secondary)

- Age: 27, student / early professional
- Focused on building consistent daily habits (meditation, journaling, exercise)
- Uses todo lists as habit trackers; the "mark as done" action is ritually satisfying
- **Core need:** Daily recurring tasks with a visible streak or completion pattern
- **Frustration:** Apps that treat every day as isolated; wants to see her consistency over time

### Persona 3 — Arun, The Light User (Tertiary)

- Age: 45, manager, low tech appetite
- 2–4 tasks per day, mostly one-off reminders
- Does not want to configure much; wants defaults that work
- **Core need:** Minimal friction — add task, get reminded, mark done
- **Frustration:** Complex apps with too many settings and categories

---

## SECTION 4 — FEATURE SPECIFICATION

### 4.1 Task Model

Every task has the following attributes:


| Attribute        | Type                                                                 | Description                                                                             |
| ---------------- | -------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| `id`             | UUID                                                                 | Unique identifier                                                                       |
| `title`          | String (max 200 chars)                                               | What the task is                                                                        |
| `notes`          | String (optional, max 1000 chars)                                    | Additional context                                                                      |
| `type`           | Enum: `daily`                                                        | `dated`                                                                                 |
| `date`           | Date (only for `dated` type)                                         | The specific day this task is due                                                       |
| `status`         | Enum: `pending`                                                      | `done`                                                                                  |
| `created_at`     | Timestamp                                                            | When the task was created                                                               |
| `resolved_at`    | Timestamp (nullable)                                                 | When the task was marked done/closed                                                    |
| `snooze_until`   | Timestamp (nullable)                                                 | If snoozed, when to resurface                                                           |
| `sort_order`     | Integer                                                              | Manual ordering within a day                                                            |
| `is_quantified`  | Boolean (default false)                                              | Whether this task has a numeric target                                                  |
| `target_value`   | Float (nullable)                                                     | Goal quantity — only set when `is_quantified` is true                                   |
| `target_unit`    | String (nullable, max 12 chars)                                      | Display label for the unit (e.g., "km", "pages", "glasses")                             |
| `progress_value` | Float (default 0.0)                                                  | Cumulative progress recorded by the user                                                |
| `progress_log`   | JSON array (nullable)                                                | Timestamped history of each progress update: `[{value, recorded_at}]`                   |
| `pod_visible`    | Boolean (default false)                                              | Whether this task's title and progress are visible to the user's Accountability Pod     |
| `priority`       | Enum: `none` | `low` | `medium` | `high` | `urgent` (default `none`) | Urgency level assigned by the user. Editable at any time regardless of task status.     |
| `labels`         | ListString (max 5 items, each max 30 chars; default empty)           | User-defined tags assigned to the task. Editable at any time regardless of task status. |


**Status definitions:**

- `pending` — Not yet acted upon
- `done` — Completed by the user
- `closed` — Consciously acknowledged as not-done for today, without rescheduling
- `snoozed` — Deferred within the same day to a later time (e.g., "remind me in 2 hours")

**Completion threshold for quantified tasks:** A quantified task is considered successfully resolved when `progress_value >= 0.8 × target_value` (80% rule). This threshold is a product constant applied consistently across streaks, metrics, and pod accountability. Tasks exceeding the target are fully valid — no cap. Tasks below 80% are treated as pending for all accountability purposes despite having partial progress.

`daily` tasks are instantiated fresh each day at midnight. Their historical completion states are stored for streak/analytics purposes but a new pending instance always appears on the current day.

### 4.2 Core Task Actions


| Action       | Available in Status                | Resulting Status                 | Notes                                                                                                                                            |
| ------------ | ---------------------------------- | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Mark Done    | pending, snoozed                   | done                             | For binary tasks: one tap. For quantified tasks: opens a progress input bottom sheet (see Section 12). Reversible within same day.               |
| Log Progress | pending, snoozed (quantified only) | pending (or done if ≥80% target) | Updates `progress_value`. Can be called multiple times; always sets a cumulative total, not an increment.                                        |
| Undo Done    | done                               | pending                          | Allowed until midnight                                                                                                                           |
| Close        | pending, snoozed                   | closed                           | Requires no explicit reason in v1; prompts brief optional note in v2                                                                             |
| Snooze       | pending                            | snoozed                          | User picks duration: 30m, 1h, 2h, or custom time                                                                                                 |
| Reschedule   | pending, snoozed, closed           | pending (new date)               | Moves a `dated` task to a new date. `daily` tasks cannot be rescheduled (they always repeat)                                                     |
| Skip today   | pending (daily tasks only)         | skipped                          | Marks this day's instance as resolved without completing it. Streak counts skip as "excused". Task resumes tomorrow. Optional skip reason.       |
| Delete       | any                                | —                                | Soft delete. `daily` tasks: deletes all future instances. Confirms before deletion                                                               |
| Edit         | pending, snoozed                   | pending                          | Title and notes editable. Type and date editable only before end-of-day. `priority` and `labels` are editable from any status (see Section 4.7). |


### 4.3 Task Views

**Today View (default home screen)**

- Shows all tasks due today: all `daily` tasks + all `dated` tasks with today's date
- Grouped by status: Pending → Snoozed → Done → Closed
- Pending count shown prominently as a badge/counter
- Progress bar showing % of today's tasks resolved (done + closed / total)

**Calendar / Date View**

- Month calendar with indicators on dates that have tasks
- Tap a date to see tasks for that date
- Future dates show pending `dated` tasks; past dates show completed/closed states
- `daily` tasks always appear on every date

**All Tasks / Backlog View**

- Shows all `dated` tasks across all dates grouped by date
- Allows bulk reschedule for overdue items

### 4.4 Notification System

This is the core differentiation of DayDone. The notification model is time-contextual and escalates toward the user's configured end-of-day.

**User-configured inputs:**

- **End of Day Time:** Time at which the day is considered over. User-selected via time range picker (6:00 PM – 3:00 AM, in 15-minute increments). Default: 11:00 PM. Prominently set in onboarding and editable in settings at any time. Changing it immediately reschedules all pending notifications for the day.
- **Morning Check-in Time:** When the user wants a morning summary (default: 8:00 AM)
- **Notification Frequency Mode:** `minimal` | `standard` | `persistent` (default: standard)

**Notification schedule (relative to bedtime `T`):**


| Time Window                     | Minimal                         | Standard                        | Persistent                          |
| ------------------------------- | ------------------------------- | ------------------------------- | ----------------------------------- |
| Morning check-in (configurable) | Summary of today's tasks        | Summary of today's tasks        | Summary of today's tasks            |
| T − 4h                          | —                               | Pending count reminder          | Pending count reminder              |
| T − 2h                          | —                               | Pending count + list preview    | Pending count + list preview        |
| T − 1h                          | Pending reminder                | Urgent: list of remaining tasks | Urgent: list of remaining tasks     |
| T − 30m                         | Urgent: list of remaining tasks | Final push: full list           | Final push: full list               |
| T − 10m                         | —                               | —                               | Last call: every pending task named |
| T (bedtime)                     | —                               | Day summary                     | Day summary                         |


**Notification content rules:**

- If 0 tasks pending: no reminder notifications sent (only morning summary)
- If all tasks are done/closed before T − 1h: send a "You're done for the day!" confirmation and suppress remaining reminders
- Snoozed tasks surface at their snooze expiry time regardless of the general schedule

**Notification text examples:**

- T − 2h: "3 tasks still pending. Bedtime in 2 hours — you've got this."
- T − 30m: "Last chance — 2 tasks unfinished: 'Email invoice', 'Call dentist'"
- T − 30m (quantified, partial): "Run 5km — you're at 3km. Bedtime in 30 minutes."
- Completion: "All done for today. Great work."

**Pod (social) notification triggers** — sent server-side to other pod members (requires backend, Phase 3):


| Trigger                        | Condition                                             | Recipient             | Message                                                                                                    |
| ------------------------------ | ----------------------------------------------------- | --------------------- | ---------------------------------------------------------------------------------------------------------- |
| Bedtime missed                 | Member passes bedtime with ≥1 task unresolved         | All other pod members | "Alex didn't finish their tasks for today. They had 2 left at bedtime." (private task titles not revealed) |
| Streak broken                  | Member breaks a streak of 7+ days                     | All other pod members | "Alex's 12-day streak ended. Send some encouragement."                                                     |
| Quantified task falling behind | Shared quantified task <50% at T−1h                   | All other pod members | "Alex has 'Run 5km' at 2/5km with 1 hour left." — fires once per task per day                              |
| Full completion (notable)      | Member completes all tasks; prior 7-day rate was <60% | All other pod members | "Alex finished everything today."                                                                          |


**Pod notification caps:** Recipients receive at most 2 social notifications per 24-hour period regardless of how many pod members miss their deadlines. Multiple missed members are batched: "Alex and 2 others didn't finish their tasks tonight." Pod members can individually mute notifications from a specific member without leaving the pod or alerting that member.

### 4.5 End-of-Day Resolution Flow

At bedtime (`T`), if any tasks remain `pending` or `snoozed`, the app triggers an **End-of-Day Resolution Screen** on next app open (or via notification tap).

This screen:

1. Lists all unresolved tasks for today
2. For each, prompts the user to choose: **Done** | **Move to Tomorrow** | **Close**
3. Does not dismiss until all tasks have a resolution
4. "Move to Tomorrow" creates a new `dated` task for tomorrow (for `dated` tasks) or adds a note to the `daily` task instance

`daily` tasks are never deleted by this flow — a new instance always appears tomorrow. The resolution screen records the outcome for today's instance.

### 4.6 Onboarding

1. **Step 1 — Bedtime setup:** Ask the user when their day typically ends. Explain why (used for reminders). Default: 11:00 PM.
2. **Step 2 — Morning check-in:** Ask when they want their morning summary. Default: 8:00 AM.
3. **Step 3 — First task:** Prompt user to add their first task to make the experience tangible before leaving onboarding.
4. **Step 4 — Notification permission:** Request permission with explicit explanation of what notifications will contain and when. Do not request before Step 3.

Onboarding is skippable from Step 2 onward. Skipped steps use defaults.

### 4.7 Task Priority & Labels

#### 4.7.1 Overview

Priority and labels give users a lightweight layer of organisation on top of the existing task model. Priority signals urgency; labels group tasks by domain (e.g., "work", "health", "finance"). Both are entirely user-driven — the app never assigns or suggests a priority automatically, and never creates labels on the user's behalf.

#### 4.7.2 Priority

**Values:** `none` | `low` | `medium` | `high` | `urgent`

- Default is `none` for all newly created tasks.
- Priority is set at task creation via a priority picker in the creation/edit form (see 4.7.5). It may be changed at any time, including when the task is `done` or `closed` — this allows users to re-evaluate priority after the fact for personal record-keeping without triggering a status change.
- Priority is stored on the task row (see Section 4.1) and is therefore preserved across daily task instances. Changing priority on a `daily` task template changes it for all future instances. Changing it on a specific day's instance changes only that instance.

**Visual treatment on task tiles:**


| Priority | Colour treatment                                      | Icon indicator                            |
| -------- | ----------------------------------------------------- | ----------------------------------------- |
| `none`   | No decoration                                         | None                                      |
| `low`    | Subtle cool-grey left border or muted badge           | Optional: single downward chevron         |
| `medium` | Amber/yellow left border or badge                     | Optional: dash icon                       |
| `high`   | Orange left border or badge                           | Single upward chevron or filled flag      |
| `urgent` | Red left border or badge; task title rendered in bold | Double upward chevrons or filled red flag |


The exact visual tokens are defined at the theme layer. The requirements are: (a) priority must be distinguishable at a glance without reading text, (b) `urgent` must be unambiguous even in peripheral vision, and (c) the visual treatment must not impair readability of the task title.

**Sorting:** Within each status group on the Today View, tasks are sorted first by `priority` descending (urgent → high → medium → low → none) and then by `sort_order`. Manual drag-to-reorder overrides this sort within its priority tier.

#### 4.7.3 Labels

**Data constraints:**

- A task may have 0 to 5 labels.
- Each label is a user-defined string, max 30 characters.
- Labels are not normalised at the data layer — "Work" and "work" are stored as entered. The UI surface (see 4.7.4) provides suggestions from previously used labels to naturally converge on consistent spelling.
- Labels are stored as a JSON array on the task row (see `labels` field in Section 4.1).
- There is no global label management screen in v1. Labels exist only as attached task attributes.

**Persistence of used labels:** The app maintains a locally-derived list of all distinct label strings the user has ever applied to any task. This list powers the suggestion UI (4.7.5) and is re-derived from the task table on demand — it is not a separate stored table, to avoid sync complexity.

**Editable at any time:** Labels may be added or removed from a task regardless of its status (`pending`, `done`, `closed`, `snoozed`). Changing labels does not alter the task's `status`, `resolved_at`, or any other field.

#### 4.7.4 Visual Treatment on Task Tiles

Labels are displayed as inline chips on the task tile, positioned below the task title and above the progress bar (if applicable).

**Chip display rules:**

- Display up to 3 chips inline. If a task has 4 or 5 labels, show the first 3 and a "+N more" overflow chip.
- Chips use a compact style: small font, pill-shaped, light background fill derived from the app's theme neutral palette. Labels are not individually colour-coded in v1 (colour-coding is deferred to v2 — it requires a label management screen to assign colours, which is out of scope here).
- Chips are non-interactive on the task tile in the Today View. Tapping the task tile opens the edit sheet as normal. The chips are display-only at list level.
- If a task has no labels, no chip row is rendered (no empty space reserved).

#### 4.7.5 Task Creation / Edit Form

The task creation form and the task edit sheet both gain two new sections:

**Priority picker:**

- Displayed as a segmented control or a horizontal row of selectable option tiles showing the five priority levels (`none`, `low`, `medium`, `high`, `urgent`) with their respective colour indicators.
- Default selection: `none`.
- Only one value may be selected at a time.

**Label management UI:**

- A text input field labelled "Add label" with a character counter (0/30).
- As the user types, a suggestion dropdown appears below the input showing any previously used labels that match the typed prefix (case-insensitive). Selecting a suggestion adds it without requiring the user to finish typing.
- Pressing the add/confirm action (Enter or a "+" button) adds the typed label as a chip in the current-labels area above the input.
- Current labels are shown as dismissible chips. Tapping the "×" on a chip removes that label.
- If the user attempts to add a 6th label, the input is blocked and an inline error appears: "Maximum 5 labels per task."
- If the user attempts to add a label exceeding 30 characters, the input is blocked at 30 characters with a gentle character-count warning at 25 characters.
- Duplicate label detection: if the user adds a label that already exists on the task (case-insensitive match), the duplicate is silently rejected and the existing chip is briefly highlighted.

#### 4.7.6 Filtering and Sorting by Priority / Labels

**Today View filter bar:**

- A horizontally scrollable filter chip bar appears above the task list when the user has tasks with at least one non-`none` priority or at least one label. It is hidden otherwise to keep the UI clean for new users.
- Filter chips available: one chip per active label used in today's tasks + priority level chips for any priority value present today.
- Multiple chips may be active simultaneously; the filter applies AND logic across label chips and OR logic within priority selection (i.e., showing "urgent OR high" with a "work" label means: tasks that are [urgent or high priority] AND [labelled "work"]).
- An "All" chip is always present and clears all active filters when tapped.
- Active filter state is transient — it resets when the user navigates away from Today View. It is not persisted across sessions.

**All Tasks / Backlog View:** The same filter bar pattern applies, scoped to the tasks visible in that view.

#### 4.7.7 Edge Cases


| Scenario                                                   | Behaviour                                                                                                                                                                  |
| ---------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| User imports/migrates tasks from an older version          | Tasks without `priority` field default to `none`. Tasks without `labels` field default to empty list. Schema migration handled by Drift migration (see Section 7.2).       |
| `daily` task priority changed on a past instance           | Only the specific past instance is changed. The template and future instances are unaffected.                                                                              |
| `daily` task priority changed on the template (via edit)   | All future instances inherit the new priority. Past instances are not retroactively changed.                                                                               |
| Label string contains only whitespace                      | Rejected on form submission. Trim is applied before validation; a blank-after-trim label is not accepted.                                                                  |
| User removes all labels from a task                        | The `labels` field is stored as an empty JSON array `[]`. No error.                                                                                                        |
| Label in suggestion list that no longer exists on any task | The suggestion list is re-derived from active task data. If all tasks with a given label are deleted, that label disappears from suggestions naturally on next derivation. |


---

### 4.8 Progress / Reports Screen

#### 4.8.1 Overview

The Reports screen gives users a read-only, data-driven view of their task completion history. It is designed to answer the question: "How have I actually been doing?" — not to prompt any action. No task state can be modified from this screen. The Reports screen is accessible via the main navigation bar (a dedicated "Reports" or "Progress" tab) or via a shortcut in Settings.

#### 4.8.2 Date Range

- **Default range on open:** Last 7 days (from 7 days ago through yesterday, inclusive; today is excluded from the default range as the day may be incomplete).
- Users may change the date range via a date range picker component. The picker allows selection of any start and end date; start must be on or before end.
- Practical upper limit: the picker does not block large ranges, but the app surfaces a soft warning if the range exceeds 90 days: "Large date ranges may take a moment to load." Performance is the only constraint.
- The selected date range persists for the session. It resets to the default 7-day range on next app open.

#### 4.8.3 Summary Metrics

At the top of the Reports screen, a summary card shows aggregate counts for the selected date range:


| Metric                  | Definition                                                                                                                                                                                                                                                |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Tasks Created           | Total distinct task instances created (or active) within the range, across all types and statuses                                                                                                                                                         |
| Completed               | Count of task instances resolved as `done` (including quantified tasks that met the 80% threshold)                                                                                                                                                        |
| Closed                  | Count of task instances resolved as `closed`                                                                                                                                                                                                              |
| Pending / Unresolved    | Count of task instances that ended the day as `pending` (overdue) within the range — excludes today if today is in range and the day is not yet over                                                                                                      |
| Overall Completion Rate | `done` count ÷ (total non-`closed` task instances) × 100%. Expressed as a percentage, rounded to one decimal place. `closed` tasks are excluded from both numerator and denominator on the basis that a closed task was a conscious decision, not a miss. |


#### 4.8.4 Per-Day Completion Chart

A bar chart (or sparkline for ranges > 30 days) displaying the daily completion rate for each day in the selected range.

**Chart specification:**

- X-axis: dates in the selected range (one bar per day).
- Y-axis: completion rate from 0% to 100%. A horizontal reference line is drawn at 80% (the product's completion threshold constant `COMPLETION_THRESHOLD`).
- Bar colour: green if the day's rate is ≥ 80%; amber if 50–79%; red if < 50%. Days with zero tasks are rendered as an empty/grey bar with a distinct pattern to distinguish them from 0% completion days with tasks.
- Tapping a bar shows a tooltip: "Apr 2 — 4 of 5 tasks done (80%)."
- For ranges > 30 days, switch to a sparkline to keep the chart readable. The sparkline uses the same colour logic encoded as line colour at each data point.
- The chart is not interactive beyond tap-for-tooltip.

#### 4.8.5 Streak Data

Below the chart, a streak summary section shows:

- **Current streak:** Number of consecutive days (ending yesterday or today if today is complete) where all tasks met the resolution criteria (all tasks `done` or `closed`; quantified tasks at ≥ 80%).
- **Longest streak:** All-time longest consecutive day streak.
- **Scope:** Streak calculation uses the same logic as the main streak mechanic. Days with zero tasks do not break a streak (consistent with the app's general streak rules). `daily` task skips count as resolved.

If the selected date range does not include the current streak's start date, the streak values shown are scoped to the selected range, not the all-time values. A label clarifies: "Within selected range" vs. "All time."

#### 4.8.6 Breakdown by Priority

A grouped summary showing, for each priority level present in the selected range:


| Column          | Definition                                                       |
| --------------- | ---------------------------------------------------------------- |
| Priority        | `urgent` / `high` / `medium` / `low` / `none`                    |
| Total           | Total task instances at that priority level in the range         |
| Completed       | Count resolved as `done` (80% rule applies for quantified tasks) |
| Missed          | Count that ended as `pending` or overdue                         |
| Completion Rate | Completed ÷ (Completed + Missed) × 100%                          |


Only priority levels that have at least one task in the selected range are shown. If no tasks have a non-`none` priority, this section is collapsed with a note: "No tasks with a priority level in this range."

#### 4.8.7 Breakdown by Label

A list showing, for each label used in the selected range:


| Column          | Definition                                               |
| --------------- | -------------------------------------------------------- |
| Label           | The label string                                         |
| Total           | Total task instances tagged with this label in the range |
| Completed       | Count resolved as `done`                                 |
| Missed          | Count ending as `pending` or overdue                     |
| Completion Rate | Completed ÷ (Completed + Missed) × 100%                  |


A task with multiple labels appears in each label's row independently — a task tagged "work" and "health" contributes to both rows. The totals across label rows will therefore not sum to the total task count. This is by design and is communicated to the user via a footnote: "A task with multiple labels is counted once per label."

If the user has no labelled tasks in the selected range, this section is collapsed with a note: "No labelled tasks in this range."

#### 4.8.8 Filters

A filter panel is accessible from the Reports screen via a filter icon button in the screen header. All active filters are displayed as chips below the header. Filters narrow the data shown in all sections (summary card, chart, breakdown tables) simultaneously.

Available filters:


| Filter       | Type                             | Behaviour                                                                                  |
| ------------ | -------------------------------- | ------------------------------------------------------------------------------------------ |
| By label(s)  | Multi-select                     | Show only tasks tagged with any of the selected labels (OR logic within the label filter). |
| By priority  | Multi-select                     | Show only tasks at any of the selected priority levels (OR logic).                         |
| By task name | Text substring                   | Case-insensitive substring match against `title`. Minimum 1 character.                     |
| By task type | Toggle: `daily` / `dated` / both | Filter to only daily tasks, only dated tasks, or both (default).                           |


**Combined filter logic:** All active filters are combined with AND logic. Example: label = "work" AND priority = urgent|high AND type = daily means: show only daily tasks tagged "work" that are urgent or high priority.

**Filter persistence:** Filter state is transient and resets when the user leaves the Reports screen. There is no saved filter in v1.

**Empty state:** If the active filters match no tasks in the selected range, the screen shows an empty state illustration with the message: "No tasks match these filters in the selected period." The filter chips remain visible so the user can adjust them.

#### 4.8.9 Read-Only Constraint

The Reports screen is strictly read-only. There are no swipe actions, no checkboxes, no action buttons on individual tasks. Users cannot change task status, priority, labels, or any other field from this screen. Task titles are displayed for reference but are not tappable links to the task detail. This constraint is intentional: the Reports screen is a reflection surface, not an action surface.

#### 4.8.10 Navigation and Placement

- The Reports screen is a top-level navigation destination: accessible via the main bottom navigation bar as a dedicated tab (icon: chart or similar).
- It is also accessible from the Settings screen via a "View Progress" entry for discoverability among users who do not use bottom nav tabs.
- Deep-link path (go_router): `/reports`
- The back button returns to the previous screen.

#### 4.8.11 Edge Cases


| Scenario                                                     | Behaviour                                                                                                                                                                                                 |
| ------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Selected range has no tasks                                  | Summary card shows all zeros. Chart renders empty. Breakdown sections show their respective empty-state messages.                                                                                         |
| Today is included in the range                               | Today's data is included with a visual indicator ("Today — in progress") on the chart bar. The overall completion rate treats today's `pending` tasks as neither completed nor missed until the day ends. |
| User changes date range                                      | All sections re-query and re-render. A loading indicator is shown during re-render. Previous data is not preserved (no stale rendering).                                                                  |
| Very old date range (> 1 year ago)                           | Supported. No data archiving in v1 — all history is stored in local SQLite. Performance on large ranges is tested up to 365 days.                                                                         |
| `daily` task with entries spanning multiple range boundaries | Only the instances whose `date` falls within the selected range are included. Instances outside the range are excluded even if the template was created before the range start.                           |


---

## SECTION 5 — EDGE CASES & FAILURE STATES

### 5.1 Notifications Denied

- If the user denies notification permission, the app functions fully as a manual tracker
- A persistent (but dismissable) in-app banner reminds the user that reminders are disabled and offers a path to re-enable
- The banner reappears after 7 days if not acted upon; never again after the second dismissal

### 5.2 App Killed / Background Restrictions (Android)

- On Android, background notification delivery is not guaranteed across all OEMs (e.g., Xiaomi, OnePlus aggressively kill background processes)
- The onboarding and settings screen will surface a battery optimization prompt for known restrictive OEMs, linking to dontkillmyapp.com guidance
- Notifications are scheduled via `flutter_local_notifications` with `AndroidAlarmManager` exact alarm where possible; fallback to inexact alarms on restricted devices
- The app will request **Do Not Disturb override permission** on both iOS (Critical Alerts entitlement) and Android (high-priority / full-screen intent channel) — this is core to the product goal of ensuring task completion. The final T−10m and bedtime notifications use this channel. Clearly explained to users during onboarding: "DayDone needs to reach you even if your phone is on silent — this is how it keeps you accountable."
- The app must not present itself as reliable for critical reminders on heavily restricted OEMs; a one-time advisory is shown on those devices

### 5.3 Timezone / Device Clock Changes

- All task dates are stored in local date (YYYY-MM-DD) without timezone, as tasks are personal/local by nature
- Notification times are recalculated on each app foreground if the device timezone changes
- Daylight saving transitions: the system recalculates bedtime-relative notifications at midnight each day

### 5.4 Missed End-of-Day (App not opened)

- If the user does not open the app on a given day, `dated` tasks for that day are marked `overdue` (a sub-state of pending) at midnight
- `overdue` tasks appear at the top of the Today View the following morning with a distinct indicator ("From yesterday")
- The user must explicitly resolve overdue tasks; they do not auto-close

### 5.5 Large Number of Tasks

- UI is tested for graceful rendering with up to 50 tasks per day
- Beyond 50 tasks, a warning is surfaced: "You have a lot of tasks today. Consider closing some to stay focused."
- No hard cap enforced; performance is monitored

### 5.6 Daily Tasks and First-Time Appearance

- `daily` tasks are created once and appear on every subsequent day's Today View
- They do not appear retroactively on past dates (i.e., creating a `daily` task on April 10 does not populate April 1–9 in the calendar view)

### 5.7 Offline Behaviour

- All task data is local-first (stored on device)
- No network dependency for core functionality in v1
- Notifications are entirely local; no server-push dependency

### 5.8 Task Deletion Edge Cases

- Deleting a `daily` task while it has a pending instance for today: confirm dialog states "This will remove the task from today and all future days."
- Deleting a `done` task: allowed, but prompts "This will also remove your completion record for today."
- No bulk delete in v1 (too destructive without undo infrastructure)

---

## SECTION 6 — METRICS FRAMEWORK

### 6.1 North Star Metric

**Daily Resolution Rate** — percentage of `pending` tasks on a given day that are resolved as `done` or `closed` (i.e., not left as `pending` at midnight) — measured per user, averaged across the cohort.

> Target (D30): 70% of active users achieve ≥80% resolution rate on their active days.

### 6.2 Input Metrics (Controllable)


| Metric                                       | Target                                                    | Why it matters                                                      |
| -------------------------------------------- | --------------------------------------------------------- | ------------------------------------------------------------------- |
| Notification delivery rate                   | >95% (where permitted)                                    | Reminders only drive behaviour if delivered                         |
| End-of-Day resolution screen engagement rate | >60% of users who see it take an action within the screen | Measures whether the accountability mechanic works                  |
| Morning check-in open rate                   | >30%                                                      | Signals that users value the daily planning moment                  |
| Snooze rate per task                         | <25% of all reminder interactions                         | High snooze rate means reminders are poorly timed                   |
| Onboarding completion rate                   | >75%                                                      | Incomplete onboarding = no bedtime set = broken notification system |


### 6.3 Output Metrics


| Metric                               | Description                                            |
| ------------------------------------ | ------------------------------------------------------ |
| D7 Retention                         | % of users who open the app on 5 of their first 7 days |
| D30 Retention                        | % of users still active at day 30                      |
| Daily Resolution Rate                | North star (above)                                     |
| Weekly task completion streak length | Avg consecutive days with ≥1 task completed            |


### 6.4 Counter-Metrics (Guard Rails)


| Growth Metric                  | Counter-Metric                       | Risk being guarded against                                                            |
| ------------------------------ | ------------------------------------ | ------------------------------------------------------------------------------------- |
| Notification sends per day     | Notification disable rate            | Sending too many reminders causes users to turn off notifications entirely            |
| Tasks created per user per day | Task closure-without-completion rate | If users are "closing" tasks instead of doing them, the app may be training avoidance |
| End-of-day screen shown        | User force-quit rate on that screen  | If the resolution screen causes frustration and exits, it's counter-productive        |


---

## SECTION 7 — TECHNICAL ARCHITECTURE

### 7.0 Backend Architecture (Phase 3+)

Phase 1 and 2 are entirely local (no backend). Phase 3 introduces Accountability Pods which requires a cloud backend. The following microservices are required:


| Service                       | Responsibility                                                                                                                                                                                                                                                   |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Identity Service**          | User registration, login, JWT issuance/refresh, device token registration. Unblocking dependency for all social and sync features. Email+password in v1; Apple/Google OAuth fast-follow.                                                                         |
| **User-Relationship Service** | Pod creation, membership (invite, accept, leave, remove), pod settings. Deliberately decoupled from Identity to allow the social graph model to evolve independently.                                                                                            |
| **Task-Sync Service**         | Receives task state changes from clients; persists and broadcasts only pod-permitted fields (completion signal for private tasks; title + progress for `pod_visible` tasks). Full task records including private notes never leave the device for private tasks. |
| **Notification Service**      | Evaluates pod trigger conditions on schedule (bedtime miss, streak break, quantified pacing, completion). Composes and dispatches payloads via APNs and FCM. Timezone-aware per pod member.                                                                      |
| **API Gateway**               | Single entry point for the Flutter client. Auth token validation, rate limiting, request routing.                                                                                                                                                                |


**Flutter client additions required for Phase 3:**

- Auth screens (login/register) and secure token storage (`flutter_secure_storage`)
- Dio HTTP client with auth header interceptor, retry logic, and offline task queue
- Conflict resolution strategy: last-write-wins by server timestamp for task completion state
- Push registration: device token handshake with Notification Service on login

**Architecture note:** The local SQLite database remains the source of truth for the user's own tasks. The backend holds a derived, privacy-filtered view for pod purposes only. The app must function fully offline; completions recorded offline sync when connectivity restores.

---

### 7.1 Platform Targets (v1)

- **iOS** (primary)
- **Android** (primary)
- macOS, Windows, Linux, Web — deferred to v2 (Flutter supports all; enable when product is validated on mobile)

### 7.2 Local Data Layer

- **Storage:** `drift` (type-safe SQLite wrapper for Flutter) — chosen over Hive for relational query support (tasks by date, status filters)
- **Schema migrations:** Managed via `drift` migration system from v1 forward
- No remote backend in v1. Cloud sync is a v2 feature.

### 7.3 State Management

- `**riverpod`** (code generation variant) — reactive, testable, no BuildContext dependency
- Key providers: `todayTasksProvider`, `tasksByDateProvider`, `settingsProvider`, `notificationSchedulerProvider`

### 7.4 Notification Layer

- **Package:** `flutter_local_notifications` + `timezone` package for accurate scheduling
- All notifications are scheduled locally at midnight each day for the following day's windows
- A background isolate (via `workmanager`) reschedules notifications daily to handle app-not-open scenarios
- Notification tap deep-links to Today View or End-of-Day Resolution Screen as appropriate

### 7.5 Key Packages (Recommended)


| Concern                         | Package                                       |
| ------------------------------- | --------------------------------------------- |
| Local DB                        | `drift`                                       |
| State management                | `flutter_riverpod` + `riverpod_annotation`    |
| Notifications                   | `flutter_local_notifications`                 |
| Background tasks                | `workmanager`                                 |
| Date/time handling              | `clock` (for testability) + `timezone`        |
| Navigation                      | `go_router`                                   |
| UI theming                      | Flutter Material 3                            |
| HTTP client (Phase 3+)          | `dio` with interceptors                       |
| Secure token storage (Phase 3+) | `flutter_secure_storage`                      |
| Push notifications (Phase 3+)   | `firebase_messaging` (FCM) + APNs entitlement |


### 7.6 Folder Structure (Recommended)

```
lib/
  features/
    tasks/
      data/          # Drift tables, DAOs, repository impl
      domain/        # Task entity, enums, repository interface
      presentation/  # Riverpod providers, widgets, screens
    notifications/
      notification_scheduler.dart    # Local notification scheduling
      notification_service.dart      # Dispatch + DND channel management
    settings/
      data/
      presentation/
    reports/
      data/          # Query layer for aggregating task history (read-only, no DAOs mutate here)
      domain/        # Report model, date range value object, filter state
      presentation/  # Riverpod providers, chart widgets, filter panel, reports screen
    auth/                            # Phase 3 — login/register screens, token management
    pods/                            # Phase 3 — pod creation, membership, member view
    sync/                            # Phase 3 — offline queue, conflict resolution, API client
  core/
    routing/         # go_router config
    theme/
    utils/
```

---

## SECTION 8 — PHASED ROADMAP

### Phase 1 — Foundation (MVP)

**Goal:** Prove the core accountability loop works. Ship to TestFlight/internal testing.

**Scope:**

- Task creation (title only, type: daily/dated, date picker for dated)
- Today View with pending/done/closed grouping
- Mark done, close, delete actions
- Bedtime configuration
- Basic notification schedule (T−2h, T−30m, morning summary)
- End-of-Day Resolution Screen
- Local SQLite persistence

**Out of scope:** Notes, snooze, calendar view, streaks, undo, all counter-metrics

**Success criteria:** 3 internal users use it for 14 consecutive days without reverting to another tool.

---

### Phase 2 — Engagement & Polish

**Goal:** Improve daily habit formation, reduce notification friction, and introduce quantified accountability.

**Scope:**

- Task notes field
- Snooze action (30m, 1h, 2h, custom)
- Undo "Mark Done" (within same day)
- Calendar / Date View
- Notification frequency mode (minimal / standard / persistent)
- Daily task "Skip today" action with optional reason
- Overdue task handling ("From yesterday" indicator)
- Android battery optimisation prompt
- D7 / D30 retention instrumentation (local analytics only)
- **Quantified tasks** (Section 12) — numeric target + progress logging, 80% rule, honest progress display

**Success criteria:** D14 daily resolution rate ≥70% across active users. Quantified task adoption: ≥25% of active users create at least one quantified task within their first 14 days.

---

### Phase 3 — Social Accountability

**Goal:** Introduce Accountability Pods to drive cross-user engagement, retention, and organic growth.

**Prerequisites (pull forward from Phase 4):** User accounts (Identity Service) and cloud infrastructure must be available. Account creation ships as optional in Phase 2 (no features require it yet) to build the user base before Phase 3 depends on it.

**Scope:**

- User accounts and authentication (email+password; Apple/Google OAuth)
- Identity Service, User-Relationship Service, Task-Sync Service, Notification Service, API Gateway (see Section 7.0)
- Accountability Pods (Section 11): creation, membership, pod view, privacy toggles
- Cross-user server-push notifications for bedtime miss, streak break, quantified pacing, notable completion
- Cloud sync across user's own devices (included because infrastructure is already built)
- Daily task streaks with pod-visible streak display
- Weekly completion summary notification

**Success criteria:** ≥30% of Phase 3 users who have been active for 14+ days create or join a pod within 7 days of feature launch. Pod members show ≥15% higher D30 retention than non-pod users.

---

### Phase 4 — Depth & Platform Expansion

**Goal:** Reward long-term users and expand platform reach.

**Scope:**

- Reschedule action for dated tasks
- Bulk actions on All Tasks view
- Home screen widget (iOS/Android) showing today's pending count
- Label colour-coding (requires a label management screen to assign per-label colours; promoted from the Phase 4 "categories / tags" item — base labels and priorities shipped in the current phase)
- macOS and web targets
- Natural language task input ("Call dentist tomorrow at 3pm")

---

## SECTION 9 — OPEN QUESTIONS

These must be resolved before Phase 1 development begins:

1. **What is the exact definition of "a new day"?** Midnight by device local time is assumed. Does a task created at 11:55 PM for "today" appear in today or tomorrow's view?
  → Decision needed: recommend midnight cutoff; tasks created after midnight go to tomorrow.
2. **Can a `daily` task be temporarily paused for a specific date?** (e.g., "Rest day from exercise" on Saturday)
  → **Yes — promoted to Phase 2.** Users can "Skip today" on any `daily` task instance. The skip is recorded (counts as resolved for that day's streak calculation) and the task resumes normally the following day. A skip reason is optional.
3. **What happens to tasks if the user changes their bedtime after notifications are already scheduled?**
  → **Resolved:** Changing End of Day time in settings immediately cancels and reschedules all pending notifications for the current day. A confirmation toast is shown: "Reminders updated to your new end-of-day time."
4. **Should the app support multiple notification channels / Do Not Disturb passthrough?**
  → **Resolved:** DND bypass is a core feature, not optional. The goal is task completion by any means necessary. Final push notifications (T−10m and bedtime) use a high-priority channel with DND override on both iOS (Critical Alerts) and Android (full-screen intent). This is explained clearly in onboarding. Promote to Phase 1 MVP scope.
5. **What is the minimum iOS version target?**
  → **Resolved:** iOS 16+ minimum target.

---

## SECTION 11 — ACCOUNTABILITY PODS

### 11.1 Overview

Accountability Pods are small, private groups of 2–5 people who hold each other responsible for daily task completion. A pod member who fails to finish their shared tasks before their bedtime triggers a notification to the rest of the group. The core mechanic is social pressure applied at the exact moment of individual failure — not a feed, not a leaderboard, not a chat.

One pod per user in v1. This constraint prevents the multi-pod performance optimization problem where users join several groups and only share tasks where they are likely to succeed. One ground truth, one social commitment.

### 11.2 Pod Structure and Formation


| Attribute     | Detail                                                                                       |
| ------------- | -------------------------------------------------------------------------------------------- |
| Members       | 2–5 users (including the creator)                                                            |
| Formation     | Invite via shareable link or direct username search                                          |
| Pods per user | 1 (v1)                                                                                       |
| Pod settings  | Display name, member list. Each member keeps their own personal bedtime — no shared bedtime. |


**Invite flow:** Pod creator shares a link (expires in 48 hours) or searches by username. Invited user receives an in-app notification and must explicitly accept. Joining a pod that is already at 5 members shows an error and does not consume the invite.

**Leaving a pod:** Any member can leave at any time. The pod continues with remaining members. If the pod drops below 2 members, it is dissolved and all members are notified. Pod creator can remove a member; removal is silent (no notification to the removed member).

### 11.3 Privacy Model

The privacy model is designed around a single principle: **one incident of unexpected task title exposure will destroy user trust irrecoverably.** All tasks are private by default.

**Per-task privacy toggle:** "Share with pod" — off by default on every task. When off:

- Pod members see the user counted in the daily completion percentage
- Pod members cannot see the task title, notes, or unit-level progress
- Pod members see the task counted as "1 private task"

When on:

- Pod members see the task title, current progress (for quantified tasks), and status
- Notes are never shared regardless of the toggle

**What pod members always see (no opt-in required):**

- Member's overall daily completion percentage ("Alex: 4 of 7 tasks done")
- Whether the member hit their bedtime (met it / missed it)
- Count of that member's pending tasks at any given time

**What pod members never see without the toggle:**

- Task titles of private tasks
- Task notes or descriptions
- Snooze history or reasons
- The user's configured bedtime (to prevent members from calculating when reminders will fire)

**Task deletion:** If a pod-visible task is deleted, it disappears from the pod view silently. No "deleted" state is shown to pod members. Members are not notified of deletions.

### 11.4 Pod Member View

A dedicated "Pod" tab (or section within the home screen) shows:

- Each pod member's avatar / name
- Today's completion percentage per member (updates in near-real-time when the app is foregrounded)
- Shared tasks per member with their current status and progress
- End-of-day indicator: green check if they finished before bedtime, red indicator if they missed it
- Reaction capability: thumbs-up only in v1. No free-text comments (comments become a chat, which is out of scope).

**Refresh behaviour:** Pod data is fetched on app foreground and on manual pull-to-refresh. No persistent WebSocket in v1 — polling is sufficient given the accountability loop operates on a daily cadence.

### 11.5 Pod Notification Triggers

See Section 4.4 for the full notification trigger table. Summary:

- **Bedtime missed:** 15 minutes after a member's bedtime passes with unresolved tasks. Sent to all other members. Private task titles not revealed in the payload.
- **Streak broken (7+ days):** Sent to all other members. Enables a reaction.
- **Quantified task falling behind:** Shared quantified task below 50% at T−1h. Sent once per task per day.
- **Completion (notable):** Only when prior 7-day completion rate was below 60% — prevents celebration notifications from becoming noise for consistently high-performing members.

**Cap:** 2 social notifications per recipient per 24-hour period. Batched if multiple members trigger simultaneously.

### 11.6 Edge Cases


| Scenario                              | Behaviour                                                                                                                                                                                                                                                                                              |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| User has no pod                       | Pod tab shows an invite prompt. No social notifications are sent or received.                                                                                                                                                                                                                          |
| Pod member changes their bedtime      | Notification triggers recalculate immediately against the new time. Other pod members are not informed of the bedtime change.                                                                                                                                                                          |
| Pod member is in a different timezone | Notification Service is fully timezone-aware. A member in Tokyo triggers a bedtime-missed notification to London-based members at the Tokyo bedtime, which may be London's daytime. No suppression — accountability is real-time.                                                                      |
| Pod member mutes another member       | The muting member stops receiving notifications from the muted member. The muted member is not informed. The muting persists until manually reversed.                                                                                                                                                  |
| User deletes their account            | User is removed from their pod. Pod continues if ≥2 members remain; dissolves otherwise.                                                                                                                                                                                                               |
| Offline member                        | If a member's device was offline and tasks were completed before bedtime, the sync on reconnect retroactively marks the day as completed. Pod members receive a correction notification only if a "missed" notification was already sent: "Alex actually finished on time — their device was offline." |


---

## SECTION 12 — QUANTIFIED / PARTIAL COMPLETION TASKS

### 12.1 Overview

Binary task completion is easy to game. A user can mark "Exercise for 30 minutes" as done after five minutes with zero friction. Quantified tasks make honesty structural: the user sets a numeric target and logs their actual result. The app displays honest progress, not a manufactured binary.

This feature is motivated by two needs simultaneously:

1. **Individual accuracy:** Users want to track genuine effort, not fake it to themselves.
2. **Social honesty:** When tasks are shared with a pod, the group sees "Alex: Run 5km — 3/5km (60%)" instead of a misleading green check.

### 12.2 Task Model Extensions

See Section 4.1 for the full updated task model. Key fields:

- `is_quantified` — must be explicitly set at task creation. Cannot be toggled after the first progress log entry for that task instance (changing the nature of a task mid-measurement is confusing).
- `target_value` — must be greater than 0. Float, one decimal place of precision in the UI (stored at full float precision).
- `target_unit` — display label only. Free text, max 12 characters. Not validated or normalised (users can write "km", "KM", "kilometers" — this is a display concern, not a data concern).
- `progress_value` — cumulative, not incremental. Always represents the total as of the last log entry.
- `progress_log` — append-only history. Never mutated after writing. Enables the pod activity feed in a future version and provides an audit trail for the user's own analytics.

**Target change rule:** If a user changes the target after progress has been logged, the 80% threshold recalculates against the new target. Progress log entries are preserved unchanged. Target changes are recorded with a timestamp in a separate `target_history` field (JSON array) for audit purposes. This prevents hidden retroactive success inflation — the change is always traceable.

### 12.3 Completion UX

**Tapping "Mark Done" on a quantified task** opens a bottom sheet:

```
[Task title]
Goal: 5 km

[ 5.0 ] km          ← numeric input, pre-filled with target, keyboard auto-focused

[  Log Progress  ]  [  Cancel  ]
```

If progress has already been logged today, the input is pre-filled with the current `progress_value`, and a secondary label shows: "Currently logged: 3.0 of 5.0 km."

**Value rules:**

- Value must be ≥ 0 (entering 0 triggers a confirmation: "Remove all logged progress?")
- Value may exceed the target — accepted without friction, status becomes `done`
- Value is cumulative (always the total, not an addition to prior progress)
- Decimal input: one decimal place accepted in the UI; rounds at two decimal places

**Resulting status:**

- `progress_value >= target_value`: status → `done`
- `progress_value >= 0.8 × target_value` (and < target): status remains `pending` visually marked as "on track" — treated as resolved for metrics purposes (see 12.4)
- `progress_value < 0.8 × target_value`: status remains `pending`, treated as unresolved

**Visual states on the task card:**


| Progress | Visual treatment                                                    |
| -------- | ------------------------------------------------------------------- |
| 0%       | Standard pending state, no progress bar                             |
| 1–79%    | Amber progress bar with "X / Y unit" label                          |
| 80–99%   | Green progress bar with "X / Y unit" — checkmark appears (resolved) |
| 100%+    | Full green with "X / Y unit (done)"                                 |


### 12.4 Streaks and Metrics

**The 80% rule is the product's single definition of "done enough"** — applied consistently everywhere:


| Context                      | Rule                                                                                                                             |
| ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Daily resolution rate        | Quantified task counts as resolved if `progress_value >= 0.8 × target_value`                                                     |
| Streak maintenance           | All tasks for the day must be resolved (80% rule applies). One task at 70% breaks the streak even if all others are complete.    |
| Pod accountability           | Pod members see the progress bar. The "missed bedtime" notification fires if any task remains below 80% at the member's bedtime. |
| End-of-Day Resolution Screen | Quantified tasks below 80% appear in the resolution screen like any unresolved task.                                             |


**Why 80% and not 100%:** Requiring 100% is punitive for effort-based tasks. A user who runs 4.9km against a 5km goal has done the work. Any-progress-counts invites gaming (log 0.1km and mark done). 80% is the minimum credible effort threshold. This value is hardcoded in v1 — not user-configurable, because configurability here directly enables gaming.

### 12.5 Interaction with Daily Tasks

`daily` task instances of a quantified task reset to `progress_value = 0` each day. Historical `progress_log` entries are preserved for analytics but do not carry forward to the new day's instance. Each day starts from zero.

**Skip today on a quantified daily task:** Functions identically to binary daily tasks — marks the instance as skipped (excused) without requiring a progress entry.

### 12.6 Interaction with Pods

When `pod_visible` is true on a quantified task:

- Pod members see the progress bar and label in real-time (on app foreground / pull-to-refresh)
- The "quantified task falling behind" pod notification fires when `progress_value < 0.5 × target_value` at T−1h (note: 50% pacing trigger, not 80% completion threshold — these are different thresholds for different purposes)
- Pod members cannot log progress on another member's task — they are read-only

**Interaction design rationale:** Pod visibility on quantified tasks shifts accountability from outcome-based ("did you or didn't you") to effort-visible ("you're at 60% with 2 hours left"). This is the most valuable form of social accountability for physical or effort-based goals, and it is only possible because progress is honest and timestamped.

### 12.7 Edge Cases


| Scenario                                                     | Behaviour                                                                                                                                                                                                                          |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| User changes target mid-day after progress logged            | New target applies immediately. 80% threshold recalculates. Change recorded in `target_history`.                                                                                                                                   |
| User exceeds target                                          | Fully valid. `progress_value` stored above target. Status → `done`. No cap enforced.                                                                                                                                               |
| `is_quantified` toggled after task creation                  | Not permitted after the first progress log entry. The field is locked at that point. Before any progress is logged, toggling is allowed with a confirmation warning that any set target/unit will be cleared.                      |
| Quantified task shared to pod, then `pod_visible` turned off | Pod members immediately lose visibility of that task. No notification to pod members. The task is counted in the completion percentage but not shown by name.                                                                      |
| `target_unit` left blank                                     | Permitted. The display shows the number only: "3 / 5" without a unit label.                                                                                                                                                        |
| `progress_log` and offline sync (Phase 3+)                   | Progress log entries include device-generated timestamps. On sync, the server merges entries by timestamp — no entry is discarded. If the same logical update arrives twice (retry), deduplication is by `{task_id, recorded_at}`. |


---

## SECTION 10 — NON-GOALS (v1 and v2)

These are explicitly out of scope and should not influence early architecture decisions:

- AI-generated task suggestions
- Integration with calendars (Google Calendar, Apple Calendar)
- Time-blocking or time estimation per task
- Sub-tasks / checklists within a task (quantified tasks address this need in v2)
- Public pods, pod discovery, or any strangers-visible social feed
- Free-text comments or chat within pods (reactions only in v1)
- Gamification beyond streaks and pod accountability

---

*Document owner: Product. Review cycle: before each phase kickoff. Last updated: 2026-04-04.*