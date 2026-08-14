import 'mitigation.dart';

/// If analysis has not returned within this long, the local fallback screen is
/// shown instead. Mandatory, not best-effort: an intervention that hangs is
/// worse than no intervention, because it blocks the user's phone.
const kInterventionTimeout = Duration(seconds: 3);

/// What put PIKIR on screen.
enum InterventionTrigger {
  /// Checkout screen detected AND paylater selected. Both conditions, not
  /// either: blocking on checkout alone would fire on every purchase and
  /// train the user to swipe PIKIR away.
  checkoutPaylater,

  /// A whitelisted loan app was opened. Blocked the moment it opens.
  loanAppOpened,
}

/// What the analysis decided to do.
enum InterventionAction {
  /// Show the reflection overlay with the cost laid out.
  showOpportunityCost,

  /// Nothing to reflect on; just offer to record the decision.
  recordToLedger,
}

/// The reason the user gave for opening a loan app.
enum BorrowReason {
  urgentAtauModal(
    'Kebutuhan mendesak atau modal kerja',
    'berobat, alat kerja rusak, modal dagang',
  ),
  barangAtauKeinginan(
    'Beli barang atau keinginan',
    'HP, baju, gadget, liburan',
  );

  const BorrowReason(this.label, this.example);

  final String label;
  final String example;

  /// Where this answer hands off to.
  ///
  /// The urgent answer goes straight to mitigation without asking anything
  /// else. Someone whose child is ill should not be made to fill in a form
  /// about what they want to buy.
  NeedKind? get handoverKind =>
      this == BorrowReason.urgentAtauModal ? null : NeedKind.konsumtif;
}

/// What the intervention asks about before it can say anything useful.
class InterventionRequest {
  const InterventionRequest({
    required this.trigger,
    this.amount,
    this.itemName,
    this.reason,
  });

  final InterventionTrigger trigger;

  /// The instalment or cart total picked up from the blocked screen.
  final int? amount;

  /// Typed by the user on the consumptive path. Never guessed for them.
  final String? itemName;

  final BorrowReason? reason;
}

/// The analysis outcome.
class InterventionAnalysis {
  const InterventionAnalysis({
    required this.action,
    required this.instalmentAmount,
    required this.ratioBefore,
    required this.ratioAfter,
    this.opportunityCost,
  });

  final InterventionAction action;

  final int instalmentAmount;

  /// Debt ratio now, and what it becomes if the user goes ahead.
  ///
  /// Both are shown together. A single number cannot convey a change, and the
  /// change is the whole point.
  final double ratioBefore;
  final double ratioAfter;

  final OpportunityCost? opportunityCost;

  bool get pushesOverThreshold => ratioAfter > 0.30 && ratioBefore <= 0.30;
}
