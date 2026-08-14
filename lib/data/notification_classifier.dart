import 'models/notification_log.dart';

/// The verdict on one piece of notification text.
class ClassificationResult {
  const ClassificationResult({required this.status, this.reason, this.signals = const []});

  final NotificationStatus status;

  /// Plain-language explanation, null when nothing was flagged.
  final String? reason;

  /// The specific phrases that matched, so the detail screen can show the user
  /// what to look for next time rather than just asserting a verdict.
  final List<String> signals;
}

/// Deterministic keyword and regex matching over incoming notification text.
///
/// Runs entirely on the device with no network involved, which is what lets
/// the permission screen promise that notification text never leaves the phone.
///
/// TODO(ml): replace deterministic keyword check with TFLite classifier
/// Keep this class as the fallback when the model is unavailable, and keep the
/// [ClassificationResult.signals] contract: whatever decides, the user is still
/// owed a reason they can check.
abstract final class NotificationClassifier {
  /// Predatory-lending phrasing, paired with why it is a warning sign.
  ///
  /// Written in ordinary spelling. Both these keys and the incoming text are
  /// pushed through [_normalise] before comparison, so they cannot fall out of
  /// step with the squashing rule.
  static const _predatorySignals = <String, String>{
    'tanpa bi checking':
        'Menghindari pemeriksaan yang wajib pada pemberi pinjaman resmi.',
    'tanpa slip gaji': 'Melewati pengecekan kemampuan bayar.',
    'tanpa jaminan cair': 'Menjanjikan uang tanpa syarat yang masuk akal.',
    'tanpa survey': 'Melewati verifikasi yang biasa dilakukan lembaga resmi.',
    'langsung cair': 'Janji pencairan super cepat.',
    'cair 3 menit': 'Janji pencairan super cepat.',
    'cair 5 menit': 'Janji pencairan super cepat.',
    'cair hitungan menit': 'Janji pencairan super cepat.',
    'klik sekarang': 'Mendesak kamu memutuskan cepat.',
    'buruan': 'Mendesak kamu memutuskan cepat.',
    'limit kamu naik': 'Menawarkan utang yang tidak kamu minta.',
    'limit naik': 'Menawarkan utang yang tidak kamu minta.',
    'pinjaman disetujui': 'Mengaku menyetujui pinjaman yang tidak kamu ajukan.',
    'dana talangan': 'Istilah yang sering dipakai pinjaman ilegal.',
  };

  /// Due-date phrasing. These are recorded for awareness and never dismissed:
  /// a real bill is the user's own business.
  static final _billPatterns = <RegExp>[
    RegExp(r'jatuh tempo'),
    RegExp(r'bayar minimum'),
    RegExp(r'segera bayar'),
    RegExp(r'tagihan .*(jatuh|tempo|bayar)'),
  ];

  /// Lowercases and collapses runs of the same letter.
  ///
  /// The squashing defeats the common trick of padding words to slip past a
  /// filter, so "caiiiir" and "cair" compare equal. It is lossy on ordinary
  /// words too ("banned" becomes "baned"), which is harmless here because the
  /// result is only ever compared against text normalised the same way.
  ///
  /// Note this uses replaceAllMapped, not replaceAll. Dart's replaceAll takes
  /// the replacement literally, so the handoff's `r'$1'` form would insert the
  /// characters "$1" rather than the captured letter.
  static String _normalise(String text) {
    return text.toLowerCase().replaceAllMapped(
      RegExp(r'([a-z])\1+'),
      (match) => match[1]!,
    );
  }

  /// Classifies notification [text] from [sourceApp].
  static ClassificationResult classify(String text, {String? sourceApp}) {
    final normalised = _normalise(text);

    final matched = <String>[];
    final reasons = <String>[];
    for (final entry in _predatorySignals.entries) {
      if (normalised.contains(_normalise(entry.key))) {
        matched.add(entry.key);
        if (!reasons.contains(entry.value)) reasons.add(entry.value);
      }
    }

    if (matched.isNotEmpty) {
      return ClassificationResult(
        status: NotificationStatus.mencurigakan,
        reason: reasons.first,
        signals: matched,
      );
    }

    for (final pattern in _billPatterns) {
      if (pattern.hasMatch(normalised)) {
        return const ClassificationResult(
          status: NotificationStatus.tagihan,
          reason: 'Terdeteksi sebagai pengingat jatuh tempo.',
        );
      }
    }

    return const ClassificationResult(status: NotificationStatus.aman);
  }

  /// Builds a log entry from raw notification text.
  static NotificationLog toLog({
    required String id,
    required String sourceApp,
    required String text,
    required DateTime time,
  }) {
    final result = classify(text, sourceApp: sourceApp);
    return NotificationLog(
      id: id,
      time: time,
      sourceApp: sourceApp,
      snippet: NotificationLog.makeSnippet(text),
      status: result.status,
      reason: result.reason,
    );
  }
}
