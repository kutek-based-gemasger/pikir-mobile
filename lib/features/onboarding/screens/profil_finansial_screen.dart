import 'package:flutter/material.dart';

import '../../../core/dev/placeholder_screen.dart';

/// Tiga pertanyaan penghasilan, tidak ada pilihan yang terpilih lebih dulu.
///
/// Phase 1 stub. Replace the body with the real screen; the route and the
/// entry in the screen registry already point here.
class ProfilFinansialScreen extends StatelessWidget {
  const ProfilFinansialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Profil Finansial Lokal',
      reference: 'SCREENS.md layar 6 - P0',
      note: 'Tiga pertanyaan penghasilan, tidak ada pilihan yang terpilih lebih dulu.',
      showBottomNav: false,
      overlay: false,
    );
  }
}
