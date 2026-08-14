import 'package:flutter/material.dart';

import '../../../core/dev/placeholder_screen.dart';

/// Tiga isian, semuanya kosong di awal.
///
/// Phase 1 stub. Replace the body with the real screen; the route and the
/// entry in the screen registry already point here.
class TambahUtangScreen extends StatelessWidget {
  const TambahUtangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Tambah Utang Manual',
      reference: 'SCREENS.md layar 37 - P2',
      note: 'Tiga isian, semuanya kosong di awal.',
      showBottomNav: false,
      overlay: false,
    );
  }
}
