import 'package:flutter/material.dart';

import '../../../core/dev/placeholder_screen.dart';

/// Priming izin pemindai notifikasi, diperiksa di dalam HP tanpa internet.
///
/// Phase 1 stub. Replace the body with the real screen; the route and the
/// entry in the screen registry already point here.
class IzinNotifikasiScreen extends StatelessWidget {
  const IzinNotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Izin Akses Notifikasi',
      reference: 'SCREENS.md layar 5 - P1',
      note: 'Priming izin pemindai notifikasi, diperiksa di dalam HP tanpa internet.',
      showBottomNav: false,
      overlay: false,
    );
  }
}
