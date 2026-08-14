import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pikir/core/router/app_router.dart';
import 'package:pikir/core/router/routes.dart';
import 'package:pikir/core/theme/app_theme.dart';
import 'package:pikir/core/widgets/widgets.dart';

/// The mitigation wizard, driven end to end.
///
/// The three-way branch is the product's central argument, and the rule that
/// keeps it honest is negative: a loan product must not appear on two of the
/// three paths. Negative rules rot quietly, so they are asserted by walking
/// the real flow rather than by inspecting the data layer alone.
void main() {
  /// The real device size by default.
  ///
  /// A few tests pass a taller [height] on purpose. Those assert the
  /// composition and ordering of a list, not its layout, and a list of options
  /// is inherently scrollable: section 9 governs the primary action, which is
  /// pinned on every screen here. Rendering all of it at once is the only way
  /// to read the order the user would encounter while scrolling.
  void useDevice(WidgetTester tester, {double height = 852}) {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = Size(393 * 3, height * 3);
    addTearDown(tester.view.reset);
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    for (var i = 0; i < 7; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  Future<void> openWizard(WidgetTester tester, {double height = 852}) async {
    useDevice(tester, height: height);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: PikirTheme.light,
          initialRoute: Routes.mitigasiKebutuhan,
          onGenerateRoute: AppRouter.onGenerateRoute,
          onUnknownRoute: AppRouter.onUnknownRoute,
        ),
      ),
    );
    await settle(tester);
  }

  /// Answers step one and two, then step three when the branch asks for it.
  Future<void> answer(
    WidgetTester tester, {
    required String topic,
    required String amount,
    String? profit,
  }) async {
    // The topic list is longer than the screen. scrollUntilVisible alone
    // leaves the last card straddling the bottom navigation, where a tap
    // lands on the FAB instead, so ensureVisible finishes the job by bringing
    // it fully inside its viewport.
    await tester.scrollUntilVisible(
      find.text(topic),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text(topic));
    await settle(tester);

    await tester.tap(find.text(topic));
    await settle(tester);

    await tester.enterText(find.byType(TextField), amount);
    await tester.pump();
    await tester.tap(find.widgetWithText(PikirButton, 'Lanjut'));
    await settle(tester);

    if (profit != null) {
      await tester.enterText(find.byType(TextField), profit);
      await tester.pump();
      await tester.tap(find.widgetWithText(PikirButton, 'Lihat pilihanku'));
      await settle(tester);
    }
  }

  group('step count is honest', () {
    testWidgets('two steps on a non-productive branch', (tester) async {
      await openWizard(tester);
      await tester.tap(find.text('Kesehatan'));
      await settle(tester);

      // Telling somebody there are three steps when there are two is a small
      // dishonesty this app cannot afford.
      expect(find.text('Langkah 2 dari 2'), findsOneWidget);
    });

    testWidgets('three steps on the productive branch', (tester) async {
      await openWizard(tester);
      await tester.tap(find.text('Modal atau alat kerja'));
      await settle(tester);

      expect(find.text('Langkah 2 dari 3'), findsOneWidget);
    });
  });

  group('branch isolation, walked end to end', () {
    testWidgets('a want reaches opportunity cost and no product at all', (
      tester,
    ) async {
      await openWizard(tester);
      await answer(
        tester,
        topic: 'Barang atau keinginan',
        amount: '1250000',
      );

      expect(find.text('bunga yang kamu bayar kalau nyicil'), findsOneWidget);

      // No financing, and no social assistance either: sending somebody to
      // the Dinas Sosial because they want a phone would be insulting.
      for (final banned in [
        'Koperasi simpan pinjam terdaftar',
        'KUR Mikro bank himbara',
        'Gadai barang di Pegadaian',
        'BPJS Kesehatan PBI',
        'Program Sembako',
      ]) {
        expect(
          find.text(banned),
          findsNothing,
          reason: '"$banned" must not appear on the consumptive path.',
        );
      }
    });

    testWidgets('an urgent need reaches assistance and never a loan', (
      tester,
    ) async {
      await openWizard(tester);
      await answer(tester, topic: 'Kesehatan', amount: '1800000');

      expect(find.text('Ini hakmu, bukan pinjaman'), findsOneWidget);
      expect(find.text('BPJS Kesehatan PBI'), findsOneWidget);

      // CLAUDE.md section 6 rule 7, the hard one.
      for (final banned in [
        'Koperasi simpan pinjam terdaftar',
        'KUR Mikro bank himbara',
        'Gadai barang di Pegadaian',
      ]) {
        expect(
          find.text(banned),
          findsNothing,
          reason: 'A loan product may never appear on the urgent-need path.',
        );
      }
    });

    testWidgets('a productive need is tested before it is financed', (
      tester,
    ) async {
      await openWizard(tester);
      await answer(
        tester,
        topic: 'Modal atau alat kerja',
        amount: '1800000',
        profit: '2400000',
      );

      // Feasibility first. Whether this pays for itself is a different
      // question from who will lend the money.
      expect(find.textContaining('Balik modal sekitar 23 hari'), findsOneWidget);
      expect(find.text('Layak'), findsOneWidget);
      expect(find.text('Koperasi simpan pinjam terdaftar'), findsNothing);

      await tester.tap(
        find.widgetWithText(PikirButton, 'Lihat pilihan pembiayaan'),
      );
      await settle(tester);

      expect(find.text('Koperasi simpan pinjam terdaftar'), findsOneWidget);
    });
  });

  group('financing list', () {
    Future<void> openFinancing(WidgetTester tester) async {
      // Tall enough for all three route cards to be built at once.
      await openWizard(tester, height: 2200);
      await answer(
        tester,
        topic: 'Modal atau alat kerja',
        amount: '1800000',
        profit: '2400000',
      );
      await tester.tap(
        find.widgetWithText(PikirButton, 'Lihat pilihan pembiayaan'),
      );
      await settle(tester);
    }

    testWidgets('defaults to fastest first and says so', (tester) async {
      await openFinancing(tester);

      expect(
        find.text('Diurutkan dari yang paling cepat cair'),
        findsOneWidget,
      );

      // Pegadaian pays out today; KUR is cheapest but slowest. Fastest wins
      // the default, and the screen states the ordering rather than leaving
      // the user to infer it.
      final names = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList();
      final pegadaian = names.indexOf('Gadai barang di Pegadaian');
      final kur = names.indexOf('KUR Mikro bank himbara');
      expect(pegadaian, greaterThanOrEqualTo(0));
      expect(kur, greaterThan(pegadaian));
    });

    testWidgets('cost ordering is a switch the user throws', (tester) async {
      await openFinancing(tester);

      await tester.tap(find.text('Biaya terkecil'));
      await settle(tester);

      expect(find.text('Diurutkan dari biaya terkecil'), findsOneWidget);

      final names = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList();
      final kur = names.indexOf('KUR Mikro bank himbara');
      final pegadaian = names.indexOf('Gadai barang di Pegadaian');
      expect(kur, greaterThanOrEqualTo(0));
      expect(pegadaian, greaterThan(kur));
    });

    testWidgets('every card carries Tanya lebih lanjut', (tester) async {
      await openFinancing(tester);

      // SCREENS.md is emphatic that this button is on every single card. A
      // route the user cannot ask about is a route they must accept on trust.
      expect(
        find.widgetWithText(PikirButton, 'Tanya lebih lanjut'),
        findsNWidgets(3),
      );
    });

    testWidgets('no card is promoted above the others', (tester) async {
      await openFinancing(tester);

      for (final banned in [
        'Rekomendasi',
        'rekomendasi kami',
        'Terpopuler',
        'Paling laris',
        'Disarankan',
      ]) {
        expect(
          find.textContaining(banned),
          findsNothing,
          reason: 'Promoting one option turns routing into selling.',
        );
      }
    });

    testWidgets('asking about a route hands its numbers to the chat', (
      tester,
    ) async {
      await openFinancing(tester);

      await tester.tap(
        find.widgetWithText(PikirButton, 'Tanya lebih lanjut').first,
      );
      await settle(tester);

      // The context is a visible card, not a hidden prompt: the user can see
      // exactly what the assistant was told about them.
      expect(find.text('Konteks dari layar sebelumnya'), findsOneWidget);
      expect(find.textContaining('Gadai barang di Pegadaian'), findsWidgets);
    });
  });
}
