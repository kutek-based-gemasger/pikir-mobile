import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/rupiah.dart';
import '../../core/platform/screen_channel.dart';
import '../../data/models/debt_entry.dart';
import '../../data/models/decision_record.dart';
import '../../data/models/intervention.dart';
import '../../data/providers.dart';

/// Where the analysis sent the user.
enum InterventionOutcome {
  /// Show the reflection overlay.
  opportunityCost,

  /// Nothing worth reflecting on; offer to record it.
  recordToLedger,

  /// No answer in time. The local fallback takes over.
  offline,
}

class InterventionState {
  const InterventionState({
    this.trigger,
    this.amount,
    this.itemName,
    this.reason,
    this.analysis,
    this.isAnalyzing = false,
    this.fromRealTrigger = false,
  });

  final InterventionTrigger? trigger;

  /// The cart total or instalment read off the blocked screen.
  final int? amount;

  /// Typed by the user, never guessed for them.
  final String? itemName;

  final BorrowReason? reason;

  final InterventionAnalysis? analysis;

  final bool isAnalyzing;

  /// Whether the screen watcher started this, rather than Mode Demo.
  ///
  /// Decides where leaving goes. After a real trigger the user is standing in
  /// another app and "Lanjut ke aplikasi" has to give them that app back; in a
  /// demo there is no app underneath, only the screen they came from.
  final bool fromRealTrigger;

  InterventionState copyWith({
    InterventionTrigger? trigger,
    int? amount,
    String? itemName,
    BorrowReason? reason,
    InterventionAnalysis? analysis,
    bool? isAnalyzing,
    bool? fromRealTrigger,
  }) {
    return InterventionState(
      trigger: trigger ?? this.trigger,
      amount: amount ?? this.amount,
      itemName: itemName ?? this.itemName,
      reason: reason ?? this.reason,
      analysis: analysis ?? this.analysis,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      fromRealTrigger: fromRealTrigger ?? this.fromRealTrigger,
    );
  }
}

/// Drives the intervention from trigger to decision.
class InterventionController extends Notifier<InterventionState> {
  @override
  InterventionState build() => const InterventionState();

  /// A paylater checkout was detected.
  ///
  /// Both conditions have already been met upstream by the time this is
  /// called: the checkout screen was recognised AND paylater was selected.
  /// Firing on a checkout alone would interrupt every purchase the user makes
  /// and teach them to dismiss PIKIR without reading it.
  void startCheckout({required int amount, bool fromRealTrigger = false}) {
    state = InterventionState(
      trigger: InterventionTrigger.checkoutPaylater,
      amount: amount,
      fromRealTrigger: fromRealTrigger,
    );
  }

  /// A whitelisted loan app was opened.
  void startLoanApp({bool fromRealTrigger = false}) {
    state = InterventionState(
      trigger: InterventionTrigger.loanAppOpened,
      fromRealTrigger: fromRealTrigger,
    );
  }

  void chooseReason(BorrowReason reason) {
    state = state.copyWith(reason: reason);
  }

  void setItemName(String name) {
    state = state.copyWith(itemName: name.trim());
  }

  /// Runs the analysis against a hard deadline.
  ///
  /// CLAUDE.md section 7 makes the offline fallback mandatory rather than
  /// best-effort. This screen is covering another app, so a request that hangs
  /// does not degrade into a spinner, it holds the user's phone hostage. If
  /// there is no answer within [kInterventionTimeout] the local screen takes
  /// over, and any late reply is discarded.
  Future<InterventionOutcome> analyze() async {
    state = state.copyWith(isAnalyzing: true);

    final request = InterventionRequest(
      trigger: state.trigger ?? InterventionTrigger.checkoutPaylater,
      amount: state.amount,
      itemName: state.itemName,
      reason: state.reason,
    );

    // TODO(backend): POST /api/v1/intervene/analyze
    //
    // timeout rather than racing against a Future.delayed: the delayed one
    // keeps its timer alive even after the analysis wins, so every
    // intervention would leave a three second timer running behind it.
    // Catching Object covers both the timeout and a repository failure, which
    // land the user in the same place.
    InterventionAnalysis? analysis;
    try {
      analysis = await ref
          .read(interventionRepositoryProvider)
          .analyze(request)
          .timeout(kInterventionTimeout);
    } on Object {
      analysis = null;
    }

    if (analysis == null) {
      state = state.copyWith(isAnalyzing: false);
      return InterventionOutcome.offline;
    }

    state = state.copyWith(isAnalyzing: false, analysis: analysis);

    return analysis.action == InterventionAction.showOpportunityCost
        ? InterventionOutcome.opportunityCost
        : InterventionOutcome.recordToLedger;
  }

