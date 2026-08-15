import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_overrides.dart';
import 'package:pikir/core/router/app_router.dart';
import 'package:pikir/core/router/routes.dart';
import 'package:pikir/core/theme/app_theme.dart';
import 'package:pikir/core/theme/tokens.dart';
import 'package:pikir/core/widgets/widgets.dart';
import 'package:pikir/data/mock/mock_repositories.dart';
import 'package:pikir/data/mock/seed.dart';
import 'package:pikir/data/models/debt_entry.dart';

/// Finishing and deleting a debt.
///
/// Two different things that a single "remove" would have blurred together:
/// one is the good ending a ledger is kept for, the other is fixing a typo.
void main() {
  Future<void> openLedger(WidgetTester tester) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    addTearDown(tester.view.reset);

    mockServiceChannels(granted: true);

    await tester.pumpWidget(
      mockScope(
        child: MaterialApp(
          theme: PikirTheme.light,
          initialRoute: Routes.ledger,
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

  /// Opens the sheet for the first debt in the seeded ledger.
  Future<void> openSheetForFirstDebt(WidgetTester tester) async {
    final button = find.widgetWithText(PikirButton, 'Atur catatan ini').first;
    await scrollTo(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  group('Menandai lunas', () {
    test('takes the debt out of both totals', () {
      final debts = Seed.debts();
      final before = DebtSummary.of(debts, income: 4000000);

      final settled = [
        debts.first.settled(at: DateTime(2026, 8, 15)),
        ...debts.skip(1),
      ];
      final after = DebtSummary.of(settled, income: 4000000);

      // The ratio asks whether this month is survivable, so a debt that is
      // finished has to stop counting against it. Leaving it in would keep
      // telling the user they are more burdened than they are.
      expect(after.monthlyInstalmentTotal, lessThan(before.monthlyInstalmentTotal));
      expect(after.totalActiveDebt, lessThan(before.totalActiveDebt));
      expect(after.ratio, lessThan(before.ratio));
    });

    test('is reversible', () async {
      final store = MockStore();
      final ledger = MockLedgerRepository(store);
      final id = (await ledger.debts()).first.id;

      await ledger.setDebtSettled(id, settled: true);
      expect((await ledger.debts()).firstWhere((d) => d.id == id).isSettled,
          isTrue);

      // Without this, a mis-tap could only be undone by deleting the record,
      // which loses more than the mistake did.
      await ledger.setDebtSettled(id, settled: false);
      expect((await ledger.debts()).firstWhere((d) => d.id == id).isSettled,
          isFalse);
    });

    testWidgets('marks the card with a word, not just a colour', (
      tester,
    ) async {
      await openLedger(tester);
      await openSheetForFirstDebt(tester);

      await tester.tap(find.text('Tandai lunas'));
      await tester.pumpAndSettle();

      // CLAUDE.md section 6 rule 1.
      expect(find.text('Lunas'), findsOneWidget);
      expect(
        find.text('Tidak lagi dihitung di beban bulananmu'),
        findsOneWidget,
      );
    });

    testWidgets('offers no celebration', (tester) async {
      await openLedger(tester);
      await openSheetForFirstDebt(tester);
      await tester.tap(find.text('Tandai lunas'));
      await tester.pumpAndSettle();

      // CLAUDE.md section 6 rule 5. Paying off a debt is the user's own doing;
      // the app taking a bow over it would be taking the credit.
      for (final banned in const ['Selamat', 'Hebat', 'Keren', 'poin']) {
        expect(find.textContaining(banned), findsNothing);
      }
    });
  });

  group('Menghapus catatan', () {
    testWidgets('asks for a deliberate hold, not a tap', (tester) async {
      await openLedger(tester);
      await openSheetForFirstDebt(tester);

      await tester.tap(find.text('Hapus catatan'));
      await tester.pumpAndSettle();

      // CLAUDE.md section 6 rule 4: friction lives in the gesture. A single
      // tap must not be able to destroy a record that cannot be recovered.
      expect(find.byType(HoldToConfirmButton), findsOneWidget);
      expect(
        find.textContaining('tidak bisa dikembalikan'),
        findsOneWidget,
      );
    });

    testWidgets('keeps backing out the same size as going through', (
      tester,
    ) async {
      await openLedger(tester);
      await openSheetForFirstDebt(tester);
      await tester.tap(find.text('Hapus catatan'));
      await tester.pumpAndSettle();

      // CLAUDE.md section 6 rule 3. Measured on the pressable surfaces, not
      // on the widgets: HoldToConfirmButton is taller overall only because it
      // carries a "tekan dan tahan 5 detik" caption underneath, which is
      // instruction rather than button.
      final cancel = find.widgetWithText(PikirButton, 'Batal');
      final holdSurface = find
          .descendant(
            of: find.byType(HoldToConfirmButton),
            matching: find.byType(GestureDetector),
          )
          .first;

      expect(tester.getSize(cancel).height, PikirSpacing.buttonHeight);
      expect(tester.getSize(holdSurface).height, PikirSpacing.buttonHeight);
      expect(
        tester.getSize(holdSurface).width,
        tester.getSize(cancel).width,
      );
    });

    testWidgets('leaves the ledger untouched until the hold completes', (
      tester,
    ) async {
      await openLedger(tester);
      final before = find
          .widgetWithText(PikirButton, 'Atur catatan ini')
          .evaluate()
          .length;

      await openSheetForFirstDebt(tester);
      await tester.tap(find.text('Hapus catatan'));
      await tester.pumpAndSettle();

      // Pressed, but released early.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(HoldToConfirmButton)),
      );
      await tester.pump(const Duration(seconds: 2));
      await gesture.up();
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(PikirButton, 'Batal'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(PikirButton, 'Atur catatan ini').evaluate().length,
        before,
      );
    });
  });
}
