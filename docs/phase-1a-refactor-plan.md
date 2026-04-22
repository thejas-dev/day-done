# Phase 1A — UI Refactor to DayDone Design System

> **Status:** Pass 1–9 shipped (2026-04-22).
> **Goal:** Bring every Phase 1 screen into conformance with the DayDone UI System
> handoff (`docs/design/DayDone UI System.html` + the source bundle previously
> extracted to `/tmp/daydone_design/day-done/project/`).
>
> **Source design files (canonical):**
> - `screens-today.jsx` — Today header, filter bar, normal/urgent/empty/first-time
> - `screens-sheets.jsx` — TaskCreateSheet, SheetSnooze, SheetContext, SheetProgress, SheetEndOfDay
> - `screens-onboarding.jsx` — 4-step flow with TimeWheel
> - `primitives.jsx` — Phone, BottomNav, TaskTile, Chip, ProgressBar, SectionHeader, Toggle, PrimaryButton, TextLink, Placeholder, Dots
> - `tokens.jsx` — LIGHT/DARK colour tokens, TYPE typography, SHAPE radii, ELEV shadows
> - `styles.css` — full CSS reference

---

## Decisions locked in (2026-04-22)

1. **Bottom nav** — move to a **5-tab layout**: Today, Calendar, Backlog, Reports, Settings. Tabs whose screens aren't built yet (Reports — Phase 2) are rendered but **non-clickable** (visually muted, no tap handler). Settings is already built, so it gets a real route.
2. **Quantified-task card** on the create/edit sheet — **deferred to Phase 2** (per `CLAUDE.md` scope).
3. **"Day N in a row" streak pill** on celebration screen — **deferred to Phase 2**.

---

## Already aligned (carry-over from prior session)

- **Theme tokens**: `lib/core/theme/app_colors.dart`, `app_typography.dart`, `app_theme.dart` are synced with `tokens.jsx` (LIGHT/DARK, priority palette `pUrgent/pHigh/pMedium/pLow`, semantic tints `errorTint/warningTint/successTint`, surfaceRaised, dividers).
- **Today header**: `lib/features/tasks/presentation/widgets/today_header.dart` matches `screens-today.jsx:3` `TodayHeader` (date + greeting / countdown chip / pending pill / "X of Y done" / progress bar).
- **Today screen empty state, first-time empty, urgent banner, all-done celebration**: in `lib/features/tasks/presentation/screens/today_screen.dart`.

---

## Pass 1 — Core primitives _(blocks all later passes — ship first)_ ✅ shipped 2026-04-22

Build a `lib/core/widgets/` primitives layer mirroring `primitives.jsx`. Stops every screen from re-implementing chips, progress bars, etc.

### 1.1 TaskTile rewrite — `lib/features/tasks/presentation/widgets/task_tile.dart`
Biggest visible gap. Reference: `primitives.jsx:170` `TaskTile`.

- [x] Drop the `Border.all` outline — design tile uses **shadow + radius only** in default state.
- [x] Convert priority strip to a **4px absolute-positioned stripe on the leading edge** (currently rendered as a Row child via `IntrinsicHeight`).
- [x] **Add "From yesterday" overdue pill** (errorTint bg, error text, 10px, before title) — currently missing.
- [x] Replace urgent gradient with **flat `urgentTileTint` background** + `pUrgent22` border (per `screens-today.jsx:108` `urgentTint` prop).
- [x] Inline action icons: snooze icon **only when not strike/snoozed**; more_vert always. (Currently shows schedule for every pending tile.)
- [x] Label chip styling: bg `labelChipBg`, **radius 4**, padding 2×8 (currently radius 6, padding 2×6).
- [x] Snoozed state: italic title + 0.75 opacity (already done — verify).
- [x] Quantified inline progress block: **omit (Phase 2)**.

### 1.2 ChipDS
- [x] New file `lib/core/widgets/chip_ds.dart`. Reusable `ChipDS(active: bool, colors: ChipDSColors?, icon: Widget?, trailing: Widget?, onTap: VoidCallback?)` matching `primitives.jsx:131`. Replaces hand-rolled chips in filter bar, priority picker, label input.

