import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pikir/core/router/app_router.dart';
import 'package:pikir/core/router/routes.dart';
import 'package:pikir/core/theme/app_theme.dart';
import 'package:pikir/core/theme/tokens.dart';
import 'package:pikir/core/widgets/widgets.dart';

/// The interception flow.
///
/// These screens cover somebody else's app at the moment they are about to
/// borrow money, which is where the fair-pattern rules matter most and where
/// the Stitch reference departs from them furthest. The rules are asserted
/// here rather than trusted to survive future edits.
void main() {
  void useTargetDevice(WidgetTester tester) {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    addTearDown(tester.view.reset);
  }

  /// Pumps a bounded number of frames.
  ///
  /// Not pumpAndSettle: the offline fallback breathes forever by design.
  Future<void> settleBounded(WidgetTester tester) async {
    await tester.pump();
    for (var i = 0; i < 7; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  Future<void> open(WidgetTester tester, String route) async {
    useTargetDevice(tester);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          key: ValueKey(route),
          theme: PikirTheme.light,
          initialRoute: route,
          onGenerateRoute: AppRouter.onGenerateRoute,
          onUnknownRoute: AppRouter.onUnknownRoute,
        ),
      ),
    );
    await settleBounded(tester);
  }

  /// Every colour actually painted as text or as an icon on screen.
  Set<Color> paintedColours(WidgetTester tester) {
    final colours = <Color>{};
    for (final widget in tester.allWidgets) {
      if (widget is Text) {
        final colour = widget.style?.color;
        if (colour != null) colours.add(colour);
      } else if (widget is Icon) {
        final colour = widget.color;
        if (colour != null) colours.add(colour);
      }
    }
    return colours;
  }

  group('prompt aplikasi pinjol', () {
    testWidgets('asks one question with two equal, unselected options', (
      tester,
    ) async {
      await open(tester, Routes.intervensiTujuan);

      expect(find.text('Kamu mau ngutang buat apa?'), findsOneWidget);
      expect(find.byType(OptionCard), findsNWidgets(2));

      // Neither is pre-selected, so neither shows the chosen mark.
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);

      final sizes = tester
          .widgetList<OptionCard>(find.byType(OptionCard))
          .map((card) => tester.getSize(find.byWidget(card)))
          .toList();
      expect(sizes[0].width, sizes[1].width);
    });

    testWidgets('the way out is a full-size button, not a faint link', (
      tester,
    ) async {
      await open(tester, Routes.intervensiTujuan);

      final exit = find.widgetWithText(PikirButton, 'Lanjut ke aplikasi');
      expect(exit, findsOneWidget);
      // Section 6 rule 3: the option that declines keeps the shared metrics.
      expect(
        tester.getSize(exit).height,
        PikirSpacing.buttonHeight,
      );
      expect(tester.widget<PikirButton>(exit).onPressed, isNotNull);
    });

    testWidgets('an urgent need never reaches the item question', (
      tester,
    ) async {
      await open(tester, Routes.intervensiTujuan);

      await tester.tap(find.text('Kebutuhan mendesak atau modal kerja'));
      await settleBounded(tester);

      // Handed to mitigation, which routes to assistance rather than to a
      // loan product. Someone whose child is ill is not asked what they want
      // to buy.
      expect(find.text('Barang apa yang mau dibeli?'), findsNothing);
    });

    testWidgets('a want is asked to name the item itself', (tester) async {
      await open(tester, Routes.intervensiTujuan);

      await tester.tap(find.text('Beli barang atau keinginan'));
      await settleBounded(tester);

      expect(find.text('Barang apa yang mau dibeli?'), findsOneWidget);
      // Section 6 rule 2: the field starts empty, with only a placeholder.
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
          isEmpty);
    });
  });

  group('overlay chrome', () {
    testWidgets('every interception screen names PIKIR', (tester) async {
      // Section 6 rule 9. An app that draws over your screen without saying
      // who it is behaves like the thing this one warns about.
      for (final route in [
        Routes.intervensiBlanket,
        Routes.intervensiTujuan,
        Routes.intervensiBarang,
        Routes.intervensiLuring,
      ]) {
        await open(tester, route);
        expect(
          find.byType(PikirMark),
          findsWidgets,
          reason: '$route must carry a visible PIKIR mark.',
        );
      }
    });
  });

  group('opportunity cost', () {
    testWidgets('shows the full cost before the decision', (tester) async {
      await open(tester, Routes.intervensiOpportunityCost);

      // Section 6 rule 6: costs in rupiah, before the choice, not after.
      // The interest is the first thing on the screen.
      expect(find.text('Rp64.000'), findsOneWidget);
      expect(find.text('bunga yang kamu bayar'), findsOneWidget);
      expect(find.textContaining('Setara 8 kali makan'), findsOneWidget);

      // The ratio card sits just below the fold. Section 9 governs the
      // primary action, which is pinned; the evidence behind it may scroll.
      await tester.scrollUntilVisible(
        find.text('34%'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('34%'), findsOneWidget);
      expect(find.textContaining('Naik dari 18%'), findsOneWidget);
    });

    testWidgets('all three actions share width and stay live', (tester) async {
      await open(tester, Routes.intervensiOpportunityCost);

      final postpone = find.widgetWithText(
        PikirButton,
        'Tunda dulu, saya nabung',
      );
      final ask = find.widgetWithText(PikirButton, 'Tanya PIKIR soal ini');
      final proceed = find.byType(HoldToConfirmButton);

      expect(postpone, findsOneWidget);
      expect(ask, findsOneWidget);
      expect(proceed, findsOneWidget);

      // Section 6 rule 3: identical width. The option that continues is not
      // narrowed, and it is not disabled either.
      final width = tester.getSize(postpone).width;
      expect(tester.getSize(ask).width, width);
      expect(tester.getSize(proceed).width, width);

      expect(tester.widget<PikirButton>(ask).onPressed, isNotNull);
    });

    testWidgets('the reflection screen paints no red at all', (tester) async {
      await open(tester, Routes.intervensiOpportunityCost);

      expect(find.text('Jeda sebentar'), findsOneWidget);

      // Checked where the over-threshold warning actually lives, which is the
      // one place red would be tempting.
      await tester.scrollUntilVisible(
        find.text('Di atas batas aman'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('Naik dari 18%'), findsOneWidget);

      // DESIGN.md is explicit: no red anywhere in this flow, because the user
      // has done nothing wrong. The Stitch reference draws "Di atas batas
      // aman" in red with a red triangle; this asserts we did not copy it.
      expect(
        paintedColours(tester),
        isNot(contains(PikirColors.danger)),
        reason: 'Mode Tahan is amber. Red here would scold the user for '
            'considering a decision they are allowed to make.',
      );
    });

    testWidgets('continuing requires the whole five second hold', (
      tester,
    ) async {
      await open(tester, Routes.intervensiOpportunityCost);

      final proceed = find.byType(HoldToConfirmButton);
      final gesture = await tester.startGesture(tester.getCenter(proceed));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      for (var i = 0; i < 2; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      // Two seconds in, the friction is visibly underway and nothing has been
      // committed.
      expect(find.textContaining('Tahan terus'), findsOneWidget);
      expect(find.text('Rp64.000'), findsOneWidget);

      await gesture.up();
      await tester.pump(const Duration(milliseconds: 400));

      // Released early: still on the reflection screen, nothing recorded.
      expect(find.text('bunga yang kamu bayar'), findsOneWidget);
    });
  });

  group('fallback luring', () {
    testWidgets('offers a breath and two equal buttons, with no error code', (
      tester,
    ) async {
      await open(tester, Routes.intervensiLuring);

      expect(find.text('Internet mati'), findsOneWidget);
      expect(find.textContaining('Tarik napas'), findsWidgets);

      final wait = find.widgetWithText(PikirButton, 'Oke, saya tunda');
      final proceed = find.widgetWithText(PikirButton, 'Lanjut ke aplikasi');
      expect(tester.getSize(wait).width, tester.getSize(proceed).width);

      // No technical wording, and no red: from the user's side nothing has
      // gone wrong.
      expect(paintedColours(tester), isNot(contains(PikirColors.danger)));
      expect(find.textContaining('error'), findsNothing);
      expect(find.textContaining('gagal'), findsNothing);
    });
  });

  group('pengalihan ke ledger', () {
    testWidgets('offers both answers equally and pre-selects no category', (
      tester,
    ) async {
      await open(tester, Routes.intervensiCatatLedger);

      expect(find.text('Kami catat dulu ya'), findsOneWidget);

      final skip = find.widgetWithText(PikirButton, 'Jangan catat');
      final save = find.widgetWithText(PikirButton, 'Catat');
      expect(tester.getSize(skip).width, tester.getSize(save).width);
      expect(tester.getSize(skip).height, tester.getSize(save).height);

      // Section 6 rule 2: category may be left blank and starts that way.
      expect(find.text('Belum dipilih. Boleh dikosongkan.'), findsOneWidget);
    });
  });
}
