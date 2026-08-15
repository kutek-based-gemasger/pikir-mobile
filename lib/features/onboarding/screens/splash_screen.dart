import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';

/// The first thing the app shows.
///
/// Nothing loads here. There is no backend to wait for and the local database
/// opens in milliseconds, so a progress bar would be theatre. What this screen
/// buys is the tagline: the one line that says what the app is for, shown
/// before the user is asked anything at all.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// How long the mark stays before the app moves on.
  ///
  /// Long enough to read six words, short enough not to be in the way.
  static const dwell = Duration(milliseconds: 1600);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashScreen.dwell, _advance);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _advance() {
    if (!mounted) return;

    // Not while something is on top. The screen watcher can bring PIKIR to the
    // front the instant a loan app opens, and an interception pushed over this
    // screen must not be replaced out from under the user by a timer that
    // started before it existed.
    //
    // Checked again shortly rather than abandoned, because the interception
    // eventually closes and lands back here. Giving up on the first look left
    // the splash screen on screen forever with nothing to tap.
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      _timer = Timer(const Duration(milliseconds: 300), _advance);
      return;
    }

    Navigator.of(context).pushReplacementNamed(Routes.anonim);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PikirColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PikirSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              const PikirMark(size: 88, onDark: true, showWordmark: false),
              const SizedBox(height: 24),
              Text(
                'PIKIR',
                style: PikirText.headlineLarge.copyWith(
                  color: PikirColors.onPrimary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Pikir dulu, baru pinjam.',
                textAlign: TextAlign.center,
                style: PikirText.body.copyWith(
                  color: PikirColors.onPrimary.withValues(alpha: 0.9),
                ),
              ),
              const Spacer(flex: 4),
              // Said here, before anything is asked for, rather than buried in
              // a privacy screen the user reaches later.
              Text(
                'Tanpa akun. Tanpa data pribadi.',
                textAlign: TextAlign.center,
                style: PikirText.caption.copyWith(
                  color: PikirColors.onPrimary.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
