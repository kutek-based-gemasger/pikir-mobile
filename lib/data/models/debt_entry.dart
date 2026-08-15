/// What a debt was taken for.
///
/// The split matters beyond bookkeeping: it is what lets the ledger show which
/// debts produce income and which do not, without the app ever having to
/// lecture anyone about it.
enum DebtCategory {
  konsumtif('Konsumtif'),
  modalKerjaHarian('Modal kerja harian'),
  beliAlat('Beli alat'),
  perbaikiAlat('Perbaiki alat');

  const DebtCategory(this.label);

  final String label;

  /// Whether this kind of debt is expected to generate income.
  bool get isProductive => this != DebtCategory.konsumtif;
}

/// How an entry got into the ledger.
enum DebtSource {
  /// Recorded by PIKIR after the user chose to continue past an intervention.
  otomatis('Dicatat otomatis'),

  /// Typed in by the user.
  manual('Dicatat manual');

  const DebtSource(this.label);

  final String label;
}

/// One debt in the ledger.
class DebtEntry {
  const DebtEntry({
    required this.id,
    required this.purpose,
    required this.principal,
    required this.monthlyInstalment,
    required this.source,
    required this.recordedAt,
    this.category,
    this.settledAt,
  });

  final String id;

  /// Plain language, in the user's own words: "HP baru", "Servis motor".
  final String purpose;

  /// The original amount borrowed, in whole rupiah.
  final int principal;

  /// What it costs per month. This, not [principal], is what drives the debt
  /// ratio, because the ratio is about whether this month is survivable.
  final int monthlyInstalment;

  final DebtSource source;

  final DateTime recordedAt;

  /// When the user marked this debt paid off, or null while it is still
  /// running.
  ///
  /// Kept rather than deleted, because a debt that has been paid off is the
  /// part of the ledger worth looking back on. It stops counting towards the
  /// monthly burden the moment it is set, which is the whole point: the ratio
  /// asks whether this month is survivable, and a finished debt costs nothing
  /// this month.
  final DateTime? settledAt;

  bool get isSettled => settledAt != null;

  /// Null when the user has not chosen one.
  ///
  /// Nullable on purpose. The add-debt form states that category may be left
  /// blank, and CLAUDE.md section 6 rule 2 forbids pre-filling a default, so
  /// there is no sensible non-null value to invent here.
  final DebtCategory? category;

  DebtEntry copyWith({
    String? purpose,
    int? principal,
    int? monthlyInstalment,
    DebtCategory? category,
  }) {
    return DebtEntry(
      id: id,
      purpose: purpose ?? this.purpose,
      principal: principal ?? this.principal,
      monthlyInstalment: monthlyInstalment ?? this.monthlyInstalment,
      source: source,
      recordedAt: recordedAt,
      category: category ?? this.category,
      settledAt: settledAt,
    );
  }

  /// Marks the debt paid off, or puts it back to running.
  ///
  /// A separate method rather than a copyWith argument, because clearing a
  /// field through a null-coalescing copyWith is impossible to express: passing
  /// null there means "leave it alone", which is exactly the opposite of what
  /// undoing needs.
  DebtEntry settled({required DateTime? at}) {
    return DebtEntry(
      id: id,
      purpose: purpose,
      principal: principal,
      monthlyInstalment: monthlyInstalment,
      source: source,
      recordedAt: recordedAt,
      category: category,
      settledAt: at,
    );
  }
}

/// The aggregate the home screen and the ledger header both read from.
class DebtSummary {
  const DebtSummary({
    required this.totalActiveDebt,
    required this.monthlyInstalmentTotal,
    required this.monthlyIncome,
  });

  /// Totals count only debts still running.
  ///
  /// A paid-off debt is kept in the ledger but leaves both figures, so the
  /// gauge answers the question it actually asks: what this month costs.
  factory DebtSummary.of(Iterable<DebtEntry> debts, {required int income}) {
    var principal = 0;
    var instalment = 0;
    for (final debt in debts.where((debt) => !debt.isSettled)) {
      principal += debt.principal;
      instalment += debt.monthlyInstalment;
    }

    return DebtSummary(
      totalActiveDebt: principal,
      monthlyInstalmentTotal: instalment,
      monthlyIncome: income,
    );
  }

  /// The prudence threshold the gauge is marked against.
  ///
  /// Deliberately not called a limit or a rule. It is a widely used rule of
  /// thumb, not regulation, and every screen that shows it says so.
  static const safeThreshold = 0.30;

  final int totalActiveDebt;
  final int monthlyInstalmentTotal;
  final int monthlyIncome;

  /// Monthly instalments as a fraction of monthly income, 0 to 1.
  double get ratio =>
      monthlyIncome <= 0 ? 0 : monthlyInstalmentTotal / monthlyIncome;

  bool get isOverThreshold => ratio > safeThreshold;

  /// The ratio this would become if [extraInstalment] were added.
  ///
  /// Used by the intervention screen to show the consequence before the
  /// decision rather than after it.
  double ratioWith(int extraInstalment) {
    if (monthlyIncome <= 0) return 0;
    return (monthlyInstalmentTotal + extraInstalment) / monthlyIncome;
  }
}
