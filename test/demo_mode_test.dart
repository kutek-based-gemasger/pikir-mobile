import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_overrides.dart';
import 'package:pikir/core/router/app_router.dart';
import 'package:pikir/core/router/routes.dart';
import 'package:pikir/core/theme/app_theme.dart';
import 'package:pikir/core/widgets/widgets.dart';

/// Mode demo.
///
/// It exists so the submission recording shows the product rather than a setup
/// process, which makes it the one screen whose failure is invisible until the
/// camera is already rolling.
void main() {
  Future<void> open(WidgetTester tester, String route) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    addTearDown(tester.view.reset);

    // Nothing granted, which is what the channels report away from a device
    // and the state the demo screen has to be honest about.
    mockServiceChannels(granted: false);

    await tester.pumpWidget(
      mockScope(
        child: MaterialApp(
          key: ValueKey(route),
          theme: PikirTheme.light,
          initialRoute: route,
          onGenerateRoute: AppRouter.onGenerateRoute,
          onUnknownRoute: AppRouter.onUnknownRoute,
        ),
      ),
    );
    await tester.pump();
    for (var i = 0; i < 7; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  /// Scrolls until [finder] is on screen. The action list runs past the fold.
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
  }

  testWidgets('offers the four actions CLAUDE.md section 8 lists', (
    tester,
  ) async {
    await open(tester, Routes.demo);

    for (final label in [
      'Simulasi checkout paylater',
      'Simulasi buka aplikasi pinjaman',
      'Simulasi notifikasi pinjol masuk',
      'Reset data ke kondisi awal',
    ]) {
      await scrollTo(tester, find.text(label));
      expect(find.text(label), findsOneWidget, reason: '$label is missing.');
    }
  });

  testWidgets('says plainly how many permissions are still off', (
    tester,
  ) async {
    await open(tester, Routes.demo);

    // Nothing granted here, and the app cannot switch any of it on itself.
    // Saying so is the honest answer, and the count says how much is missing
    // rather than leaving it to be guessed from a colour.
    await scrollTo(tester, find.text('Izin perlindungan'));
    expect(find.text('3 dari 3 mati'), findsOneWidget);
    expect(find.widgetWithText(PikirButton, 'Atur izin'), findsOneWidget);
  });

  testWidgets('says the interception has no real trigger without the permission', (
    tester,
  ) async {
    await open(tester, Routes.demo);

    // Somebody must not record a demo believing the detection is live when it
    // is only the buttons above firing the flow.
    await scrollTo(tester, find.text('Izin perlindungan'));
    expect(
      find.textContaining('hanya bisa dipicu dari tombol'),
      findsOneWidget,
    );
  });

  testWidgets('the checkout simulation lands on the blocking screen', (
    tester,
  ) async {
    await open(tester, Routes.demo);

    await tester.tap(find.text('Simulasi checkout paylater'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Sebentar ya'), findsOneWidget);

    // Let the analysis finish. Ending here would leave its timer pending,
    // which the test binding treats as a failure, and would also skip the
    // hand-off this screen exists to perform.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.text('Jeda sebentar'), findsOneWidget);
  });

  testWidgets('the loan-app simulation asks the one question', (tester) async {
    await open(tester, Routes.demo);

    await tester.tap(find.text('Simulasi buka aplikasi pinjaman'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Kamu mau ngutang buat apa?'), findsOneWidget);
  });

  testWidgets('reset restores the seeded figures', (tester) async {
    await open(tester, Routes.demo);

    await scrollTo(tester, find.text('Reset data ke kondisi awal'));
    await tester.tap(find.text('Reset data ke kondisi awal'));
    await tester.pump();
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // The three figures section 8 pins, quoted back so a drift in the seed
    // shows up here rather than on camera.
    expect(find.textContaining('Rp3.150.000'), findsOneWidget);
    expect(find.textContaining('18%'), findsOneWidget);
    expect(find.textContaining('Rp450.000'), findsOneWidget);
  });

  testWidgets('adds no celebration of its own', (tester) async {
    await open(tester, Routes.demo);

    // Section 6 rule 5. A demo tool is exactly where a "Berhasil!" or a
    // confetti burst tends to sneak in.
    for (final banned in ['Selamat', 'Hebat', 'Berhasil!', 'Keren']) {
      expect(find.textContaining(banned), findsNothing);
    }
  });
}
