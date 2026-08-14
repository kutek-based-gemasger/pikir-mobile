import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_log.dart';
import '../repositories/repositories.dart';

/// A real on-device implementation of the scan log, backed by
/// SharedPreferences.
///
/// It implements the same interface as the mock, so switching the screens over
/// is a one-line change in the provider file and no screen is touched.
///
/// ## What this does not do
///
/// SharedPreferences is plain key-value storage on the device. It is not
/// encrypted. The privacy screen tells the user "Data di HP-mu dikunci dengan
/// enkripsi", and the handoff calls for AES-256 SQLite, so this class does not
/// yet make good on that promise. It stores a short excerpt of notification
/// text, which is exactly the kind of thing the claim was about.
///
/// That is an acceptable trade for a mocked frontend round and not acceptable
/// for a real release.
///
/// TODO(storage): move to an encrypted store before any build that a real user
/// installs, or soften the copy on the privacy screen to match reality.
class SharedPreferencesScannerRepository
    implements NotificationScannerRepository {
  SharedPreferencesScannerRepository({SharedPreferences? preferences})
    : _injected = preferences;

  static const _logsKey = 'pikir.scanner.logs.v1';
  static const _enabledKey = 'pikir.scanner.enabled.v1';

  /// How many log lines are kept.
  ///
  /// Bounded on purpose. The log exists so the user can see what PIKIR has
  /// been doing, not so the app accumulates an indefinite copy of their
  /// notifications.
  static const maxEntries = 200;

  final SharedPreferences? _injected;
  Future<SharedPreferences>? _pending;

  Future<SharedPreferences> get _prefs {
    final injected = _injected;
    if (injected != null) return Future.value(injected);
    return _pending ??= SharedPreferences.getInstance();
  }

  @override
  Future<bool> isEnabled() async {
    final prefs = await _prefs;
    // Defaults to off. Scanning notifications is something the user switches
    // on deliberately, never something they discover was already running.
    return prefs.getBool(_enabledKey) ?? false;
  }

  @override
  Future<void> setEnabled({required bool enabled}) async {
    final prefs = await _prefs;
    await prefs.setBool(_enabledKey, enabled);
  }

  @override
  Future<List<NotificationLog>> logs() async {
    final prefs = await _prefs;
    final raw = prefs.getStringList(_logsKey) ?? const [];

    final parsed = <NotificationLog>[];
    for (final entry in raw) {
      final log = _decode(entry);
      // A line that cannot be decoded is dropped rather than thrown over.
      // Losing one row of history is a smaller harm than a scanner screen
      // that crashes and hides all of it.
      if (log != null) parsed.add(log);
    }

    parsed.sort((a, b) => b.time.compareTo(a.time));
    return List.unmodifiable(parsed);
  }

  @override
  Future<void> record(NotificationLog log) async {
    final prefs = await _prefs;
    final raw = [...?prefs.getStringList(_logsKey)];

    raw.insert(0, jsonEncode(log.toJson()));
    if (raw.length > maxEntries) raw.removeRange(maxEntries, raw.length);

    await prefs.setStringList(_logsKey, raw);
  }

  @override
  Future<void> clearLogs() async {
    final prefs = await _prefs;
    await prefs.remove(_logsKey);
  }

  @override
  Future<List<DetectedBill>> detectedBills() async {
    // Deliberately empty rather than fabricated.
    //
    // Turning a flagged notification into a bill needs the amount and the due
    // date pulled out of free text, and that extraction is not written yet.
    // Returning invented rows here would put numbers on a screen that claims
    // they were detected from the user's own notifications.
    //
    // TODO(scanner): extract amount and due date from logs with
    // NotificationStatus.tagihan, then build the list from those.
    return const [];
  }

  @override
  Future<String> generateWarning(NotificationLog log) async {
    // TODO(backend): POST /api/v1/notification/generate-warning
    //
    // Until the backend exists, the deterministic reason is the warning. It is
    // shorter than a generated one but it is true, and it is what the detail
    // screen shows anyway.
    return log.reason ??
        'Pesan ini punya ciri tawaran pinjaman berisiko. Kami sembunyikan '
            'supaya kamu tidak tergoda dulu.';
  }

  static NotificationLog? _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return NotificationLog.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }
}
