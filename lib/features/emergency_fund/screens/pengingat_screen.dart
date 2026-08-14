import 'package:flutter/material.dart';

import '../../../core/dev/placeholder_screen.dart';

/// Pengingat lokal. Tidak ada hari yang terpilih lebih dulu.
///
/// Phase 1 stub. Replace the body with the real screen; the route and the
/// entry in the screen registry already point here.
class PengingatScreen extends StatelessWidget {
  const PengingatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Pengingat Menabung',
      reference: 'SCREENS.md layar 30 - P2',
      note: 'Pengingat lokal. Tidak ada hari yang terpilih lebih dulu.',
      showBottomNav: false,
      overlay: false,
    );
  }
}
