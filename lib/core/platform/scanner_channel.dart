import 'package:flutter/services.dart';

/// What Android's notification permission dialog answered.
class PostNotificationOutcome {
  const PostNotificationOutcome({
    required this.granted,
    required this.permanentlyDenied,
  });

  final bool granted;

  /// The dialog will not appear again, so the settings screen is the only
  /// remaining route.
  final bool permanentlyDenied;
}

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

  /// Whether this Android version gates posting notifications at all.
  ///
  /// False below API 33, where the OS grants it at install time. Asked rather
  /// than assumed, so the permission page can leave out something the user has
  /// no way to act on.
  static Future<bool> postNotificationApplicable() async =>
      await _guard(
        () => _channel.invokeMethod<bool>('postNotificationApplicable'),
      ) ??
      false;

  /// Whether PIKIR may post its own notifications.
  ///
  /// Without this the scanner still runs and still flags, but the replacement
  /// notification never reaches the shade, and nothing reports an error. The
  /// user sees a scanner that appears to do nothing.
  static Future<bool> hasPostNotification() async =>
      await _guard(() => _channel.invokeMethod<bool>('checkPostNotification')) ??
      false;

  /// Shows Android's own permission dialog and waits for the answer.
  ///
  /// The only one of PIKIR's permissions the OS will ask for on its behalf;
  /// the other three can only be granted on a settings screen.
  ///
  /// [PostNotificationOutcome.permanentlyDenied] means the dialog has been
  /// retired and asking again would show nothing, so the only way left is the
  /// app's notification settings.
  static Future<PostNotificationOutcome> requestPostNotification() async {
    final raw = await _guard(
      () =>
          _channel.invokeMapMethod<String, Object?>('requestPostNotification'),
    );
    return PostNotificationOutcome(
      granted: raw?['granted'] as bool? ?? false,
      permanentlyDenied: raw?['permanentlyDenied'] as bool? ?? false,
    );
  }

  static Future<void> openAppNotificationSettings() =>
      _guard(() => _channel.invokeMethod<void>('openAppNotificationSettings'));

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
