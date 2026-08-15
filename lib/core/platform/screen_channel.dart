import 'package:flutter/services.dart';

/// What the screen watcher detected.
class ScreenTrigger {
  const ScreenTrigger({
    required this.isCheckout,
    this.sourceApp,
    this.amount,
  });

  /// True for a paylater checkout, false for a loan app opening.
  final bool isCheckout;

  /// The package the trigger came from, for the log line only.
  final String? sourceApp;

  /// The total read off the checkout screen, when one was found.
  final int? amount;
}

/// The Flutter side of the screen watcher's platform channel.
///
/// One wrapper per service, so no screen talks to a raw MethodChannel. Every
/// call degrades to a no-op away from Android rather than throwing, which is
/// what lets the widget tests run against these screens unchanged.
abstract final class ScreenChannel {
  static const _channel = MethodChannel('com.pikir.pikir/screen');

  /// Whether the accessibility service is switched on.
  static Future<bool> hasScreenAccess() async =>
      await _guard(() => _channel.invokeMethod<bool>('checkScreenAccess')) ??
      false;

  static Future<void> openScreenAccessSettings() =>
      _guard(() => _channel.invokeMethod<void>('openScreenAccessSettings'));

  /// Whether PIKIR may draw over other apps.
  ///
  /// The interception needs this as much as it needs accessibility. Without
  /// it Android drops the background activity start without an error, so the
  /// detection fires and nothing appears, which is the hardest failure to
  /// diagnose from inside the app.
  static Future<bool> hasOverlayPermission() async =>
      await _guard(
        () => _channel.invokeMethod<bool>('checkOverlayPermission'),
      ) ??
      false;

  static Future<void> openOverlaySettings() =>
      _guard(() => _channel.invokeMethod<void>('openOverlaySettings'));

  /// Sends PIKIR to the background, uncovering the app underneath.
  ///
  /// What "Lanjut ke aplikasi" has to do after a real trigger: the user asked
  /// to go on to the app they were already in, and popping a route would only
  /// move them further into PIKIR.
  static Future<void> leaveToPreviousApp() =>
      _guard(() => _channel.invokeMethod<void>('leaveToPreviousApp'));

  /// The apps PIKIR is allowed to see, for the settings screen to list.
  static Future<List<String>> watchedApps() async =>
      await _guard(
        () => _channel.invokeListMethod<String>('watchedApps'),
      ) ??
      const [];

  /// Takes the trigger the watcher arrived with, if any.
  ///
  /// Reading clears it, so an interception fires once rather than every time
  /// the app resumes.
  static Future<ScreenTrigger?> consumePendingTrigger() async {
    final raw = await _guard(
      () => _channel.invokeMapMethod<String, Object?>('consumePendingTrigger'),
    );
    if (raw == null) return null;

    return ScreenTrigger(
      isCheckout: raw['trigger'] == 'checkout_paylater',
      sourceApp: raw['sourceApp'] as String?,
      amount: raw['amount'] as int?,
    );
  }

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