### 1.3 ProgressBarDS
- [x] New file `lib/core/widgets/progress_bar.dart`. Params: `pct`, `color?`, `trackColor?`, `height = 4`, `glow = false`. (Existing `_DailyProgressBar` in `today_header.dart` will be swapped to this in a follow-up — the primitive is in place and ready.)

### 1.4 SectionHeaderDS
- [x] New file `lib/core/widgets/section_header.dart`. Uppercase, `letterSpacing: 0.6`, padding `14px 20px 8px`, optional right-side widget (counter pill). Per `primitives.jsx:277`.

### 1.5 PrimaryButtonDS / TextLinkDS / ToggleDS
- [x] `PrimaryButtonDS({label, onPressed, full, danger, icon})` — 48px, radius 24, primary teal, `0 2px 6px rgba(0,121,107,0.18)` shadow in light. File: `lib/core/widgets/primary_button.dart`.
- [x] `TextLinkDS({label, onTap, color})` — `titleMedium` w500. File: `lib/core/widgets/text_link.dart`.
- [x] `ToggleDS({value, onChanged})` — 40×24 pill with sliding white knob. File: `lib/core/widgets/toggle.dart`.

---

## Pass 2 — Today screen polish ✅ shipped 2026-04-22

Reuse Pass 1 primitives. File: `lib/features/tasks/presentation/screens/today_screen.dart`.

- [x] Replace inline section labels in `_buildTaskSections` with `SectionHeaderDS` (e.g., `"Pending · 4"` → rendered as uppercase per `SectionHeaderDS`).
- [x] Verify tile spacing matches the 10px gap from `screens-today.jsx:61` — **`task_tile.dart` uses `vertical: 5`** on tile margin (10px between row centres); no `AppSpacing.xs` on tiles.
- [x] Filter chip bar (`lib/features/tasks/presentation/widgets/filter_chip_bar.dart`) → use `ChipDS`.

---

## Pass 3 — Bottom nav, FAB, 5-tab layout ✅ shipped 2026-04-22

Files: `lib/core/widgets/daydone_bottom_nav.dart`, `lib/routing/app_router.dart` (`MainShell`), `lib/features/tasks/presentation/screens/reports_placeholder_screen.dart`.

- [x] Expand from 3 tabs → **5 tabs**: Today, Calendar, Backlog, Reports, Settings (chart + settings icons; `primitives.jsx:58`).
- [x] **Reports tab is non-clickable** (Phase 2): **0.4 opacity**, `IgnorePointer`; no `goBranch` from tap. _(Shell branch `/reports` + `ReportsPlaceholderScreen` exists only for indexed-stack state / deep links; users cannot open it from the tab.)_
- [x] **Settings tab** → shell route to `SettingsScreen`; **gear removed** from `TodayHeader` (`onSettings: null`).
- [x] **Centered FAB** — **56×56**, `AppTheme.fabShadowLight` / `fabShadowDark`, **28px** above the 68px bar; evening error **glow** preserved when **Today** is selected and within 45min of bedtime.
- [x] **56px-wide spacer** between **Calendar and Backlog** (`[Today][Calendar][56px][Backlog][Reports][Settings]`). *(The old “slot 3” note referred to JSX index in the deck; layout uses the FAB gap between Calendar and Backlog.)*
- [x] **FAB owned by `MainShell`** (`_ShellCreateTaskFab`) — removed from `TodayScreen`; Calendar/Backlog never had FABs.
- [x] **`StatefulShellRoute`**: five branches (today, calendar, backlog, reports placeholder, settings); removed duplicate root `/settings` overlay route.

---

## Pass 4 — Task Create / Edit sheet rewrite _(largest single task)_ ✅ shipped 2026-04-22

Files: `task_create_screen.dart`, `task_edit_screen.dart`; shared **`task_sheet_scaffold.dart`**, **`task_form_body.dart`**.
Reference: `screens-sheets.jsx:22` `TaskCreateSheet`.

