import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pikir/core/theme/app_theme.dart';
import 'package:pikir/core/theme/tokens.dart';
import 'package:pikir/core/widgets/widgets.dart';

/// The shared components encode product rules that are judged, so the rules
/// get tests. A component that merely renders is not enough: the point is
/// that a decline option cannot be made smaller or lighter than the option
/// beside it, and that friction stays in the gesture.
void main() {
  Widget host(Widget child) => MaterialApp(
    theme: PikirTheme.light,
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 353, child: child),
      ),
    ),
  );

  group('PikirButton', () {
    testWidgets('every variant is the same height', (tester) async {
      for (final variant in PikirButtonVariant.values) {
        await tester.pumpWidget(
          host(
            PikirButton(
              label: 'Pilihan',
              variant: variant,
              onPressed: () {},
            ),
          ),
        );

        expect(
          tester.getSize(find.byType(PikirButton)).height,
          PikirSpacing.buttonHeight,
          reason: '$variant must match the shared button height.',
        );
      }
    });

    testWidgets('a filled and an outlined button render identically sized', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          Column(
            children: [
              PikirButton(
                key: const Key('lanjut'),
                label: 'Tunda dulu, saya nabung',
                onPressed: () {},
              ),
              PikirButton(
                key: const Key('keluar'),
                label: 'Saya tetap lanjut',
                variant: PikirButtonVariant.outlined,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      // CLAUDE.md section 6 rule 3: identical width, height, and font weight.
      expect(
        tester.getSize(find.byKey(const Key('lanjut'))),
        tester.getSize(find.byKey(const Key('keluar'))),
      );
    });

    testWidgets('PikirButtonRow gives each choice equal width', (tester) async {
      await tester.pumpWidget(
        host(
          PikirButtonRow(
            buttons: [
              PikirButton(
                key: const Key('nanti'),
                label: 'Nanti saja',
                variant: PikirButtonVariant.outlined,
                onPressed: () {},
              ),
              PikirButton(
                key: const Key('aktifkan'),
                label: 'Buka pengaturan izin',
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      // Longer copy on one side must not buy it a wider button.
      expect(
        tester.getSize(find.byKey(const Key('nanti'))).width,
        tester.getSize(find.byKey(const Key('aktifkan'))).width,
      );
    });
  });

  group('HoldToConfirmButton', () {
    /// Advances the clock by [seconds] of held press.
    ///
    /// The two leading pumps are not padding. The zero-length one sweeps the
    /// gesture arena so onTapDown fires and the controller starts; the 1ms
    /// one delivers the ticker's opening tick, which is what fixes its start
    /// time. Elapsed time only accumulates from there, so a single large pump
    /// would leave the controller sitting at zero.
    Future<void> holdFor(WidgetTester tester, int seconds) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      for (var i = 0; i < seconds; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
    }

    testWidgets('a short press does not confirm', (tester) async {
      var confirmed = false;
      await tester.pumpWidget(
        host(
          HoldToConfirmButton(
            label: 'Saya tetap lanjut',
            onConfirmed: () => confirmed = true,
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(HoldToConfirmButton)),
      );
      await holdFor(tester, 2);
      await gesture.up();
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
    });

    testWidgets('a full five-second hold confirms', (tester) async {
      var confirmed = false;
      await tester.pumpWidget(
        host(
          HoldToConfirmButton(
            label: 'Saya tetap lanjut',
            onConfirmed: () => confirmed = true,
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(HoldToConfirmButton)),
      );
      await holdFor(tester, kHoldToConfirmDuration.inSeconds);

      expect(confirmed, isTrue);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('the button keeps its full size while held', (tester) async {
      await tester.pumpWidget(
        host(
          HoldToConfirmButton(
            label: 'Saya tetap lanjut',
            onConfirmed: () {},
          ),
        ),
      );

      final finder = find.byType(HoldToConfirmButton);
      final resting = tester.getSize(finder);

      final gesture = await tester.startGesture(tester.getCenter(finder));
      await holdFor(tester, 3);

      // Proves the hold actually registered, so the size check below is
      // measuring a button mid-press rather than one that never started.
      expect(find.textContaining('Tahan terus'), findsOneWidget);

      // Rule 4: friction lives in the gesture. The control must not shrink,
      // fade, or otherwise retreat while the user is holding it.
      expect(tester.getSize(finder), resting);

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('status and content components', () {
    testWidgets('StatusChip always renders its text label', (tester) async {
      for (final status in PikirStatus.values) {
        await tester.pumpWidget(
          host(StatusChip(status: status, label: 'Aman')),
        );
        // Rule 1: colour is never the only carrier of a status.
        expect(find.text('Aman'), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);
      }
    });

    testWidgets('ThresholdGauge shows number, threshold, and status', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const ThresholdGauge(
            value: 0.18,
            caption: 'dari penghasilanmu',
            footnote: 'Rp720.000 dari Rp4.000.000',
          ),
        ),
      );

      expect(find.text('18%'), findsOneWidget);
      expect(find.text('Batas aman 30%'), findsOneWidget);
      expect(find.text('Aman'), findsOneWidget);
    });

    testWidgets('ThresholdGauge over the threshold reports it in words', (
      tester,
    ) async {
      await tester.pumpWidget(host(const ThresholdGauge(value: 0.34)));

      expect(find.text('34%'), findsOneWidget);
      expect(find.text('Di atas batas aman'), findsOneWidget);
    });

    testWidgets('OptionCard is not selected unless told to be', (tester) async {
      await tester.pumpWidget(
        host(
          OptionCard(
            icon: Icons.local_hospital_outlined,
            label: 'Kesehatan',
            example: 'berobat, obat, rumah sakit',
            onTap: () {},
          ),
        ),
      );

      // Rule 2: nothing is pre-selected. The check mark only appears once the
      // user has chosen.
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
      expect(find.text('berobat, obat, rumah sakit'), findsOneWidget);
      expect(
        tester.getSize(find.byType(OptionCard)).height,
        greaterThanOrEqualTo(PikirSpacing.optionCardMinHeight),
      );
    });

    testWidgets('SourceChip and DisclaimerBand render', (tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: [
              SourceChip(label: 'OJK - POJK Pinjaman Daring'),
              DisclaimerBand(),
            ],
          ),
        ),
      );

      expect(find.text('OJK - POJK Pinjaman Daring'), findsOneWidget);
      expect(find.textContaining('OJK 157'), findsOneWidget);
    });

    testWidgets('TierProgressBar marks the optional tier', (tester) async {
      await tester.pumpWidget(
        host(
          const TierProgressBar(
            currentAmount: 450000,
            tiers: [
              SavingsTier(label: 'Tingkat 1', target: 1000000),
              SavingsTier(label: 'Tingkat 2', target: 2000000),
              SavingsTier(
                label: 'Tingkat 3',
                target: 7200000,
                optional: true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Opsional'), findsOneWidget);
      expect(find.text('Tingkat 1'), findsOneWidget);
    });
  });
}
