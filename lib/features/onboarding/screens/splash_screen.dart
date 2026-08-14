import 'package:flutter/material.dart';

import '../../../core/dev/placeholder_screen.dart';

/// Logo, tagline, dan penyiapan awal sebelum masuk aplikasi.
///
/// Phase 1 stub. Replace the body with the real screen; the route and the
/// entry in the screen registry already point here.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Splash',
      reference: 'SCREENS.md layar 1 - P1',
      note: 'Logo, tagline, dan penyiapan awal sebelum masuk aplikasi.',
      showBottomNav: false,
      overlay: false,
    );
  }
}
