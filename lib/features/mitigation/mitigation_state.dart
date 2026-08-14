import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/mitigation.dart';
import '../../data/providers.dart';

/// How the financing list is ordered.
enum FinancingSort {
  /// The default. Someone whose motorbike broke this morning cannot use the
  /// cheapest option if it arrives in three weeks.
  cepatCair('Cepat cair'),

  /// Offered as a switch the user chooses, never as the silent default.
  biayaTerkecil('Biaya terkecil');

  const FinancingSort(this.label);

  final String label;
}

/// What the user has answered so far.
class MitigationDraft {
  const MitigationDraft({this.topic, this.amount, this.monthlyNetProfit});

  final NeedTopic? topic;
  final int? amount;
  final int? monthlyNetProfit;

  /// Which of the three branches this topic belongs to.
  ///
  /// The mapping is the product's whole argument in one place: a want is not
  /// an emergency, and an emergency is not a financing problem.
  NeedKind? get kind => switch (topic) {
    null => null,
    NeedTopic.keinginan => NeedKind.konsumtif,
    NeedTopic.modalAtauAlatKerja => NeedKind.produktif,
    NeedTopic.kesehatan ||
    NeedTopic.kebutuhanHidup ||
    NeedTopic.pendidikan => NeedKind.kebutuhanMendesak,
  };

  /// The productive branch asks one extra question.
  ///
  /// The step indicator reports the real number rather than always saying
  /// three: telling someone there are three steps when there are two is a
  /// small dishonesty, and this app spends its credibility carefully.
  int get totalSteps => kind == NeedKind.produktif ? 3 : 2;

  MitigationDraft copyWith({
    NeedTopic? topic,
    int? amount,
    int? monthlyNetProfit,
  }) {
    return MitigationDraft(
      topic: topic ?? this.topic,
      amount: amount ?? this.amount,
      monthlyNetProfit: monthlyNetProfit ?? this.monthlyNetProfit,
    );
  }
}

class MitigationState {
  const MitigationState({
    this.draft = const MitigationDraft(),
    this.result,
    this.isRouting = false,
    this.sort = FinancingSort.cepatCair,
  });

  final MitigationDraft draft;
  final MitigationResult? result;
  final bool isRouting;
  final FinancingSort sort;

  /// The financing options in the order the user asked for.
  ///
  /// Sorting is a view concern, so it happens here rather than by rebuilding
  /// the result. The default stays fastest-first.
  List<FinancingOption> get sortedFinancing {
    final options = [...?result?.financingOptions];
    switch (sort) {
      case FinancingSort.cepatCair:
        options.sort(
          (a, b) => a.disbursementDays.compareTo(b.disbursementDays),
        );
      case FinancingSort.biayaTerkecil:
        options.sort((a, b) => a.costOnTop.compareTo(b.costOnTop));
    }
    return options;
  }

  MitigationState copyWith({
    MitigationDraft? draft,
    MitigationResult? result,
    bool? isRouting,
    FinancingSort? sort,
  }) {
    return MitigationState(
      draft: draft ?? this.draft,
      result: result ?? this.result,
      isRouting: isRouting ?? this.isRouting,
      sort: sort ?? this.sort,
    );
  }
}

class MitigationController extends Notifier<MitigationState> {
  @override
  MitigationState build() => const MitigationState();

  void chooseTopic(NeedTopic topic) {
    // Starts a fresh answer set. Coming back to step one and picking a
    // different branch must not carry the old branch's numbers forward.
    state = MitigationState(draft: MitigationDraft(topic: topic));
  }

  void setAmount(int amount) {
    state = state.copyWith(draft: state.draft.copyWith(amount: amount));
  }

  void setProfit(int profit) {
    state = state.copyWith(
      draft: state.draft.copyWith(monthlyNetProfit: profit),
    );
  }

  void setSort(FinancingSort sort) => state = state.copyWith(sort: sort);

  /// Routes the completed answers down their branch.
  Future<MitigationResult?> route() async {
    final draft = state.draft;
    final topic = draft.topic;
    final kind = draft.kind;
    if (topic == null || kind == null || draft.amount == null) return null;

    state = state.copyWith(isRouting: true);

    // TODO(backend): POST /api/v1/mitigation/routing
    final result = await ref
        .read(mitigationRepositoryProvider)
        .route(
          MitigationRequest(
            topic: topic,
            kind: kind,
            amount: draft.amount!,
            monthlyNetProfit: draft.monthlyNetProfit,
          ),
        );

    state = state.copyWith(isRouting: false, result: result);
    return result;
  }

  void reset() => state = const MitigationState();
}

final mitigationControllerProvider =
    NotifierProvider<MitigationController, MitigationState>(
      MitigationController.new,
    );
