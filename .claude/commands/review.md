---
description: Review DayDone Flutter code for architectural violations. Usage: /review (reviews all changed files) or /review lib/features/tasks (reviews a specific path).
---

Invoke the flutter-reviewer agent to audit the code at: $ARGUMENTS

If no path is given, default to reviewing all files changed since the last git commit:
```bash
git diff --name-only HEAD
```

The reviewer will check for:
- Direct Drift table access bypassing DAOs
- Hardcoded 0.8 completion threshold
- setState or Navigator.push usage
- Missing Riverpod code-gen annotations
- Labels stored in a separate table
- Daily task template status mutations
- Progress log mutations
- Phase boundary violations
- Missing .g.dart generated files

Output a clean violation report. If violations are found, fix them immediately after reporting.
