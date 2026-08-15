import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_overrides.dart';
import 'package:pikir/core/router/app_router.dart';
import 'package:pikir/core/router/routes.dart';
import 'package:pikir/core/theme/app_theme.dart';
import 'package:pikir/core/widgets/widgets.dart';
import 'package:pikir/features/onboarding/screens/anonim_screen.dart';
import 'package:pikir/features/intervention/intervention_state.dart';
import 'package:pikir/features/onboarding/screens/splash_screen.dart';

/// Leaving an interception.
///
/// Written after "Lanjut ke aplikasi" stranded a real user on the splash
/// screen with nothing to tap. Two separate mistakes met there: the button
/// popped a route instead of giving back the app underneath, and the splash
/// screen gave up advancing the first time it found something on top of it.
void main() {
  /// Records what the screen channel was asked to do.
  List<String> recordChannelCalls() {
    final calls = <String>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const channel = MethodChannel('com.pikir.pikir/screen');

    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return switch (call.method) {
        'checkScreenAccess' ||
        'checkOverlayPermission' => false,
        'watchedApps' => const <String>['com.fintopia.idnEasycash.google'],
        _ => null,
      };
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    return calls;
  }

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      mockScope(
        child: MaterialApp(
          theme: PikirTheme.light,
          initialRoute: Routes.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
          onUnknownRoute: AppRouter.onUnknownRoute,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('the splash screen waits out an interception on top of it', (
    tester,
  ) async {
    recordChannelCalls();
    await pumpApp(tester);

    // The watcher pushes the interception over the splash screen, which is
    // exactly what happens when a loan app is opened from cold.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(navigator.pushNamed(Routes.intervensiTujuan));
    await tester.pumpAndSettle();

    // Well past the dwell. The splash screen must not have replaced itself
    // underneath the interception.
    await tester.pump(SplashScreen.dwell * 3);
    await tester.pumpAndSettle();
    expect(find.text('Kamu mau ngutang buat apa?'), findsOneWidget);

    // And once the interception closes, it must not sit there forever.
    navigator.pop();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(AnonimScreen), findsOneWidget);
  });

  testWidgets('"Lanjut ke aplikasi" hands back the app underneath', (
    tester,
  ) async {
    final calls = recordChannelCalls();
    await pumpApp(tester);

    // Started the way the screen watcher starts it, rather than from Mode
    // Demo, which is the whole distinction being tested.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Navigator)),
    );
    container
        .read(interventionControllerProvider.notifier)
        .startLoanApp(fromRealTrigger: true);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(navigator.pushNamed(Routes.intervensiTujuan));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(PikirButton, 'Lanjut ke aplikasi'));
    await tester.pumpAndSettle();

    // The user asked for the app they were already in. Popping a route would
    // have walked them further into PIKIR instead.
    expect(calls, contains('leaveToPreviousApp'));
  });
}
