/// What the user did when PIKIR stepped in.
enum DecisionOutcome {
  /// Chose to wait or to save instead.
  ditunda('Ditunda'),

  /// Went ahead. Recorded exactly as neutrally as the others.
  dilanjutkan('Dilanjutkan'),

  /// Ignored a flagged notification.
  diabaikan('Diabaikan');

  const DecisionOutcome(this.label);

  final String label;
}

/// One entry in the decision history.
///
/// This list is a record, not a scoreboard. CLAUDE.md section 6 rule 5 rules
/// out streaks, points, badges, and congratulatory tone, so there is no score
/// field here and no notion of a "good" outcome: continuing is logged in the
/// same shape and the same words as pausing.
class DecisionRecord {
  const DecisionRecord({
    required this.id,
    required this.occurredAt,
    required this.triggerContext,
    required this.outcome,
    required this.resultLine,
  });

  final String id;
  final DateTime occurredAt;

  /// What was happening: "Checkout paylater Rp1.250.000".
  final String triggerContext;

  final DecisionOutcome outcome;

  /// What followed, stated factually: "Kamu memilih menabung 21 hari."
  final String resultLine;
}

/// The neutral tallies shown above the history.
///
/// Counts and a rupiah figure, with no ratio, rank, or trend. A "you paused
/// 80% of the time" framing would turn the next decision into a streak to
/// protect, which is the mechanic this app exists to argue against.
class DecisionStats {
  const DecisionStats({
    required this.paused,
    required this.continued,
    required this.interestAvoided,
  });

  final int paused;
  final int continued;

  /// Interest not paid on the occasions the user chose to wait.
  final int interestAvoided;
}
