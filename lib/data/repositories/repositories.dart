/// The contracts the UI talks to.
///
/// Everything here is an interface with a mock implementation behind it. The
/// current round ships a fully mocked frontend, so no method here performs a
/// network call, and each place a real one would go is marked with the
/// endpoint from the handoff document.
///
/// The point of the split is that swapping a mock for a real client is a
/// change in one provider, not a change to any screen.
library;

import '../models/chat.dart';
import '../models/debt_entry.dart';
import '../models/decision_record.dart';
import '../models/emergency_fund.dart';
import '../models/income_profile.dart';
import '../models/intervention.dart';
import '../models/mitigation.dart';
import '../models/notification_log.dart';

/// The local financial profile.
abstract interface class ProfileRepository {
  Future<IncomeProfile> load();

  Future<void> save(IncomeProfile profile);
}

/// Debts and the decisions that produced them.
abstract interface class LedgerRepository {
  Future<List<DebtEntry>> debts();

  Future<DebtSummary> summary();

  Future<void> addDebt(DebtEntry entry);

  /// Deletes the record outright, for something entered by mistake.
  Future<void> removeDebt(String id);

  /// Marks a debt paid off, or puts it back to running.
  ///
  /// Both directions through one method, because undoing has to exist: a debt
  /// marked paid off by a mis-tap would otherwise only be recoverable by
  /// deleting the record, which loses more than the mistake did.
  Future<void> setDebtSettled(String id, {required bool settled});

  Future<List<DecisionRecord>> decisions();

  Future<DecisionStats> decisionStats();

  Future<void> recordDecision(DecisionRecord record);
}

/// Emergency-fund planning.
abstract interface class EmergencyFundRepository {
  Future<EmergencyFundPlan> plan();

  /// Sizes the tiers from the user's own income and risk.
  ///
  /// TODO(backend): POST /api/v1/planning/emergency-fund
  Future<EmergencyFundPlan> calculatePlan(IncomeProfile profile);

  Future<void> addDeposit(SavingsDeposit deposit);

  Future<void> saveReminder(SavingsReminder reminder);
}

/// The preventive intervention, feature 1.
abstract interface class InterventionRepository {
  /// Analyses a blocked checkout or loan-app launch.
  ///
  /// Implementations must respect [kInterventionTimeout]: if no answer is
  /// ready within it, the caller shows the offline fallback instead. Blocking
  /// someone's phone indefinitely is not an acceptable failure mode.
  ///
  /// TODO(backend): POST /api/v1/intervene/analyze
  Future<InterventionAnalysis> analyze(InterventionRequest request);
}

/// Mitigation routing, feature 2.
abstract interface class MitigationRepository {
  /// Routes a need down one of the three branches.
  ///
  /// Implementations must honour the branch rules encoded in
  /// [MitigationResult]: financing only on the productive branch, assistance
  /// only on the urgent branch.
  ///
  /// TODO(backend): POST /api/v1/mitigation/routing
  Future<MitigationResult> route(MitigationRequest request);

  Future<FinancingOption?> financingOption(String id);

  Future<AssistanceProgram?> assistanceProgram(String id);
}

/// The notification scanner, feature 3.
abstract interface class NotificationScannerRepository {
  /// Whether scanning is switched on.
  Future<bool> isEnabled();

  Future<void> setEnabled({required bool enabled});

  Future<List<NotificationLog>> logs();

  Future<void> record(NotificationLog log);

  Future<void> clearLogs();

  Future<List<DetectedBill>> detectedBills();

  /// Writes the educational replacement for a notification that was dismissed.
  ///
  /// Whatever this returns, the replacement the user sees must always carry an
  /// action revealing the original message. Silencing something on someone's
  /// behalf is only defensible if they can still get to it.
  ///
  /// TODO(backend): POST /api/v1/notification/generate-warning
  Future<String> generateWarning(NotificationLog log);
}

/// Tanya PIKIR, feature 5.
abstract interface class ChatRepository {
  /// The current session, or null when there is none.
  Future<ChatSession?> currentSession();

  Future<ChatSession> startSession({ChatContext? context});

  /// Sends [text] and returns the updated session.
  ///
  /// Only [kChatSlidingWindow] messages are ever sent upstream.
  ///
  /// TODO(backend): POST /api/v1/chat/advisor
  Future<ChatSession> send(String sessionId, String text);

  /// Deletes sessions older than [kChatHistoryLifetime].
  ///
  /// Runs on app open. Purely local, and stated in the UI rather than done
  /// quietly.
  Future<void> purgeExpired();
}

/// Restores the seeded state used for the demo recording.
abstract interface class DemoRepository {
  Future<void> resetToSeed();
}
