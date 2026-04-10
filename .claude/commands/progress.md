---
description: Show DayDone development progress. Lists completed weeks, current week status, and what's next.
allowed-tools: Read, Bash
---

Read `.claude/progress.md` to get the current phase progress.

Also run:
```bash
git log --oneline -20
```
to see recent commits.

Then output a summary:

```
DayDone Development Progress
=============================
Phase 1 — MVP (Weeks 1–6)
  Week 1 — Project Setup & Schema:     [COMPLETE / IN PROGRESS / NOT STARTED]
  Week 2 — Task CRUD:                  [COMPLETE / IN PROGRESS / NOT STARTED]
  Week 3 — Today View:                 [COMPLETE / IN PROGRESS / NOT STARTED]
  Week 4 — Calendar + Backlog:         [COMPLETE / IN PROGRESS / NOT STARTED]
  Week 5 — Reports Screen:             [COMPLETE / IN PROGRESS / NOT STARTED]
  Week 6 — Notifications + Resolution: [COMPLETE / IN PROGRESS / NOT STARTED]

Phase 2 — Hardening (Weeks 7–10): NOT STARTED
Phase 3 — Scale (Weeks 11–18):    NOT STARTED

Current: <week currently in progress>
Next up: <next week's first deliverable>
```

If `.claude/progress.md` doesn't exist yet, create it with all weeks set to NOT STARTED.
