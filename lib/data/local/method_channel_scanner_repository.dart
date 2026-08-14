import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/notification_log.dart';
import '../repositories/repositories.dart';

/// Reads the scan log written by the Android NotificationListenerService.
///
/// ## Why a channel and not SharedPreferences
///
/// The original plan was for Kotlin to write into shared_preferences so Flutter
/// could read it directly. That does not work safely: the plugin encodes a
/// `List<String>` with an internal marker prefix and its own JSON layout, so
/// writing to it from Kotlin means depending on a private encoding that a
/// plugin update can change without warning. The service also has to keep
/// working while the Flutter engine is not running, so it needs its own store
/// either way.
///
/// So Kotlin owns the store and hands it over across this channel. The
/// interface is unchanged, which was the actual goal: swapping the scanner
/// screens to live data is still one line in providers.dart.
///
/// [SharedPreferencesScannerRepository] is still the right choice for logs
/// written by Dart; this one is for logs written by the platform service.
class MethodChannelScannerRepository implements NotificationScannerRepository {
  const MethodChannelScannerRepository();

  static const _channel = MethodChannel('com.pikir.pikir/scanner');

  @override
  Future<bool> isEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('scannerIsEnabled') ?? false;
    } on PlatformException {
      // The channel is absent on any non-Android host, and in tests. Reporting
      // "off" is the honest answer: nothing is scanning.
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> setEnabled({required bool enabled}) async {
    try {
      await _channel.invokeMethod<void>('scannerSetEnabled', {
        'enabled': enabled,
      });
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  @override
  Future<List<NotificationLog>> logs() async {
    final String raw;
    try {
      raw = await _channel.invokeMethod<String>('scannerLogs') ?? '[]';
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    final logs = <NotificationLog>[];
    for (final entry in decoded) {
      // A row that will not parse is dropped rather than thrown over. Losing
      // one line of history beats a scanner screen that crashes and hides all
      // of it.
      if (entry is Map<String, dynamic>) {
        logs.add(NotificationLog.fromJson(entry));
      }
    }

    logs.sort((a, b) => b.time.compareTo(a.time));
    return List.unmodifiable(logs);
  }

  @override
  Future<void> record(NotificationLog log) async {
    // Writing is the service's job. Dart records nothing here, because the
    // scanner has to keep working with the Flutter engine shut down.
    throw UnsupportedError(
      'The Android service owns the scan log. Dart only reads it.',
    );
  }

  @override
  Future<void> clearLogs() async {
    try {
      await _channel.invokeMethod<void>('scannerClearLogs');
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  @override
  Future<List<DetectedBill>> detectedBills() async {
    // Deliberately empty rather than fabricated. Turning a flagged message
    // into a bill needs the amount and the due date pulled out of free text,
    // and that extraction is not written yet on either side.
    //
    // TODO(scanner): extract amount and due date from logs with
    // NotificationStatus.tagihan, then build the list from those.
    return const [];
  }

  @override
  Future<String> generateWarning(NotificationLog log) async {
    // TODO(backend): POST /api/v1/notification/generate-warning
    return log.reason ??
        'Pesan ini punya ciri tawaran pinjaman berisiko. Kami sembunyikan '
            'supaya kamu tidak tergoda dulu.';
  }
}
