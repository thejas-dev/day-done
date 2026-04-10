---
name: Spec v1.3 architecture additions
description: Priority, labels, and reports screen were added to architecture.md as part of spec v1.3 update on 2026-04-04
type: project
---

Spec v1.3 introduced two new features that were integrated into the architecture doc:
1. **Task Priority & Labels** — priority (intEnum, 5 levels) and labels (JSON array on task row, denormalized) added to tasks_table and daily_instances_table. Schema version bumped from 3 to 4.
2. **Reports/Progress Screen** — new `features/reports/` module with ReportsDao for aggregate queries, `/reports` as Tab 3 in ShellRoute, fl_chart for bar chart/sparkline rendering.

**Why:** Product expansion to give users lightweight task organization (priority/labels) and a read-only analytics view.

**How to apply:** Priority and labels are Phase 1 features. The reports screen includes a dedicated ReportsDao separate from TaskDao to keep analytics queries out of action/mutation code. Labels use denormalized JSON storage (not a junction table) for Phase 1 simplicity.
