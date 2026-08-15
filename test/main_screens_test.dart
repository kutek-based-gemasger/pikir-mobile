import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_overrides.dart';
import 'package:pikir/core/router/app_router.dart';
import 'package:pikir/core/router/routes.dart';
import 'package:pikir/core/theme/app_theme.dart';
import 'package:pikir/core/widgets/widgets.dart';

/// The screens that appear most often in the submission recording.
///
/// These assert content, not just that the widget tree builds: a screen that
/// renders an empty card is still a screen that failed. Several of the checks
/// exist because the Stitch reference export contradicts CLAUDE.md, and
/// copying it faithfully would have broken a hard rule.
void main() {
  void useTargetDevice(WidgetTester tester) {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    addTearDown(tester.view.reset);
  }

  /// Scrolls until [finder] is on screen.
  ///
  /// A ListView does not build its off-screen children, so content further
  /// down is genuinely absent from the tree rather than merely invisible.
  /// Scrolling to it also checks the thing worth checking: that it is
  /// reachable at all.
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester, String route) async {
    useTargetDevice(tester);
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

  group('Beranda', () {
    testWidgets('greets without a name and shows no avatar', (tester) async {
      await open(tester, Routes.beranda);

      // CLAUDE.md section 2 rule 2. The Stitch reference draws an avatar and
      // "Halo, Bagus"; the app has no accounts, so it can do neither.
      expect(find.text('Halo'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsNothing);
      expect(find.textContaining('Halo,'), findsNothing);
    });

    testWidgets('shows the debt ratio with a worded status', (tester) async {
      await open(tester, Routes.beranda);

      expect(find.text('Beban utangmu bulan ini'), findsOneWidget);
      expect(find.text('18%'), findsOneWidget);
      // Colour is never the only carrier: the state is spelled out.
      expect(find.text('Aman'), findsWidgets);
      expect(find.text('Batas aman 30%'), findsOneWidget);
      expect(find.textContaining('Rp720.000'), findsOneWidget);
    });

    testWidgets('reaches every feature without waiting for a trigger', (
      tester,
    ) async {
      await open(tester, Routes.beranda);

      expect(find.text('Kalkulator Mitigasi'), findsOneWidget);
      expect(find.text('Ledger Utang'), findsOneWidget);
      expect(find.text('Tagihan terdeteksi'), findsOneWidget);
      // Counts come from the seeded data, not from a literal in the layout.
      expect(find.text('3 catatan aktif'), findsOneWidget);
    });

    testWidgets('settings sit behind a gear, not a tab', (tester) async {
      await open(tester, Routes.beranda);

      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(find.text('Pengaturan'), findsNothing);
      expect(find.text('Profil'), findsNothing);
    });
  });

  group('bottom navigation', () {
    testWidgets('uses the labels from CLAUDE.md, not the Stitch export', (
      tester,
    ) async {
      await open(tester, Routes.beranda);

      // The export labels these Solusi, Darurat, and Catatan. Section 7 is
      // explicit about the real four, and the bar must be identical
      // everywhere.
      for (final label in ['Beranda', 'Mitigasi', 'Dana Darurat', 'Ledger']) {
        expect(find.text(label), findsWidgets, reason: '$label is missing.');
      }
      expect(find.text('Tanya PIKIR'), findsWidgets);

      expect(find.text('Solusi'), findsNothing);
      expect(find.text('Catatan'), findsNothing);
      expect(find.text('Profil'), findsNothing);
    });
  });

  group('Ledger', () {
    testWidgets('totals the seeded debts', (tester) async {
      await open(tester, Routes.ledger);

      expect(find.text('Total utang aktif'), findsOneWidget);
      expect(find.text('Rp3.150.000'), findsOneWidget);
      expect(find.text('HP baru'), findsOneWidget);
      expect(find.text('Modal dagangan'), findsOneWidget);
      expect(find.text('Servis motor'), findsOneWidget);
    });

    testWidgets('the decision history keeps score of nothing', (tester) async {
      await open(tester, Routes.ledger);
      await tester.tap(find.text('Riwayat keputusan'));
      await tester.pumpAndSettle();

      expect(find.text('Ditunda'), findsOneWidget);
      expect(find.text('Dilanjutkan'), findsOneWidget);
      expect(find.text('kali ditahan'), findsOneWidget);

      // Section 6 rule 5: no streaks, points, badges, or congratulation.
      for (final banned in ['Streak', 'Poin', 'Level', 'Selamat', 'Hebat']) {
        expect(
          find.textContaining(banned),
          findsNothing,
          reason: '"$banned" is a reward mechanic this app argues against.',
        );
      }
    });
  });

  group('Dana Darurat', () {
    testWidgets('shows tiers with the third marked optional', (tester) async {
      await open(tester, Routes.danaDarurat);

      expect(find.text('Rp450.000'), findsOneWidget);
      expect(find.text('Rp1.000.000'), findsOneWidget);

      await scrollTo(tester, find.text('Rp7.200.000'));
      expect(find.text('Rp7.200.000'), findsOneWidget);
      expect(find.text('Opsional'), findsWidgets);
      // The reassurance that not reaching tier three is fine.
      expect(
        find.textContaining('Tidak apa-apa kalau belum sampai sini'),
        findsOneWidget,
      );
    });

    testWidgets('the primary action stays above the fold', (tester) async {
      await open(tester, Routes.danaDarurat);

      // CLAUDE.md section 9. The tier list scrolls past the bottom of the
      // screen, so this button is pinned rather than parked at the end of it.
      final button = find.widgetWithText(PikirButton, 'Catat setoran');
      expect(button, findsOneWidget);

      final position = tester.getRect(button);
      expect(
        position.bottom,
        lessThanOrEqualTo(852.0),
        reason: 'Catat setoran must be visible without scrolling.',
      );
    });

    testWidgets('no comparison with other users anywhere', (tester) async {
      await open(tester, Routes.danaDarurat);

      for (final banned in ['pengguna lain', 'peringkat', 'Streak', 'poin']) {
        expect(find.textContaining(banned), findsNothing);
      }
    });
  });

  group('Tanya PIKIR', () {
    testWidgets('opens on suggestions with the retention notice', (
      tester,
    ) async {
      await open(tester, Routes.chat);

      expect(
        find.textContaining('terhapus otomatis setelah 24 jam'),
        findsOneWidget,
      );
      expect(
        find.text('Bunga 0,4% per hari itu berapa setahun?'),
        findsOneWidget,
      );
      // The standing disclaimer sits above the input, not buried in settings.
      expect(find.textContaining('OJK 157'), findsOneWidget);
    });

    testWidgets('an answer arrives with its sources attached', (tester) async {
      await open(tester, Routes.chat);

      await tester.tap(find.text('Bunga 0,4% per hari itu berapa setahun?'));
      await tester.pumpAndSettle();

      expect(find.textContaining('146% per tahun'), findsOneWidget);
      // Every factual claim carries a citation.
      expect(find.text('OJK - POJK Pinjaman Daring'), findsOneWidget);
      expect(find.text('AFPI - Pedoman Bunga'), findsOneWidget);
      // And the working is shown, not just the conclusion.
      expect(find.text('0,4% x 365 hari = 146%'), findsOneWidget);
    });

    testWidgets('an off-topic question is refused like a normal answer', (
      tester,
    ) async {
      await open(tester, Routes.chat);

      await tester.enterText(
        find.byType(TextField),
        'Rekomendasi saham buat cuan cepat dong',
      );
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();

      expect(find.textContaining('hanya bisa bantu soal utang'), findsOneWidget);
    });
  });

  group('Pengaturan', () {
    testWidgets('has no account section', (tester) async {
      await open(tester, Routes.pengaturan);

      expect(find.text('Kondisi keuanganku'), findsOneWidget);
      expect(find.text('Perlindungan'), findsOneWidget);
      expect(find.text('Privasi'), findsOneWidget);

      for (final banned in ['Akun', 'Keluar', 'Profil', 'Email']) {
        expect(
          find.textContaining(banned),
          findsNothing,
          reason: 'The app is anonymous; "$banned" implies an account.',
        );
      }
    });

    testWidgets('deleting everything is offered plainly, not buried', (
      tester,
    ) async {
      await open(tester, Routes.pengaturan);

      await scrollTo(tester, find.text('Hapus semua data di HP ini'));
      expect(find.text('Hapus semua data di HP ini'), findsOneWidget);

      await scrollTo(tester, find.text('Mode demo'));
      expect(find.text('Mode demo'), findsOneWidget);
    });
  });

  group('Privasi', () {
    testWidgets('states both what is kept and what never is', (tester) async {
      await open(tester, Routes.privasi);

      expect(find.text('Tersimpan di HP-mu'), findsOneWidget);

      // The scan log is listed as kept, not as never stored. PIKIR does keep a
      // flagged excerpt and the original of a message it dismissed, because
      // the replacement has to be able to hand it back. Claiming otherwise
      // here would be the app lying to the user on its own privacy page.
      expect(
        find.textContaining('Cuplikan notifikasi yang ditandai'),
        findsOneWidget,
      );

      await scrollTo(tester, find.text('Tidak pernah kami simpan'));
      expect(find.text('Nomor rekening'), findsOneWidget);
      expect(
        find.textContaining('Isi notifikasi yang aman'),
        findsOneWidget,
      );

      await scrollTo(
        tester,
        find.textContaining('Notifikasi diperiksa tanpa internet'),
      );
      expect(
        find.textContaining('Notifikasi diperiksa tanpa internet'),
        findsOneWidget,
      );
    });
  });
}
