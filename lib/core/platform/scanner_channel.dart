import 'package:flutter/services.dart';

/// The Flutter side of the notification scanner's platform channel.
///
/// One wrapper per service, so no screen talks to a raw MethodChannel or has
/// to know the method names.
///
/// Every call degrades to a no-op away from Android rather than throwing. The
/// scanner is a platform capability; a host without it should make the app
/// quieter, not crash it, and every widget test runs on such a host.
abstract final class ScannerChannel {
  static const _channel = MethodChannel('com.pikir.pikir/scanner');

  /// Fires the full flagged-notification path: classify, log, replace.
  ///
  /// Used by Mode Demo. Returns null where the platform is unavailable.
  static Future<Map<String, Object?>?> simulateFlagged({
    required String appLabel,
    required String title,
    required String text,
  }) => _guard(
    () => _channel.invokeMapMethod<String, Object?>('demoFlaggedNotification', {
      'appLabel': appLabel,
      'title': title,
      'text': text,
    }),
  );

  /// Whether the OS has granted notification access.
  ///
  /// Only the user can grant this, from Android's own settings screen, so the
  /// app can ask and check but never switch it on itself.
  static Future<bool> hasNotificationAccess() async =>
      await _guard(
        () => _channel.invokeMethod<bool>('checkNotificationAccess'),
      ) ??
      false;

  static Future<void> openNotificationAccessSettings() =>
      _guard(() => _channel.invokeMethod<void>('openNotificationAccessSettings'));

  static Future<T?> _guard<T>(Future<T?> Function() call) async {
    try {
      return await call();
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
