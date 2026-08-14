import 'package:flutter/material.dart';

import '../../../core/dev/placeholder_screen.dart';

/// Alasan sebuah notifikasi ditandai, plus aksi menampilkan pesan aslinya.
///
/// Phase 1 stub. Replace the body with the real screen; the route and the
/// entry in the screen registry already point here.
class PeringatanScreen extends StatelessWidget {
  const PeringatanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Detail Peringatan',
      reference: 'SCREENS.md layar 25 - P1',
      note: 'Alasan sebuah notifikasi ditandai, plus aksi menampilkan pesan aslinya.',
      showBottomNav: false,
      overlay: false,
    );
  }
}