- [x] Custom **52px header bar**: `[X close] · New Task / Edit Task · [Save]` (`TaskSheetScaffold`). Save = primary teal **w600**; **Divider** hairline below.
- [x] **Big underlined title**: **22px** semibold; **primary** underline (stronger when focused); **`n / 200`** counter top-right (`labelSmall`, disabled colour).
- [x] **Segmented type** (create only): track `#F0F1F3` / `#262626`; active segment **surface** + **`AppTheme.tileShadow`**. **🔁 Daily** / **📅 One-time**. Edit **hides** type (immutable).
- [x] **`PriorityPicker`** → **`ChipDS`** wrap with **`ChipDSColors`** when a concrete priority is selected (`priority_picker.dart`).
- [x] **Labels**: row **Labels (optional)** + **`count / 5`**; chips **`ChipDS`** + inline **×** (`label_chips_input.dart`); **`+ Add label`** borderless field.
- [x] **Collapsible notes** — collapsed by default; chevron rotates; expanded shows multiline field (`_NotesCollapsible` in `task_form_body.dart`).
- [x] **Quantified card** — Phase 2 only; comment + minimal spacer in form (no UI).
- [x] **Pod share** — Phase 3; no UI.
- [x] **Bottom**: **`PrimaryButtonDS('Save Task')`**; edit adds **`TextLinkDS('Delete Task')`** + confirm dialog.
- [x] **Sheet affordance**: scrim + **rounded top** (`AppRadius.sheetTop`) + **`CustomTransitionPage`** slide-up on **`/tasks/create`** & **`/tasks/edit/:id`** — same routes, modal presentation (not raw `showModalBottomSheet`, equivalent UX).

---

## Pass 5 — Action sheets ✅ shipped 2026-04-22

Aligned to `docs/design/styles.css` (`.bsheet`, `.drag-handle`, `.opt-row`, `.bsheet-title`) and `docs/design/build-slides.js` (`sheetA_Snooze`, `sheetB_Context`).

### 5.1 Long-press / overflow menu
File: `lib/features/tasks/presentation/widgets/task_action_sheet.dart`.
Reference: `screens-sheets.jsx:176` `SheetContext`.

- [x] **36×4 drag handle** at top (`opacity: 0.5` per CSS; spacing `8 + 4 + handle + 12` per `.bsheet`/handle margins).
- [x] Header block: `TASK` caption (11px uppercase, secondary) + task title (15px semibold).
- [x] Hairline divider.
- [x] Rows: `[Icon][Label]` — `.opt-row` padding 12×20, 22px icon, 14px gap (see `_OptRow`).
  - Mark Done — success tint on icon + label
  - Log Progress — **omitted** (Phase 2 quantified); deck shows it conditionally.
  - Snooze / Change snooze → **`showSnoozePickerSheet`** (secondary icons on rows)
  - Reschedule — **dated one-time tasks only**
  - Skip Today
  - Close (won’t do) — **extra** vs static deck (preserves prior app behaviour; destructive tint)
  - Edit — `go_router` push to edit route
- [x] Divider with **4px vertical margin** before destructive block.
- [x] Delete row — `.opt-row.destructive` (error icon + label); hidden for daily instances.

### 5.2 Snooze picker (own sheet)
Files: `lib/features/tasks/presentation/widgets/snooze_picker_sheet.dart`.
Reference: `screens-sheets.jsx:141` `SheetSnooze`.

- [x] Title **`Snooze until…`** (`bsheet-title`: 16px w700, padding `4 20 12`).
- [x] Rows: 30 minutes, 1 hour, 2 hours, Custom time… with **resolved clock time** on the right (11px secondary), matching slide markup (not “Until …” prefix).
- [ ] **Selected row** styling (primaryContainer / dark `#1E3B3A` + check) — **not in static slide**; rows **apply snooze on tap** (instant confirm).
- [x] Bottom **Cancel** — 13px w600 secondary (`padding: 14px 20px 4px`, centered).

---

## Pass 6 — Resolution screen rewrite ✅ shipped 2026-04-22

File: `lib/features/resolution/presentation/resolution_screen.dart`.
Reference: `build-slides.js` `sheetD_EndOfDay`, `styles.css` `.eod-row` / `.eod-actions` / `.eod-btn`.

Full-screen **`surfaceRaised`** layout (no `AppBar`). Per-card layout matches `.eod-row` (inner **`surface`** card, **12×14** padding, **12** radius, **4px** priority strip + **1px** hairline border).

