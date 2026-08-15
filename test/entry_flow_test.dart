import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_overrides.dart';
import 'package:pikir/core/router/app_router.dart';
import 'package:pikir/core/router/routes.dart';
import 'package:pikir/core/theme/app_theme.dart';
import 'package:pikir/core/widgets/widgets.dart';
import 'package:pikir/features/home/screens/beranda_screen.dart';
import 'package:pikir/features/onboarding/screens/anonim_screen.dart';
import 'package:pikir/features/onboarding/screens/splash_screen.dart';
import 'package:pikir/features/settings/screens/izin_screen.dart';

/// The way into the app: splash, then the anonymous entry, then the dashboard.
///
/// Worth its own test because it is the one path every user and every
/// screen recording takes, and because it is where the app makes its first
/// promise — that there is no account to create.
void main() {
  Future<void> launch(WidgetTester tester, {bool granted = false}) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    addTearDown(tester.view.reset);

    mockServiceChannels(granted: granted);

    await tester.pumpWidget(
      mockScope(
        child: MaterialApp(
          key: ValueKey(granted),
          theme: PikirTheme.light,
          initialRoute: Routes.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
          onUnknownRoute: AppRouter.onUnknownRoute,
        ),
      ),
    );
    await tester.pump();
  }

  /// Waits out the splash dwell and lets the replacement settle.
  Future<void> pastSplash(WidgetTester tester) async {
    await tester.pump(SplashScreen.dwell);
    await tester.pumpAndSettle();
  }

  testWidgets('opens on the splash screen, not a developer tool', (
    tester,
  ) async {
    await launch(tester);

    // The app used to land on the screen map, which is scaffolding. What a
    // user meets first is the mark and the tagline.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Pikir dulu, baru pinjam.'), findsOneWidget);
    expect(find.text('Buka peta layar'), findsNothing);
  });

  testWidgets('moves on by itself', (tester) async {
    await launch(tester);
    await pastSplash(tester);

    // No tap needed and none offered: a splash the user has to dismiss is a
    // door, not an opening.
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(AnonimScreen), findsOneWidget);
  });

  testWidgets('asks for no account, no name, and no password', (tester) async {
    await launch(tester);
    await pastSplash(tester);

    // CLAUDE.md section 2 rule 2. This screen sits exactly where a sign-in
    // screen would, which is why it is the one most at risk of growing one.
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.byType(CircleAvatar), findsNothing);
    for (final banned in const ['Masuk dengan', 'Daftar', 'Kata sandi',
        'Email', 'Nomor HP', 'Lanjut dengan']) {
      expect(
        find.textContaining(banned),
        findsNothing,
        reason: 'sign-in wording "$banned" appeared on the entry screen',
      );
    }
  });

  testWidgets('lands on Beranda once every permission is on', (tester) async {
    await launch(tester, granted: true);
    await pastSplash(tester);

    await tester.tap(find.widgetWithText(PikirButton, 'Mulai pakai PIKIR'));
    await tester.pumpAndSettle();

    expect(find.byType(BerandaScreen), findsOneWidget);
    expect(find.byType(IzinScreen), findsNothing);
  });

  testWidgets('stops at the permission page while something is off', (
    tester,
  ) async {
    await launch(tester);
    await pastSplash(tester);

    await tester.tap(find.widgetWithText(PikirButton, 'Mulai pakai PIKIR'));
    await tester.pumpAndSettle();

    expect(find.byType(IzinScreen), findsOneWidget);

    // Declining lands on the dashboard rather than back at the entry screen:
    // the permissions are optional, so refusing them cannot bar the door.
    await tester.tap(find.widgetWithText(PikirButton, 'Nanti saja'));
    await tester.pumpAndSettle();

    expect(find.byType(BerandaScreen), findsOneWidget);
    expect(find.byType(AnonimScreen), findsNothing);
  });

  testWidgets('leaves nothing to go back to from Beranda', (tester) async {
    await launch(tester, granted: true);
    await pastSplash(tester);

    await tester.tap(find.widgetWithText(PikirButton, 'Mulai pakai PIKIR'));
    await tester.pumpAndSettle();

    // Splash and the entry screen are replaced rather than stacked, so the
    // system back button leaves the app instead of walking back through the
    // opening sequence.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });
}
