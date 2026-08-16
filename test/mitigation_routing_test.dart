import 'package:flutter_test/flutter_test.dart';
import 'package:pikir/data/mock/mock_repositories.dart';
import 'package:pikir/data/mock/seed.dart';
import 'package:pikir/data/models/mitigation.dart';

/// The three-branch rule and the no-loan-product rule are the two things in
/// this app that would be worst to get wrong quietly, so both are tested at
/// the data layer rather than left to each screen to honour.
void main() {
  final repository = MockMitigationRepository();

  MitigationRequest request(NeedKind kind, {int? profit}) => MitigationRequest(
    topic: switch (kind) {
      NeedKind.konsumtif => NeedTopic.keinginan,
      NeedKind.kebutuhanMendesak => NeedTopic.kesehatan,
      NeedKind.produktif => NeedTopic.modalAtauAlatKerja,
    },
    kind: kind,
    amount: 1800000,
    monthlyNetProfit: profit,
  );

  group('branch isolation', () {
    test('a want gets opportunity cost and nothing else', () async {
      final result = await repository.route(request(NeedKind.konsumtif));

      expect(result.opportunityCost, isNotNull);
      // CLAUDE.md section 6 rule 7.
      expect(result.financingOptions, isEmpty);
      // A want does not go to social assistance either.
      expect(result.assistancePrograms, isEmpty);
    });

    test('an urgent need gets assistance and never a loan', () async {
      final result = await repository.route(
        request(NeedKind.kebutuhanMendesak),
      );

      expect(result.assistancePrograms, isNotEmpty);
      expect(result.financingOptions, isEmpty);
      expect(result.opportunityCost, isNull);
    });

    test('a productive need gets feasibility then financing', () async {
      final result = await repository.route(
        request(NeedKind.produktif, profit: 2400000),
      );

      expect(result.feasibility, isNotNull);
      expect(result.feasibility!.paybackDays, 23);
      expect(result.feasibility!.feasible, isTrue);
      expect(result.financingOptions, isNotEmpty);
      expect(result.assistancePrograms, isEmpty);
    });
  });

  group('the model refuses to hold an illegal combination', () {
    test('financing cannot be attached to a consumptive result', () {
      expect(
        () => MitigationResult(
          request: request(NeedKind.konsumtif),
          financingOptions: Seed.financingOptions(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('financing cannot be attached to an urgent-need result', () {
      expect(
        () => MitigationResult(
          request: request(NeedKind.kebutuhanMendesak),
          financingOptions: Seed.financingOptions(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('assistance cannot be attached to a consumptive result', () {
      expect(
        () => MitigationResult(
          request: request(NeedKind.konsumtif),
          assistancePrograms: Seed.assistancePrograms(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('ordering', () {
    test('financing is sorted fastest first, not cheapest first', () async {
      final result = await repository.route(
        request(NeedKind.produktif, profit: 2400000),
      );
      final options = result.financingOptions;

      // Ascending by wait.
      for (var i = 1; i < options.length; i++) {
        expect(
          options[i].disbursementDays,
          greaterThanOrEqualTo(options[i - 1].disbursementDays),
        );
      }

      // And the ordering genuinely costs something: the cheapest option is
      // not first. If it ever were, this test would pass by coincidence and
      // stop proving the rule, so assert the tension directly.
      final cheapest = [...options]
        ..sort((a, b) => a.costOnTop.compareTo(b.costOnTop));
      expect(
        cheapest.first.id,
        isNot(options.first.id),
        reason: 'Seed data must keep fastest and cheapest as different '
            'options, otherwise this rule is untested.',
      );
    });

    test('every financing option states its full cost', () async {
      final result = await repository.route(
        request(NeedKind.produktif, profit: 2400000),
      );

      for (final option in result.financingOptions) {
        expect(option.totalReturn, greaterThan(option.principal));
        expect(option.costOnTop, option.totalReturn - option.principal);
        expect(option.cautionLine, isNotEmpty);
        expect(option.trustBadge, isNotEmpty);
      }
    });
  });

  test('states the profit as whole rupiah, not as "ribu"', () async {
    // "Rp${profit ~/ 1000} ribu" rendered Rp1.500.000 as "Rp1500 ribu" on the
    // feasibility screen, which is both wrong and unreadable. Section 6 rule 6
    // asks for whole rupiah.
    final result = await MockMitigationRepository().route(
      const MitigationRequest(
        topic: NeedTopic.modalAtauAlatKerja,
        kind: NeedKind.produktif,
        amount: 2000000,
        monthlyNetProfit: 1500000,
      ),
    );

    expect(result.feasibility!.explanation, contains('Rp1.500.000'));
    expect(result.feasibility!.explanation, isNot(contains('ribu')));
  });
}
