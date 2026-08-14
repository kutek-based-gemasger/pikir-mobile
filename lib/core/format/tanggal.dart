/// Date formatting in Bahasa Indonesia.
///
/// Written by hand rather than pulled from `intl`, which would add a
/// dependency and a locale-data load for what amounts to a list of twelve
/// abbreviations.
library;

const _shortMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

const _longMonths = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// `12 Agu`.
String formatShortDate(DateTime date) =>
    '${date.day} ${_shortMonths[date.month - 1]}';

/// `Agustus 2026`, for a list's date header.
String formatMonthYear(DateTime date) =>
    '${_longMonths[date.month - 1]} ${date.year}';

/// `21:40`, zero-padded so times line up in a column.
String formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';

/// `12 Agu 21:40`.
String formatDateTime(DateTime date) =>
    '${formatShortDate(date)} ${formatTime(date)}';

/// A due date in the words someone would actually use.
///
/// Relative phrasing beats a bare date for something the user has to act on,
/// and this is a factual statement of when money is owed, not a manufactured
/// deadline: the sentence stays neutral and never urges.
String formatDueLabel(DateTime dueDate, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final days = due.difference(today).inDays;

  return switch (days) {
    < 0 => 'Lewat ${-days} hari',
    0 => 'Jatuh tempo hari ini',
    1 => 'Jatuh tempo besok',
    _ => 'Jatuh tempo $days hari lagi',
  };
}

/// `19 jam`, for the calm line about when chat history is deleted.
String formatRemaining(Duration duration) {
  if (duration.inHours >= 1) return '${duration.inHours} jam';
  if (duration.inMinutes >= 1) return '${duration.inMinutes} menit';
  return 'kurang dari semenit';
}
