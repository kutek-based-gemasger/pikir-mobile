/// How money arrives.
///
/// This drives the emergency-fund maths. A "three to six months of salary"
/// target is meaningless to someone paid per delivery, so the plan is built
/// from the user's own rhythm and risk instead.
enum IncomeRhythm {
  harian('Harian atau tidak menentu'),
  bulanan('Bulanan atau tetap');

  const IncomeRhythm(this.label);

  final String label;
}

/// How often work stops without warning.
enum JobRisk {
  jarang('Jarang', 1),
  kadang('Kadang', 2),
  sering('Sering', 3);

  const JobRisk(this.label, this.weight);

  final String label;

  /// Multiplier used when sizing the emergency fund. Higher risk means a
  /// larger first tier, because the gap between shocks is shorter.
  final int weight;
}

/// The local financial profile.
///
/// Stays on the device. There is no account to attach it to and nothing here
/// identifies a person: no name, no phone number, no email.
class IncomeProfile {
  const IncomeProfile({
    this.rhythm,
    this.monthlyIncome = 0,
    this.mandatoryMonthlyExpense = 0,
    this.dependents = 0,
    this.risk,
  });

  /// Null until the user answers.
  ///
  /// The setup form pre-selects nothing, so the model has to be able to
  /// represent "not answered yet" rather than quietly defaulting to one.
  final IncomeRhythm? rhythm;

  final int monthlyIncome;
  final int mandatoryMonthlyExpense;
  final int dependents;

  /// Null until the user answers.
  final JobRisk? risk;

  bool get isComplete => rhythm != null && risk != null && monthlyIncome > 0;

  IncomeProfile copyWith({
    IncomeRhythm? rhythm,
    int? monthlyIncome,
    int? mandatoryMonthlyExpense,
    int? dependents,
    JobRisk? risk,
  }) {
    return IncomeProfile(
      rhythm: rhythm ?? this.rhythm,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      mandatoryMonthlyExpense:
          mandatoryMonthlyExpense ?? this.mandatoryMonthlyExpense,
      dependents: dependents ?? this.dependents,
      risk: risk ?? this.risk,
    );
  }
}
