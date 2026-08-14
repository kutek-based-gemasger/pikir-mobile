import 'package:flutter/material.dart';

import '../../../core/dev/placeholder_screen.dart';

/// Tiga slide pengenalan, bisa dilewati kapan saja.
///
/// Phase 1 stub. Replace the body with the real screen; the route and the
/// entry in the screen registry already point here.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Onboarding',
      reference: 'SCREENS.md layar 2 - P1',
      note: 'Tiga slide pengenalan, bisa dilewati kapan saja.',
      showBottomNav: false,
      overlay: false,
    );
  }
}
