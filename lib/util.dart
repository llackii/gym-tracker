const weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String fmtNum(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

String monthShort(DateTime d) => _months[d.month - 1];

String shortDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

String dayDate(DateTime d) =>
    '${weekdayNames[d.weekday - 1].substring(0, 3)}, ${shortDate(d)}';

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime startOfWeek(DateTime d) =>
    DateTime(d.year, d.month, d.day - (d.weekday - 1));

String _two(int n) => n.toString().padLeft(2, '0');

/// 05:32 or 1:05:32
String fmtClock(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  return h > 0 ? '$h:${_two(m)}:${_two(s)}' : '${_two(m)}:${_two(s)}';
}

/// 52 min or 1 h 05 min
String fmtMinutes(int seconds) {
  final m = (seconds / 60).round();
  if (m < 60) return '$m min';
  return '${m ~/ 60} h ${_two(m % 60)} min';
}
