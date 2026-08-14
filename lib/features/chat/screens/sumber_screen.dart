import 'package:flutter/material.dart';

import '../../../core/dev/placeholder_screen.dart';

/// Daftar sumber di balik satu jawaban.
///
/// Phase 1 stub. Replace the body with the real screen; the route and the
/// entry in the screen registry already point here.
class SumberJawabanScreen extends StatelessWidget {
  const SumberJawabanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Sumber Jawaban',
      reference: 'Stitch sumber_jawaban_ai',
      note: 'Daftar sumber di balik satu jawaban.',
      showBottomNav: false,
      overlay: false,
    );
  }
}
