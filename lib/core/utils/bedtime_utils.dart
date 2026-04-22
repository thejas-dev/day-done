/// Next wall-clock occurrence of the user's bedtime (hour + minute only).
///
/// Used for "time to bedtime" countdown on Today. Walks forward from
/// [now] across calendar days until a candidate is strictly after [now].
DateTime? nextBedtimeOccurrence(DateTime now, DateTime bedtimeTemplate) {
  final bh = bedtimeTemplate.hour;
  final bm = bedtimeTemplate.minute;
  final day0 = DateTime(now.year, now.month, now.day);

  for (var i = 0; i < 8; i++) {
    final d = day0.add(Duration(days: i));
    final candidate = DateTime(d.year, d.month, d.day, bh, bm);
    if (candidate.isAfter(now)) {
      return candidate;
    }
  }
  return null;
}

String formatDurationCompact(Duration d) {
  if (d.isNegative) return '0m';
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  if (hours >= 1) {
    return '${hours}h ${minutes}m';
  }
  return '${minutes}m';
}
