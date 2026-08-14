import 'package:flutter/material.dart';

import '../../../core/dev/placeholder_screen.dart';

/// Menggantikan layar masuk. Aplikasi tidak minta nama, nomor HP, atau email.
///
/// Phase 1 stub. Replace the body with the real screen; the route and the
/// entry in the screen registry already point here.
class AnonimScreen extends StatelessWidget {
  const AnonimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Tanpa Akun, Tanpa Data Pribadi',
      reference: 'SCREENS.md layar 3 - P0',
      note: 'Menggantikan layar masuk. Aplikasi tidak minta nama, nomor HP, atau email.',
      showBottomNav: false,
      overlay: false,
    );
  }
}
