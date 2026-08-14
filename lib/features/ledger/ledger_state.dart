import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/debt_entry.dart';

/// The two views of the ledger.
enum LedgerTab {
  utang('Utang'),
  riwayat('Riwayat keputusan');

  const LedgerTab(this.label);

  final String label;
}

/// Which view is showing.
///
/// A view switch, not a decision, so starting on [LedgerTab.utang] is simply
/// where the user lands rather than a recommended answer.
class LedgerTabNotifier extends Notifier<LedgerTab> {
  @override
  LedgerTab build() => LedgerTab.utang;

  void select(LedgerTab tab) => state = tab;
}

final ledgerTabProvider = NotifierProvider<LedgerTabNotifier, LedgerTab>(
  LedgerTabNotifier.new,
);

/// The icon standing in for a debt's category.
///
/// Semi-concrete and recognisable rather than abstract, and always shown
/// beside the purpose in words: the icon never carries the meaning alone.
IconData debtIcon(DebtCategory? category) => switch (category) {
  DebtCategory.konsumtif => Icons.shopping_bag_outlined,
  DebtCategory.modalKerjaHarian => Icons.storefront_outlined,
  DebtCategory.beliAlat => Icons.handyman_outlined,
  DebtCategory.perbaikiAlat => Icons.two_wheeler_outlined,
  null => Icons.receipt_long_outlined,
};
