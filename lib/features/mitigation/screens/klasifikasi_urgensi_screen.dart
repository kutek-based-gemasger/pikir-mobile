import 'package:flutter/material.dart';

import '../../../core/dev/placeholder_screen.dart';

/// Menentukan apakah kebutuhan tergolong bertahan hidup dan mendesak.
///
/// Phase 1 stub. Replace the body with the real screen; the route and the
/// entry in the screen registry already point here.
class KlasifikasiUrgensiScreen extends StatelessWidget {
  const KlasifikasiUrgensiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Klasifikasi Urgensi',
      reference: 'Stitch klasifikasi_q2_urgensi',
      note: 'Menentukan apakah kebutuhan tergolong bertahan hidup dan mendesak.',
      showBottomNav: false,
      overlay: false,
    );
  }
}
