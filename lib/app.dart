import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/platform/screen_channel.dart';
import 'core/router/app_router.dart';
import 'core/router/routes.dart';
import 'core/theme/app_theme.dart';
import 'features/intervention/intervention_state.dart';

/// The root of the PIKIR app.
class PikirApp extends ConsumerStatefulWidget {
  const PikirApp({super.key});

  @override
  ConsumerState<PikirApp> createState() => _PikirAppState();
}

class _PikirAppState extends ConsumerState<PikirApp>
    with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkTrigger());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The screen watcher brings PIKIR to the front, which resumes an app that
    // is usually already running rather than launching a new one. Checking on
    // resume is therefore the normal path, not the exception.
    if (state == AppLifecycleState.resumed) _checkTrigger();
  }

  Future<void> _checkTrigger() async {
    final trigger = await ScreenChannel.consumePendingTrigger();
    if (trigger == null || !mounted) return;

    final controller = ref.read(interventionControllerProvider.notifier);
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    if (trigger.isCheckout) {
      // The amount read off the checkout screen when one was found, and the
      // seeded figure when it was not, so the reflection screen always has a
      // real number to reason about rather than a blank.
      controller.startCheckout(amount: trigger.amount ?? 1250000);
      await navigator.pushNamed(Routes.intervensiBlanket);
    } else {
      controller.startLoanApp();
      await navigator.pushNamed(Routes.intervensiTujuan);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIKIR',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,

      // One theme, always light. No darkTheme is supplied on purpose, so a
      // device in dark mode still gets the palette the contrast ratios were
      // checked against.
      theme: PikirTheme.light,
      themeMode: ThemeMode.light,

      initialRoute: Routes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: AppRouter.onUnknownRoute,

      // System text scaling is deliberately left alone. The users this is
      // built for often run their phones at a larger text size, and clamping
      // it would trade their legibility for our layout's convenience.
    );
  }
}
