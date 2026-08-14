import 'package:flutter/material.dart';

import '../../../core/dev/placeholder_screen.dart';

/// Priming izin deteksi layar, dengan dua tombol berukuran sama.
///
/// Phase 1 stub. Replace the body with the real screen; the route and the
/// entry in the screen registry already point here.
class IzinLayarScreen extends StatelessWidget {
  const IzinLayarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Izin Deteksi Layar',
      reference: 'SCREENS.md layar 4 - P0',
      note: 'Priming izin deteksi layar, dengan dua tombol berukuran sama.',
      showBottomNav: false,
      overlay: false,
    );
  }
}
