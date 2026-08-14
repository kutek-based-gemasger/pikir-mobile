/// What the money is for, as the user picks it in step 1.
enum NeedTopic {
  kesehatan('Kesehatan', 'berobat, obat, rumah sakit'),
  kebutuhanHidup('Kebutuhan hidup', 'makan, listrik, kontrakan'),
  pendidikan('Pendidikan', 'SPP, buku, seragam'),
  modalAtauAlatKerja('Modal atau alat kerja', 'dagangan, servis motor, alat usaha'),
  keinginan('Barang atau keinginan', 'HP, baju, gadget, liburan');

  const NeedTopic(this.label, this.example);

  final String label;
  final String example;
}

/// The three branches a need can take.
///
/// Three, not two. This was corrected late and older drafts in the repository
/// still get it wrong, so it is worth being blunt about: a want and an
/// emergency are not the same problem, and neither of them is a financing
/// problem.
enum NeedKind {
  /// A want. Goes to the opportunity cost screen. Never to social assistance,
  /// and never to a loan product.
  konsumtif,

  /// Survival: medical care, food, rent. Goes to social assistance and rights
  /// routing. Never to a loan product, at any interest rate, ever.
  kebutuhanMendesak,

  /// Working capital or a broken tool. Goes to the feasibility test first,
  /// and only then to financing options.
  produktif,
}

/// Whether a financing option may be shown on this branch.
///
/// Only the productive branch. The other two are protected paths.
extension NeedKindRouting on NeedKind {
  bool get mayShowFinancing => this == NeedKind.produktif;

  bool get mayShowAssistance => this == NeedKind.kebutuhanMendesak;
}

/// What the user told the wizard.
class MitigationRequest {
  const MitigationRequest({
    required this.topic,
    required this.kind,
    required this.amount,
    this.monthlyNetProfit,
  });

  final NeedTopic topic;
  final NeedKind kind;

  /// What is actually needed, not what was offered.
  final int amount;

  /// Net of fuel, food, and deposits. Only asked on the productive branch.
  final int? monthlyNetProfit;
}

/// Can this pay for itself, and how fast.
class FeasibilityResult {
  const FeasibilityResult({
    required this.paybackDays,
    required this.feasible,
    required this.explanation,
  });

  final int paybackDays;
  final bool feasible;

  /// Plain language working, so the verdict is checkable rather than oracular.
  final String explanation;
}

/// One way to raise the money, on the productive branch only.
class FinancingOption {
  const FinancingOption({
    required this.id,
    required this.name,
    required this.disbursementLabel,
    required this.disbursementDays,
    required this.principal,
    required this.totalReturn,
    required this.cautionLine,
    required this.trustBadge,
    this.serviceFee = 0,
    this.adminFee = 0,
    this.sourceLabel,
  });

  final String id;
  final String name;

  /// Human phrasing of the wait: "1-2 hari", "Hari ini".
  final String disbursementLabel;

  /// Used for ordering. See [MitigationResult] for why speed, not interest.
  final int disbursementDays;

  final int principal;

  /// Everything the user hands back. No asterisks, no fees revealed later.
  final int totalReturn;

  final int serviceFee;
  final int adminFee;

  /// One honest caution, stated plainly rather than buried.
  final String cautionLine;

  /// "Terdaftar OJK", "Program pemerintah", "BUMN".
  final String trustBadge;

  final String? sourceLabel;

  /// What borrowing costs on top of the principal.
  int get costOnTop => totalReturn - principal;
}

/// A social assistance programme or a right the user can claim.
class AssistanceProgram {
  const AssistanceProgram({
    required this.id,
    required this.name,
    required this.provider,
    required this.whatYouGet,
    required this.requirements,
    required this.howToApply,
    this.sourceLabel,
  });

  final String id;
  final String name;

  /// Who runs it, so the user knows which door to knock on.
  final String provider;

  final String whatYouGet;
  final List<String> requirements;
  final List<String> howToApply;
  final String? sourceLabel;
}

/// What waiting costs, and what borrowing would cost, on the consumptive
/// branch.
class OpportunityCost {
  const OpportunityCost({
    required this.itemName,
    required this.price,
    required this.interestIfBorrowed,
    required this.comparison,
    required this.daysToSave,
    required this.suggestedMonthlySaving,
  });

  final String itemName;
  final int price;

  /// Interest the user would pay. Shown before the decision, never after.
  final int interestIfBorrowed;

  /// The number made concrete: "Setara 8 kali makan, atau 1,5 hari
  /// penghasilanmu." An amount in rupiah is abstract to someone who is tired.
  final String comparison;

  final int daysToSave;
  final int suggestedMonthlySaving;
}

/// The outcome of routing, branch-aware.
///
/// The constructor asserts the product rule rather than leaving it to each
/// screen to remember: a financing option cannot be attached to a consumptive
/// or urgent-need result, and assistance cannot be attached to a consumptive
/// one. CLAUDE.md section 6 rule 7 calls this a hard product rule, so it is
/// enforced where the data is built, not where it is displayed.
class MitigationResult {
  MitigationResult({
    required this.request,
    this.feasibility,
    this.financingOptions = const [],
    this.assistancePrograms = const [],
    this.opportunityCost,
  }) : assert(
         financingOptions.isEmpty || request.kind == NeedKind.produktif,
         'A loan product may never appear on a consumptive or urgent-need '
         'path. See CLAUDE.md section 6 rule 7.',
       ),
       assert(
         assistancePrograms.isEmpty ||
             request.kind == NeedKind.kebutuhanMendesak,
         'Assistance routing belongs to the urgent-need branch. A want does '
         'not go to social assistance.',
       );

  final MitigationRequest request;

  /// Productive branch only, computed before options are shown.
  final FeasibilityResult? feasibility;

  /// Productive branch only.
  ///
  /// Callers should present these in the order given. The mock sorts by
  /// [FinancingOption.disbursementDays] rather than by cost, because someone
  /// whose motorbike broke this morning cannot use the cheapest option if it
  /// arrives in three weeks. The cheaper-first view is offered as a toggle the
  /// user chooses, never as the silent default.
  final List<FinancingOption> financingOptions;

  /// Urgent-need branch only.
  final List<AssistanceProgram> assistancePrograms;

  /// Consumptive branch only.
  final OpportunityCost? opportunityCost;
}
