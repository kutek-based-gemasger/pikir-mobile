import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_overrides.dart';
import 'package:pikir/core/router/app_router.dart';
import 'package:pikir/core/router/screen_registry.dart';
import 'package:pikir/core/theme/app_theme.dart';

/// Renders every screen under conditions harsher than the target device.
///
/// Six horizontal overflows have been found and fixed one at a time across the
/// build, always the same shape: a Text inside a Row with no Flexible around
/// it. Catching them one screen per phase is slow and leaves the rest
/// unchecked, so this sweeps the lot.
///
/// Two conditions, both real rather than hypothetical. 360dp wide is one of
/// the most common Android widths and is narrower than the 393dp target. And a
/// 1.3x text scale is ordinary among the users this app is built for, who
/// often run their phones at a larger size; app.dart deliberately does not
/// clamp it, which is only defensible if the layouts survive it.
void main() {
  Widget appAt(String route) => mockScope(
    child: MaterialApp(
      key: ValueKey(route),
      theme: PikirTheme.light,
      initialRoute: route,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: AppRouter.onUnknownRoute,
    ),
  );

  Widget scaled(String route, double textScale) => mockScope(
    child: MaterialApp(
      key: ValueKey('$route-$textScale'),
      theme: PikirTheme.light,
      initialRoute: route,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: AppRouter.onUnknownRoute,
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: child!,
      ),
    ),
  );

  /// Bounded pumping: the offline fallback breathes forever by design, so
  /// pumpAndSettle would never return.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    for (var i = 0; i < 7; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  testWidgets('every screen survives a 360dp width', (tester) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360 * 3, 800 * 3);
    addTearDown(tester.view.reset);

    final broken = <String>[];
    for (final entry in kScreenRegistry) {
      await tester.pumpWidget(appAt(entry.route));
      await settle(tester);

      final error = tester.takeException();
      if (error != null) broken.add('${entry.route}: $error');
    }

    expect(broken, isEmpty, reason: broken.join('\n'));
  });

  testWidgets('every screen survives a 1.3x text scale', (tester) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    addTearDown(tester.view.reset);

    final broken = <String>[];
    for (final entry in kScreenRegistry) {
      await tester.pumpWidget(scaled(entry.route, 1.3));
      await settle(tester);

      final error = tester.takeException();
      if (error != null) broken.add('${entry.route}: $error');
    }

    expect(broken, isEmpty, reason: broken.join('\n'));
  });
}
