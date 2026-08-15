import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pikir/core/router/app_router.dart';
import 'package:pikir/core/router/routes.dart';
import 'package:pikir/core/theme/app_theme.dart';
import 'package:pikir/core/widgets/widgets.dart';

import 'helpers/test_overrides.dart';

/// Recording a debt by hand.
///
/// A form is where pre-filled defaults and demoted exit buttons creep in most
/// easily, so the fair-pattern rules are asserted here rather than trusted.
void main() {
  Future<void> open(WidgetTester tester, String route) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    addTearDown(tester.view.reset);

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
    await tester.pumpAndSettle();
  }

  testWidgets('every field starts empty and no category is chosen', (
    tester,
  ) async {
    await open(tester, Routes.ledgerTambah);

    // Section 6 rule 2. A form that arrives with a category already picked is
    // the app deciding what kind of borrower somebody is before they spoke.
    for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(field.controller?.text ?? '', isEmpty);
    }
    expect(find.text('Belum dipilih.'), findsOneWidget);
  });

  testWidgets('Simpan waits for the two fields it actually needs', (
    tester,
  ) async {
    await open(tester, Routes.ledgerTambah);

    final save = find.widgetWithText(PikirButton, 'Simpan');
    expect(tester.widget<PikirButton>(save).onPressed, isNull);

    // Amount alone is not enough: a debt with no stated purpose is a row the
    // user cannot recognise later.
    await tester.enterText(find.byType(TextField).first, '900000');
    await tester.pump();
    expect(tester.widget<PikirButton>(save).onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(2), 'bayar kontrakan');
    await tester.pump();
    expect(tester.widget<PikirButton>(save).onPressed, isNotNull);
  });

  testWidgets('Batal is the same size as Simpan', (tester) async {
    await open(tester, Routes.ledgerTambah);

    // SCREENS.md draws Batal as a bare text link. Section 6 rule 3 forbids
    // shrinking the option that exits, so it is a full button here.
    final cancel = find.widgetWithText(PikirButton, 'Batal');
    final save = find.widgetWithText(PikirButton, 'Simpan');

    expect(tester.getSize(cancel), tester.getSize(save));
    expect(tester.widget<PikirButton>(cancel).onPressed, isNotNull);
  });

  testWidgets('the instalment is optional and says why it matters', (
    tester,
  ) async {
    await open(tester, Routes.ledgerTambah);

    // Leaving it blank keeps the debt out of the ratio on Beranda, which is
    // the number the whole app is organised around. The screen says so rather
    // than under-reporting it silently.
    expect(
      find.textContaining('ikut dihitung ke beban utang bulananmu'),
      findsOneWidget,
    );
  });

  testWidgets('a saved debt reaches the ledger', (tester) async {
    await open(tester, Routes.ledger);
    expect(find.text('Rp3.150.000'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '500000');
    await tester.enterText(find.byType(TextField).at(2), 'bayar kontrakan');
    await tester.pump();

    await tester.tap(find.widgetWithText(PikirButton, 'Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('bayar kontrakan'), findsOneWidget);
    // Blank instalment reads as unknown, never as "Rp0 per bulan", which
    // would look like a debt that costs nothing.
    expect(find.text('Cicilan belum diisi'), findsOneWidget);
    expect(find.text('Rp3.650.000'), findsOneWidget);
  });
}
