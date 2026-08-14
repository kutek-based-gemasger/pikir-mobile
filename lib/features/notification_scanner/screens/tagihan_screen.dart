import 'package:flutter/material.dart';

import '../../../core/dev/placeholder_screen.dart';

/// Jatuh tempo yang terbaca dari notifikasi, untuk kesadaran saja.
///
/// Phase 1 stub. Replace the body with the real screen; the route and the
/// entry in the screen registry already point here.
class TagihanScreen extends StatelessWidget {
  const TagihanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Tagihan Terdeteksi',
      reference: 'SCREENS.md layar 26 - P1',
      note: 'Jatuh tempo yang terbaca dari notifikasi, untuk kesadaran saja.',
      showBottomNav: false,
      overlay: false,
    );
  }
}
