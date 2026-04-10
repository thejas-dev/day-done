/// Determines the "logical date" whose bedtime has passed, meaning
/// that date's tasks need end-of-day resolution.
///
/// Returns the date whose tasks need resolution, or `null` if bedtime
/// hasn't passed yet (user is still in their active day).
///
/// Bedtime range: 6 PM – 3 AM.
///
/// Rules:
/// - Bedtime ≥ 18:00 (pre-midnight, e.g. 11 PM):
///   - After midnight until 6 AM → logical date = yesterday
///   - Between bedtime and midnight → logical date = today
///   - Before bedtime (6 AM – bedtime) → null (still active)
/// - Bedtime < 6:00 (post-midnight, e.g. 1 AM):
///   - After bedtime until 6 AM → logical date = yesterday
///   - Before bedtime same morning → null (still in yesterday's day)
///   - After 6 AM → null (new active day, bedtime hasn't come yet)
DateTime? resolveLogicalDate(
  DateTime now,
  int bedtimeHour,
  int bedtimeMinute,
) {
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  if (bedtimeHour >= 6) {
    // Pre-midnight bedtime (e.g. 11 PM)
    final bedtimeToday = DateTime(
      today.year,
      today.month,
      today.day,
      bedtimeHour,
      bedtimeMinute,
    );

    if (now.hour < 6) {
      // Between midnight and 6 AM — yesterday's bedtime has passed.
      return yesterday;
    } else if (now.isAfter(bedtimeToday)) {
      // Past bedtime today, before midnight.
      return today;
    } else {
      // Before bedtime today — still active day.
      return null;
    }
  } else {
    // Post-midnight bedtime (e.g. 1 AM)
    // This bedtime belongs to the previous calendar day's logical day.
    final bedtimeThisMorning = DateTime(
      today.year,
      today.month,
      today.day,
      bedtimeHour,
      bedtimeMinute,
    );

    if (now.hour < 6) {
      if (now.isBefore(bedtimeThisMorning)) {
        // Before bedtime this morning (e.g. 12:30 AM, bedtime 1 AM).
        // Still in yesterday's active day.
        return null;
      } else {
        // Past bedtime this morning, before 6 AM.
        // Yesterday's logical day is done.
        return yesterday;
      }
    } else {
      // 6 AM or later — new active day. Bedtime hasn't come yet.
      return null;
    }
  }
}
