---
description: Start a DayDone development week. Usage: /week 1, /week 2, etc. Reads CLAUDE.md, plans the week's deliverables, and begins implementation in dependency order.
---

Read CLAUDE.md completely before doing anything else.

The user wants to execute Phase 1, Week $ARGUMENTS of DayDone development.

Use the phase-runner agent to:
1. Load the Week $ARGUMENTS deliverables from your instructions
2. Output a numbered plan with dependencies clearly identified
3. Ask "Ready to execute? (yes/no)" before writing any code
4. On confirmation, implement each deliverable in order — one at a time
5. Run `dart run build_runner build --delete-conflicting-outputs` after any schema or annotation change
6. After all deliverables are complete, invoke the flutter-reviewer agent to validate the session's output
7. Update `.claude/progress.md` with the week's completion status

Do not skip the planning step. Do not implement multiple deliverables simultaneously.
