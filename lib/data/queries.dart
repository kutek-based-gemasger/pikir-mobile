/// What the UI reads.
///
/// providers.dart decides which implementation is used; this file exposes the
/// reads themselves. Several of these are shared, the debt summary in
/// particular, which both Beranda and the ledger header show. Keeping one
/// provider for it means the two can never disagree about the same number.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/debt_entry.dart';
import 'models/decision_record.dart';
import 'models/emergency_fund.dart';
import 'models/income_profile.dart';
import 'models/notification_log.dart';
import 'providers.dart';

final debtsProvider = FutureProvider<List<DebtEntry>>(
  (ref) => ref.watch(ledgerRepositoryProvider).debts(),
);

final debtSummaryProvider = FutureProvider<DebtSummary>(
  (ref) => ref.watch(ledgerRepositoryProvider).summary(),
);

final decisionsProvider = FutureProvider<List<DecisionRecord>>(
  (ref) => ref.watch(ledgerRepositoryProvider).decisions(),
);

final decisionStatsProvider = FutureProvider<DecisionStats>(
  (ref) => ref.watch(ledgerRepositoryProvider).decisionStats(),
);

final emergencyFundProvider = FutureProvider<EmergencyFundPlan>(
  (ref) => ref.watch(emergencyFundRepositoryProvider).plan(),
);

final incomeProfileProvider = FutureProvider<IncomeProfile>(
  (ref) => ref.watch(profileRepositoryProvider).load(),
);

final scannerLogsProvider = FutureProvider<List<NotificationLog>>(
  (ref) => ref.watch(notificationScannerRepositoryProvider).logs(),
);

final scannerEnabledProvider = FutureProvider<bool>(
  (ref) => ref.watch(notificationScannerRepositoryProvider).isEnabled(),
);

final detectedBillsProvider = FutureProvider<List<DetectedBill>>(
  (ref) => ref.watch(notificationScannerRepositoryProvider).detectedBills(),
);

/// Bills falling due within the next seven days.
///
/// The window is what the summary card counts, so it is computed once here
/// rather than re-derived on the screen.
final billsDueSoonProvider = FutureProvider<List<DetectedBill>>((ref) async {
  final bills = await ref.watch(detectedBillsProvider.future);
  final now = DateTime.now();
  return bills.where((bill) {
    final days = bill.daysUntilDue(now);
    return days >= 0 && days <= 7;
  }).toList();
});

/// How many notifications the scanner held back.
final heldNotificationCountProvider = FutureProvider<int>((ref) async {
  final logs = await ref.watch(scannerLogsProvider.future);
  return logs
      .where((log) => log.status == NotificationStatus.mencurigakan)
      .length;
});
