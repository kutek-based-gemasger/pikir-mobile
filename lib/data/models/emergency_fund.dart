/// One rung of the emergency-fund ladder.
class EmergencyFundTier {
  const EmergencyFundTier({
    required this.level,
    required this.target,
    required this.covers,
    this.optional = false,
  });

  final int level;

  /// Cumulative rupiah target for this tier.
  final int target;

  /// What reaching it actually buys, in concrete terms: "Menutup satu
  /// kejadian: servis motor atau berobat mendadak." An abstract number is not
  /// motivating; a named disaster it covers is.
  final String covers;

  /// Marks a tier the user is explicitly not expected to reach.
  ///
  /// Three months of living costs is out of reach on a daily income. Saying so
  /// is kinder and more honest than leaving a bar permanently unfinished, and
  /// it is why the UI shows an "Opsional" pill rather than an empty segment.
  final bool optional;
}

/// How the user wants to be nudged to save.
enum SavingsMode {
  persentase('Persentase tiap pemasukan'),
  nominalTetap('Nominal tetap tiap bulan');

  const SavingsMode(this.label);

  final String label;
}

/// A local savings reminder.
///
/// Runs from the device with no server involved. Nothing here is pre-enabled
/// or pre-selected.
class SavingsReminder {
  const SavingsReminder({
    this.enabled = false,
    this.hour,
    this.minute,
    this.days = const {},
    this.mode,
    this.percentage,
    this.fixedAmount,
  });

  /// Off until the user turns it on.
  final bool enabled;

  final int? hour;
  final int? minute;

  /// Weekday numbers, 1 = Monday. Empty until the user picks.
  final Set<int> days;

  final SavingsMode? mode;

  /// Percent of each incoming payment, when [mode] is [SavingsMode.persentase].
  final int? percentage;

  /// Rupiah per month, when [mode] is [SavingsMode.nominalTetap].
  final int? fixedAmount;

  SavingsReminder copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    Set<int>? days,
    SavingsMode? mode,
    int? percentage,
    int? fixedAmount,
  }) {
    return SavingsReminder(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      days: days ?? this.days,
      mode: mode ?? this.mode,
      percentage: percentage ?? this.percentage,
      fixedAmount: fixedAmount ?? this.fixedAmount,
    );
  }
}

/// Money put in.
class SavingsDeposit {
  const SavingsDeposit({
    required this.id,
    required this.amount,
    required this.recordedAt,
  });

  final String id;
  final int amount;
  final DateTime recordedAt;
}

/// The whole emergency-fund picture.
class EmergencyFundPlan {
  const EmergencyFundPlan({
    required this.currentAmount,
    required this.tiers,
    this.deposits = const [],
    this.reminder = const SavingsReminder(),
  });

  final int currentAmount;
  final List<EmergencyFundTier> tiers;
  final List<SavingsDeposit> deposits;
  final SavingsReminder reminder;

  /// The tier currently being worked toward, or null once all are reached.
  EmergencyFundTier? get activeTier {
    for (final tier in tiers) {
      if (currentAmount < tier.target) return tier;
    }
    return null;
  }

  /// Progress toward [activeTier], 0 to 1.
  ///
  /// Measured from the previous tier's target, not from zero, so the bar
  /// reflects the stretch actually in front of the user.
  double get progressToActiveTier {
    final tier = activeTier;
    if (tier == null) return 1;

    final index = tiers.indexOf(tier);
    final floor = index == 0 ? 0 : tiers[index - 1].target;
    final span = tier.target - floor;
    if (span <= 0) return 1;

    return ((currentAmount - floor) / span).clamp(0.0, 1.0);
  }
}
