import 'package:flutter/material.dart';

import '../../../core/dev/placeholder_screen.dart';

/// Mencatat tabungan yang masuk ke target dana darurat.
///
/// Phase 1 stub. Replace the body with the real screen; the route and the
/// entry in the screen registry already point here.
class SetoranScreen extends StatelessWidget {
  const SetoranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Catat Setoran',
      reference: 'Stitch catat_setoran_pengingat',
      note: 'Mencatat tabungan yang masuk ke target dana darurat.',
      showBottomNav: false,
      overlay: false,
    );
  }
}