- [x] Title **"Before you sleep 💤"** — **26px** / w700 / −0.02em (slide markup; token `displayLarge` overridden).
- [x] Sub-line — **13px** secondary, **6px** below title.
- [x] Progress row — **16px** below copy: **`ProgressBarDS`** (h **4**, track divider, fill **primary**) + **`10px`** gap + **`X of Y resolved`** in an **11px** w700 pill (`#F0F1F3` / `#262626` chip bg).
- [x] Per-task tile — **16** horizontal margin, **10** bottom gap; title **14px** w600 (**urgent** → w700); quantified sub-line **Phase 2**.
- [x] **3 actions** — `.eod-actions` **6px** gap; `.eod-btn` (**12px** font w600, **8×4** padding, **`AppRadius.sm`** = **8px** per `styles.css`). Default state: divider border, secondary icon + label (tap commits immediately — deck “selected” styling is illustrative).
- [x] Bottom **`PrimaryButtonDS('All done (resolved / total)')`** — padding **`12 16 20`**; **`onPressed`** only when every task has been acted on (`remaining.isEmpty`). User exits via CTA (**no** auto-`go` when the list empties).
- [x] **`PopScope(canPop: false)`** retained.

---

## Pass 7 — Onboarding 4-step flow ✅ shipped 2026-04-22

File: `lib/features/onboarding/presentation/onboarding_screen.dart`.
Reference: `screens-onboarding.jsx`, `build-slides.js` `onboardStep1..4`, and `styles.css` `.onboard` / `.time-wheel` / `.step-dots`.

- [x] **Dots pagination** at bottom: 4 dots, active 20×6 pill and inactive 6×6 circles.
- [x] **Step 1 — bedtime**: headline + sub-line + DayDone TimeWheel with range caption (`6:00 PM — 3:00 AM · 15-min steps`), wired to `updateBedtime`.
- [x] **Step 2 — morning check-in**: same wheel treatment, default 8:00 AM, wired to `updateMorningCheckin`; includes `Skip for now` ghost link.
- [x] **Step 3 — first task**: functional first-task card (editable title, type toggle, priority pills, optional label) wired to task creation from onboarding.
- [x] **Step 4 — notification permission**: primary-container bell circle + error dot badge, 3-paragraph copy, `Allow Notifications` + `Not now` actions.
- [x] All steps: `PrimaryButtonDS` primary CTA + `TextLinkDS` secondary action placement.

---

## Pass 8 — Calendar / Backlog / Settings conformance ✅ shipped 2026-04-22

Not in the design deck, but should reuse new primitives so they don't drift.

- [x] `lib/features/tasks/presentation/screens/calendar_screen.dart` — swap to new `TaskTile` + `SectionHeaderDS`.
- [x] `lib/features/tasks/presentation/screens/backlog_screen.dart` — same.
- [x] `lib/features/settings/presentation/settings_screen.dart` — apply typography + spacing tokens; no structural change.

---

## Pass 9 — Visual QA ✅ shipped 2026-04-22

- [x] Sweep light + dark on a 360×800 Pixel emulator.
- [x] Compare each screen to its `screenshots/` reference (overview.jpg + the 8 audit shots in the handoff bundle).
- [x] Run `flutter analyze` after each pass — must end clean (only the pre-existing `workmanager_service.dart` warning is acceptable).
- [x] Spot-check: tap targets ≥ 44×44, contrast ratios on muted text in dark mode.

---

## Suggested execution order

1. **Pass 1 → 2 → 3** — **complete (2026-04-22)** — Today + nav + primitives foundation.
2. **Pass 4** (task create/edit sheet) — **complete (2026-04-22)**.
3. **Pass 5** (action sheets) — small, slots in next.
4. **Pass 6** (resolution) — rewrite using primitives.
5. **Pass 7** (onboarding) — TimeWheel is custom work, isolate.
6. **Pass 8** (cleanup) — quick conformance.
7. **Pass 9** (QA) — final.

---

## Out of scope for Phase 1A

(Recorded here so we don't drift.)

- Quantified-task UI (progress bar inside tile, log-progress sheet, quantified card on create sheet) → **Phase 2**.
- Streak pill on celebration → **Phase 2**.
- **Reports** — real metrics / navigation / interactive tab → **Phase 2** (Phase 1A ships a **disabled tab** + placeholder shell branch only).
- Pod sharing toggle on create sheet → **Phase 3**.
- Animations / micro-interactions beyond what Flutter gives us by default → polish pass after Phase 1A lands.
