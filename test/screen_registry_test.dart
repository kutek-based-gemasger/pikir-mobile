import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pikir/core/router/app_router.dart';
import 'package:pikir/core/router/routes.dart';
import 'package:pikir/core/router/screen_registry.dart';
import 'package:pikir/core/theme/app_theme.dart';

/// The Phase 1 deliverable is that every screen opens. These tests check that
/// claim against the registry rather than against a list someone maintains by
/// hand, so a route added later is covered without anyone remembering to.
void main() {
  /// CLAUDE.md section 9: screens must run at 393x852 without the primary
  /// action falling below the fold. Rendering at that exact size means a
  /// layout overflow fails the test instead of showing up on a device later.
  void useTargetDevice(WidgetTester tester) {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    addTearDown(tester.view.reset);
  }

  /// Builds the app rooted at [route].
  ///
  /// Two details here are load-bearing. The ValueKey forces a fresh Navigator
  /// on every pump: MaterialApp.initialRoute is only honoured when the
  /// Navigator is first created, so without it a loop of pumpWidget calls
  /// silently keeps showing the first route and tests nothing. And the
  /// ProviderScope matches what main.dart installs, without which every
  /// ConsumerWidget screen throws "No ProviderScope found".
  Widget appAt(String route, [GlobalKey<NavigatorState>? navigatorKey]) =>
      ProviderScope(
        child: MaterialApp(
          key: ValueKey(route),
          theme: PikirTheme.light,
          navigatorKey: navigatorKey,
          initialRoute: route,
          onGenerateRoute: AppRouter.onGenerateRoute,
          onUnknownRoute: AppRouter.onUnknownRoute,
        ),
      );

  testWidgets('every registered route builds without error', (tester) async {
    useTargetDevice(tester);

    for (final entry in kScreenRegistry) {
      await tester.pumpWidget(appAt(entry.route));

      // A bounded number of frames rather than pumpAndSettle. The offline
      // fallback runs a breathing animation that repeats forever by design,
      // so settling would never finish. Roughly two seconds of frames is
      // enough for the mock repositories' delays to resolve.
      await tester.pump();
      for (var i = 0; i < 7; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }

      expect(
        tester.takeException(),
        isNull,
        reason: 'Route ${entry.route} (${entry.title}) failed to build.',
      );
    }
  });

  testWidgets('pushing an unregistered route lands on the unknown-route page', (
    tester,
  ) async {
    useTargetDevice(tester);

    // Tested through pushNamed rather than initialRoute: a failed
    // initialRoute is silently replaced with "/" by the framework and never
    // reaches onUnknownRoute, so pushing is the only path this page is on.
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(appAt(Routes.splash, navigatorKey));
    await tester.pumpAndSettle();

    navigatorKey.currentState!.pushNamed('/rute-yang-tidak-ada');
    await tester.pumpAndSettle();

    expect(find.text('Rute belum terdaftar'), findsOneWidget);
  });

  test('route names are unique', () {
    final seen = <String>{};
    for (final entry in kScreenRegistry) {
      expect(
        seen.add(entry.route),
        isTrue,
        reason: 'Duplicate route ${entry.route}; the registry map would drop '
            'one of the two silently.',
      );
    }
  });

  test('the screen map lists every non-tool route', () {
    final product = kScreenRegistry
        .where((e) => e.group != ScreenGroup.perkakas)
        .length;

    expect(product, greaterThan(0));
    expect(kScreenByRoute.length, kScreenRegistry.length);
    expect(kScreenByRoute.containsKey(Routes.petaLayar), isTrue);
  });
}