  /// Records that the user chose to wait.
  ///
  /// Logged in the same shape as continuing. The history is a record, not a
  /// tally of good and bad choices.
  Future<void> recordPostponed() async {
    final analysis = state.analysis;
    await ref.read(ledgerRepositoryProvider).recordDecision(
      DecisionRecord(
        id: 'dec-${DateTime.now().millisecondsSinceEpoch}',
        occurredAt: DateTime.now(),
        triggerContext: _context(),
        outcome: DecisionOutcome.ditunda,
        resultLine: analysis?.opportunityCost == null
            ? 'Kamu memilih menunda.'
            : 'Kamu memilih menabung '
                  '${analysis!.opportunityCost!.daysToSave} hari.',
      ),
    );
  }

  /// Records the debt and the decision to go ahead.
  ///
  /// Called after the five second hold, or from the ledger handover screen.
  /// The wording never scolds: the point of writing it down is that the total
  /// stays visible, not that the user is told off for adding to it.
  Future<void> recordContinued({DebtCategory? category}) async {
    final ledger = ref.read(ledgerRepositoryProvider);
    final now = DateTime.now();
    final amount = state.analysis?.instalmentAmount ?? state.amount ?? 0;

    await ledger.addDebt(
      DebtEntry(
        id: 'debt-${now.millisecondsSinceEpoch}',
        purpose: state.itemName?.isNotEmpty == true
            ? state.itemName!
            : 'Cicilan baru',
        principal: state.amount ?? amount,
        monthlyInstalment: amount,
        source: DebtSource.otomatis,
        recordedAt: now,
        category: category,
      ),
    );

    await ledger.recordDecision(
      DecisionRecord(
        id: 'dec-${now.millisecondsSinceEpoch}',
        occurredAt: now,
        triggerContext: _context(),
        outcome: DecisionOutcome.dilanjutkan,
        resultLine: 'Tercatat di ledger.',
      ),
    );
  }

  String _context() {
    final amount = state.amount;
    return switch (state.trigger) {
      InterventionTrigger.checkoutPaylater =>
        amount == null
            ? 'Checkout paylater'
            : 'Checkout paylater ${formatRupiah(amount)}',
      InterventionTrigger.loanAppOpened => 'Buka aplikasi pinjaman',
      null => 'Intervensi',
    };
  }

  void reset() => state = const InterventionState();
}

final interventionControllerProvider =
    NotifierProvider<InterventionController, InterventionState>(
      InterventionController.new,
    );

/// Leaves the intervention without taking any of PIKIR's paths.
///
/// Where "leaving" goes depends on how the user got here, and getting this
/// wrong is what made "Lanjut ke aplikasi" strand people on the splash screen:
/// popping a route walks back through PIKIR's own stack, which after a real
/// trigger is not where the user was at all.
///
/// After a real trigger PIKIR steps out of the way and gives back the app
/// underneath. From Mode Demo there is nothing underneath, so it pops back to
/// the screen the demo was fired from.
Future<void> leaveIntervention(BuildContext context, WidgetRef ref) async {
  final fromRealTrigger = ref.read(interventionControllerProvider).fromRealTrigger;
  final navigator = Navigator.of(context);

  // Cleared either way, so the next trigger starts from nothing rather than
  // inheriting the amount and the reason from the last one.
  ref.read(interventionControllerProvider.notifier).reset();

  if (fromRealTrigger) {
    await ScreenChannel.leaveToPreviousApp();
  } else {
    await navigator.maybePop();
  }
}
