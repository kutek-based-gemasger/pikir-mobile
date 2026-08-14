import 'package:flutter_test/flutter_test.dart';
import 'package:pikir/core/format/rupiah.dart';
import 'package:pikir/data/mock/mock_repositories.dart';
import 'package:pikir/data/mock/seed.dart';
import 'package:pikir/data/models/debt_entry.dart';

/// CLAUDE.md section 8 pins the demo's figures so the recording always looks
/// the same. They are asserted here because they are the numbers judges will
/// read off the screen, and because they are easy to break by editing one
/// instalment without noticing the ratio moved.
void main() {
  test('the three ledger entries total Rp3.150.000', () {
    final total = Seed.debts().fold<int>(0, (sum, d) => sum + d.principal);

    expect(Seed.debts(), hasLength(3));
    expect(total, 3150000);
    expect(formatRupiah(total), 'Rp3.150.000');
  });

  test('the debt ratio is 18 percent', () async {
    final store = MockStore();
    final summary = await MockLedgerRepository(store).summary();

    expect(summary.monthlyInstalmentTotal, 720000);
    expect(summary.monthlyIncome, 4000000);
    expect(formatPercent(summary.ratio), '18%');
    expect(summary.isOverThreshold, isFalse);
  });

  test('the emergency fund sits at Rp450.000 of a Rp1.000.000 tier one', () {
    final plan = Seed.emergencyFund();

    expect(plan.currentAmount, 450000);
    expect(plan.tiers.first.target, 1000000);
    expect(plan.activeTier, plan.tiers.first);
    expect(plan.progressToActiveTier, closeTo(0.45, 0.001));
  });

  test('only the third tier is optional', () {
    final plan = Seed.emergencyFund();

    expect(plan.tiers.map((t) => t.optional), [false, false, true]);
    expect(plan.tiers.last.target, 7200000);
  });

  test('the opportunity cost figures move the ratio from 18 to 34 percent', () {
    final store = MockStore();
    var instalments = 0;
    for (final debt in store.debts) {
      instalments += debt.monthlyInstalment;
    }

    final summary = DebtSummary(
      totalActiveDebt: 0,
      monthlyInstalmentTotal: instalments,
      monthlyIncome: store.profile.monthlyIncome,
    );

    // The pair of numbers the reflection screen shows side by side. If the
    // seeded instalment drifts, this catches it before a judge does.
    expect(formatPercent(summary.ratio), '18%');
    expect(
      formatPercent(summary.ratioWith(Seed.paylaterMonthlyInstalment)),
      '34%',
    );
  });

  test('the productive payback matches the quoted 23 days', () {
    // Rp1.800.000 of capital against Rp2.400.000 of monthly net profit.
    const capital = 1800000;
    const monthlyProfit = 2400000;
    final days = (capital / (monthlyProfit / 30)).ceil();

    expect(days, 23);
  });
}
