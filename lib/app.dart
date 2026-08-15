import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/platform/screen_channel.dart';
import 'core/router/app_router.dart';
import 'core/router/routes.dart';
import 'core/theme/app_theme.dart';
import 'features/intervention/intervention_state.dart';
import 'features/settings/izin_state.dart';

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
    // In that order, and awaited: an interception must never end up behind the
    // permission page. The user standing in front of a loan app came here for
    // the interruption, not for a settings screen.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final intercepted = await _checkTrigger();
      if (!intercepted) await _offerMissingPermissions();
    });
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

  /// Returns whether an interception was opened.
  Future<bool> _checkTrigger() async {
    final trigger = await ScreenChannel.consumePendingTrigger();
    if (trigger == null || !mounted) return false;

    final controller = ref.read(interventionControllerProvider.notifier);
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return false;

    if (trigger.isCheckout) {
      // The amount read off the checkout screen when one was found, and the
      // seeded figure when it was not, so the reflection screen always has a
      // real number to reason about rather than a blank.
      controller.startCheckout(amount: trigger.amount ?? 1250000);
      unawaited(navigator.pushNamed(Routes.intervensiBlanket));
    } else {
      controller.startLoanApp();
      unawaited(navigator.pushNamed(Routes.intervensiTujuan));
    }
    return true;
  }

  /// Opens the permission page once per launch while any permission is off.
  ///
  /// PIKIR is worth nothing to the user if it cannot see the moment it exists
  /// to interrupt, and the three permissions can only be granted by hand in
  /// Android's own settings, so an app that never mentions them stays silently
  /// inert. It is offered once and then dropped: an app that argues against
  /// pressure has no business nagging.
  ///
  /// A trigger takes precedence. If the watcher brought PIKIR to the front,
  /// the user is standing in front of a loan app right now and the permission
  /// page would be in the way of the thing they came here for.
  Future<void> _offerMissingPermissions() async {
    if (ref.read(launchPromptSeenProvider)) return;

    final status = await ref.read(permissionStatusProvider.future);
    if (!mounted || status.allGranted) return;

    final navigator = _navigatorKey.currentState;
    // canPop means a trigger already pushed the intervention ahead of us.
    if (navigator == null || navigator.canPop()) return;

    ref.read(launchPromptSeenProvider.notifier).markSeen();
    await navigator.pushNamed(
      Routes.pengaturanIzin,
      arguments: kIzinLaunchPrompt,
    );
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
