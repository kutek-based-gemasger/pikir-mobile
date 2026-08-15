import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_overrides.dart';
import 'package:pikir/core/router/app_router.dart';
import 'package:pikir/core/router/routes.dart';
import 'package:pikir/core/theme/app_theme.dart';
import 'package:pikir/core/theme/tokens.dart';
import 'package:pikir/core/widgets/widgets.dart';
import 'package:pikir/features/settings/izin_state.dart';

/// The permission centre.
///
/// The interesting state is the one before anything is granted: this is the
/// screen a user meets on first launch, and the one place the app could most
/// easily start pressuring them for access it cannot obtain by itself.
void main() {
  /// The three Android calls "special access": no dialog exists for them, so
  /// the only route is a settings screen. Listed on every device.
  final specialAccess = PikirPermission.values
      .where((permission) => !permission.usesSystemDialog)
      .toList();

  Future<void> open(
    WidgetTester tester,
    String route, {
    Object? arguments,
    bool granted = false,
    bool postNotificationApplicable = false,
  }) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    addTearDown(tester.view.reset);

    mockServiceChannels(
      granted: granted,
      postNotificationApplicable: postNotificationApplicable,
    );

    await tester.pumpWidget(
      mockScope(
        child: MaterialApp(
          key: ValueKey(
            '$route$arguments$granted$postNotificationApplicable',
          ),
          theme: PikirTheme.light,
          // Built by hand rather than through initialRoute, for two reasons:
          // a path-shaped initial route makes MaterialApp build every parent
          // segment underneath as well, and initialRoute carries no arguments
          // of its own. This puts the screen under test on screen alone, with
          // the launch-prompt argument attached.
          onGenerateInitialRoutes: (_) => [
            AppRouter.onGenerateRoute(
              RouteSettings(name: route, arguments: arguments),
            )!,
          ],
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

  group('Izin perlindungan', () {
    testWidgets('lists all three permissions', (tester) async {
      await open(tester, Routes.pengaturanIzin);

      for (final permission in specialAccess) {
        await scrollTo(tester, find.text(permission.title));
        expect(
          find.text(permission.title),
          findsOneWidget,
          reason: 'permission ${permission.name} is missing from the page',
        );
      }

      // Not listed below Android 13, where the OS grants it at install time.
      // A row nobody can change is a row that only wastes their attention.
      expect(find.text(PikirPermission.postNotification.title), findsNothing);
    });

    testWidgets('states the limit of every permission it asks for', (
      tester,
    ) async {
      await open(tester, Routes.pengaturanIzin);

      // A permission screen that only says what it wants is asking to be
      // trusted blindly. Each card says where the access stops as well.
      for (final permission in specialAccess) {
        await scrollTo(tester, find.text(permission.limit));
        expect(find.text(permission.limit), findsOneWidget);
      }
    });

    testWidgets('never carries status by colour alone', (tester) async {
      await open(tester, Routes.pengaturanIzin);

      // CLAUDE.md section 6 rule 1: colour plus icon plus words, always. Read
      // per card rather than by counting chips on the page, because a ListView
      // only builds what is on screen.
      for (final permission in specialAccess) {
        await scrollTo(tester, find.text(permission.title));
        final card = find.ancestor(
          of: find.text(permission.title),
          matching: find.byType(PikirCard),
        );
        expect(
          find.descendant(of: card, matching: find.text('Belum aktif')),
          findsOneWidget,
          reason: '${permission.name} shows its state without words',
        );
      }
    });

    testWidgets('says what stops working while a permission is off', (
      tester,
    ) async {
      await open(tester, Routes.pengaturanIzin);

      await scrollTo(tester, find.text(PikirPermission.screenAccess.missing));
      expect(find.text(PikirPermission.screenAccess.missing), findsOneWidget);
    });

    testWidgets('uses no urgency, scarcity, or countdown copy', (tester) async {
      await open(tester, Routes.pengaturanIzin);

      // CLAUDE.md section 6 rule 5. This screen wants something from the user,
      // which makes it the likeliest place for pressure to creep in.
      for (final banned in const [
        'segera',
        'sekarang juga',
        'jangan sampai',
        'sisa ',
        'terakhir',
        'bahaya',
      ]) {
        expect(
          find.textContaining(banned),
          findsNothing,
          reason: 'pressure wording "$banned" appeared on the permission page',
        );
      }
    });

    testWidgets('offers no second dismissal when opened from Settings', (
      tester,
    ) async {
      await open(tester, Routes.pengaturanIzin);

      // Reached from Settings there is a back arrow already, so a "Nanti saja"
      // button would only be noise.
      expect(find.text('Nanti saja'), findsNothing);
    });

    testWidgets('drops the per-permission button once granted', (tester) async {
      await open(tester, Routes.pengaturanIzin, granted: true);

      expect(find.text('Buka pengaturan'), findsNothing);
      expect(find.textContaining('Semua izin sudah aktif'), findsOneWidget);
    });
  });

  group('Izin mengirim notifikasi', () {
    testWidgets('appears on Android 13 and above', (tester) async {
      await open(
        tester,
        Routes.pengaturanIzin,
        postNotificationApplicable: true,
      );

      // Counted before scrolling: the intro card is at the top of a ListView
      // and stops being built once it leaves the screen.
      expect(find.textContaining('dari 4 izin belum aktif'), findsOneWidget);

      await scrollTo(
        tester,
        find.text(PikirPermission.postNotification.title),
      );
      expect(
        find.text(PikirPermission.postNotification.title),
        findsOneWidget,
      );
    });

    testWidgets('says "Izinkan", not "Buka pengaturan"', (tester) async {
      await open(
        tester,
        Routes.pengaturanIzin,
        postNotificationApplicable: true,
      );

      // This is the one permission Android will ask for itself, so the button
      // has to promise the dialog it actually shows rather than a settings
      // screen the user is never taken to.
      final card = find.ancestor(
        of: find.text(PikirPermission.postNotification.title),
        matching: find.byType(PikirCard),
      );
      await scrollTo(tester, find.descendant(
        of: card,
        matching: find.text('Izinkan'),
      ));
      expect(
        find.descendant(of: card, matching: find.text('Izinkan')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text('Buka pengaturan')),
        findsNothing,
      );
    });

    testWidgets('names the silent failure it prevents', (tester) async {
      await open(
        tester,
        Routes.pengaturanIzin,
        postNotificationApplicable: true,
      );

      // The failure this permission causes is invisible: the scanner keeps
      // flagging and holding messages, and the user is simply never told.
      await scrollTo(
        tester,
        find.text(PikirPermission.postNotification.missing),
      );
      expect(
        find.text(PikirPermission.postNotification.missing),
        findsOneWidget,
      );
    });
  });

  group('Sebagai pop up saat aplikasi dibuka', () {
    testWidgets('carries a full-size way to decline', (tester) async {
      await open(
        tester,
        Routes.pengaturanIzin,
        arguments: kIzinLaunchPrompt,
      );

      // CLAUDE.md section 6 rule 3: declining is never smaller, fainter, or
      // lighter than proceeding. Every PikirButton shares one height and one
      // text style, so what matters is that the option is a real button at
      // full size rather than a link tucked underneath.
      final decline = find.widgetWithText(PikirButton, 'Nanti saja');
      expect(decline, findsOneWidget);
      expect(tester.getSize(decline).height, PikirSpacing.buttonHeight);
    });

    testWidgets('hides the back arrow so the button is the way out', (
      tester,
    ) async {
      await open(
        tester,
        Routes.pengaturanIzin,
        arguments: kIzinLaunchPrompt,
      );

      expect(find.byType(BackButton), findsNothing);
      expect(find.text('Nanti saja'), findsOneWidget);
    });
  });
}
