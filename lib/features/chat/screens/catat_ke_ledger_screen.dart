import 'package:flutter/material.dart';

import '../../../core/dev/placeholder_screen.dart';

/// Menawarkan mencatat hasil obrolan ke ledger utang.
///
/// Phase 1 stub. Replace the body with the real screen; the route and the
/// entry in the screen registry already point here.
class CatatKeLedgerScreen extends StatelessWidget {
  const CatatKeLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Konfirmasi Catat ke Ledger',
      reference: 'Stitch konfirmasi_catat_ke_ledger_dari_chat',
      note: 'Menawarkan mencatat hasil obrolan ke ledger utang.',
      showBottomNav: false,
      overlay: false,
    );
  }
}
