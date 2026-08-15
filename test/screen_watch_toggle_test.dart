import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_overrides.dart';
import 'package:pikir/core/router/app_router.dart';
import 'package:pikir/core/router/routes.dart';
import 'package:pikir/core/theme/app_theme.dart';
import 'package:pikir/features/settings/widgets/settings_row.dart';

/// The in-app switch for screen detection.
///
/// It sits beside the Android permission rather than replacing it, and the two
/// fail differently: the permission is granted on a settings screen PIKIR
/// cannot reach, this is the user's own switch. A user who cannot find the
/// second one is left with an app that looks broken.
void main() {
  /// Records what the screen channel was told, and answers as the platform.
  ({List<MethodCall> calls, void Function(bool) setEnabled}) mockScreenChannel({
    bool enabled = true,
  }) {
    final calls = <MethodCall>[];
    var current = enabled;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const channel = MethodChannel('com.pikir.pikir/screen');

    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return switch (call.method) {
        'screenWatchIsEnabled' => current,
        'checkScreenAccess' || 'checkOverlayPermission' => true,
        'watchedApps' => const <String>['com.tokopedia.tkpd'],
        'screenWatchSetEnabled' => null,
        _ => null,
      };
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    return (calls: calls, setEnabled: (value) => current = value);
  }

  Future<void> openSettings(WidgetTester tester) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      mockScope(
        child: MaterialApp(
          theme: PikirTheme.light,
          onGenerateInitialRoutes: (_) => [
            AppRouter.onGenerateRoute(
              const RouteSettings(name: Routes.pengaturan),
            )!,
          ],
          onGenerateRoute: AppRouter.onGenerateRoute,
          onUnknownRoute: AppRouter.onUnknownRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sits in Settings as a switch, not buried in Android', (
    tester,
  ) async {
    // The scanner channel first, then the screen channel over the top of it:
    // mockServiceChannels claims both, so installing it second would silently
    // replace the recording handler below.
    mockServiceChannels(granted: true);
    mockScreenChannel();
    await openSettings(tester);

    await scrollTo(tester, find.text('Deteksi layar'));
    final row = find.ancestor(
      of: find.text('Deteksi layar'),
      matching: find.byType(SettingsToggleRow),
    );
    expect(row, findsOneWidget);
  });

  testWidgets('says how many apps it is allowed to watch', (tester) async {
    mockServiceChannels(granted: true);
    mockScreenChannel();
    await openSettings(tester);

    // Counted from the Kotlin whitelist rather than a number written in Dart,
    // so it cannot drift away from the list that governs detection.
    await scrollTo(tester, find.textContaining('1 aplikasi terdaftar'));
    expect(find.textContaining('1 aplikasi terdaftar'), findsOneWidget);
  });

  testWidgets('tells the platform when switched off', (tester) async {
    mockServiceChannels(granted: true);
    final channel = mockScreenChannel();
    await openSettings(tester);

    await scrollTo(tester, find.text('Deteksi layar'));
    await tester.tap(
      find.descendant(
        of: find.ancestor(
          of: find.text('Deteksi layar'),
          matching: find.byType(SettingsToggleRow),
        ),
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();

    final sent = channel.calls
        .where((call) => call.method == 'screenWatchSetEnabled')
        .toList();
    expect(sent, hasLength(1));
    expect(sent.single.arguments, {'enabled': false});
  });

  testWidgets('defaults to on where the platform cannot answer', (
    tester,
  ) async {
    // Every widget test and every non-Android host. Reporting "off" there
    // would describe an app that is switched off rather than one that simply
    // has no platform to ask.
    mockServiceChannels(granted: true);
    await openSettings(tester);

    await scrollTo(tester, find.text('Deteksi layar'));
    final toggle = tester.widget<Switch>(
      find.descendant(
        of: find.ancestor(
          of: find.text('Deteksi layar'),
          matching: find.byType(SettingsToggleRow),
        ),
        matching: find.byType(Switch),
      ),
    );
    expect(toggle.value, isTrue);
  });
}
