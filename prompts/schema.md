---
description: Validate the DayDone Drift schema and run build_runner. Checks all table definitions, enum mappings, indices, and schemaVersion before building.
---

Invoke the schema-guardian agent to:

1. Read and validate all files in `lib/core/database/tables/`
2. Validate `lib/core/database/app_database.dart` (schemaVersion, MigrationStrategy)
3. Check all enum definitions in `lib/features/task/domain/`
4. Confirm all required indices are declared
5. Run `dart run build_runner build --delete-conflicting-outputs`
6. Report results

If any validation fails, list what needs to be fixed and DO NOT run build_runner until the schema issues are resolved.
