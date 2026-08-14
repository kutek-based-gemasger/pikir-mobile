import 'package:flutter/material.dart';

import '../../../core/dev/placeholder_screen.dart';

/// Dihitung dari risiko pengguna sendiri, bukan patokan tiga sampai enam kali gaji.
///
/// Phase 1 stub. Replace the body with the real screen; the route and the
/// entry in the screen registry already point here.
class HitungDanaDaruratScreen extends StatelessWidget {
  const HitungDanaDaruratScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Hitung Dana Darurat',
      reference: 'SCREENS.md layar 28 - P1',
      note: 'Dihitung dari risiko pengguna sendiri, bukan patokan tiga sampai enam kali gaji.',
      showBottomNav: false,
      overlay: false,
    );
  }
}
