/// What the scanner concluded about one notification.
enum NotificationStatus {
  /// Matched the predatory-lending patterns. The original is dismissed and
  /// PIKIR posts its own notification in its place, always carrying an action
  /// that reveals the original text.
  mencurigakan('Mencurigakan'),

  /// A due date was recognised. Recorded for the user's awareness only; the
  /// notification itself is left completely alone.
  tagihan('Tagihan'),

  /// Nothing matched. Left untouched, with no PIKIR marking at all.
  aman('Aman');

  const NotificationStatus(this.label);

  final String label;

  static NotificationStatus fromName(String name) => values.firstWhere(
    (status) => status.name == name,
    orElse: () => NotificationStatus.aman,
  );
}

/// One line in the scan log.
///
/// Deliberately small. The log exists so the user can see what PIKIR has been
/// doing on their behalf, which means it stores a short excerpt rather than
/// the full notification: enough to recognise the message, not enough to
/// become a copy of the user's inbox.
class NotificationLog {
  const NotificationLog({
    required this.id,
    required this.time,
    required this.sourceApp,
    required this.snippet,
    required this.status,
    this.reason,
  });

  /// How much of the original text is kept.
  static const snippetLimit = 120;

  final String id;

  final DateTime time;

  /// The app the notification came from, as shown to the user: "DanaKilat".
  final String sourceApp;

  /// A trimmed excerpt of the notification text.
  final String snippet;

  final NotificationStatus status;

  /// Why it was flagged, in plain language. Null for anything not flagged.
  ///
  /// A warning without a reason is just an alarm. This is the line that lets
  /// the user learn the pattern instead of depending on the app to spot it
  /// next time.
  final String? reason;

  /// Trims [text] to [snippetLimit], collapsing whitespace.
  static String makeSnippet(String text) {
    final collapsed = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (collapsed.length <= snippetLimit) return collapsed;
    return '${collapsed.substring(0, snippetLimit - 1)}…';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'time': time.toIso8601String(),
    'sourceApp': sourceApp,
    'snippet': snippet,
    'status': status.name,
    'reason': reason,
  };

  /// Rebuilds from stored JSON.
  ///
  /// Tolerant on purpose: a log line that cannot be parsed is not worth
  /// crashing the scanner history over, so missing fields fall back rather
  /// than throw. The caller drops entries that fail outright.
  factory NotificationLog.fromJson(Map<String, dynamic> json) {
    return NotificationLog(
      id: json['id'] as String? ?? '',
      time:
          DateTime.tryParse(json['time'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      sourceApp: json['sourceApp'] as String? ?? 'Aplikasi',
      snippet: json['snippet'] as String? ?? '',
      status: NotificationStatus.fromName(json['status'] as String? ?? 'aman'),
      reason: json['reason'] as String?,
    );
  }
}

/// A due date PIKIR noticed in an incoming notification.
///
/// Awareness only. PIKIR reads notifications as they arrive; it cannot see
/// bills inside other apps, and the UI says so rather than implying the list
/// is complete.
class DetectedBill {
  const DetectedBill({
    required this.id,
    required this.sourceApp,
    required this.amount,
    required this.dueDate,
  });

  final String id;
  final String sourceApp;
  final int amount;
  final DateTime dueDate;

  int daysUntilDue(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }
}
