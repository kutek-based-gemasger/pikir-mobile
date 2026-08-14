import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/rupiah.dart';
import '../../../core/format/tanggal.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/debt_entry.dart';
import '../../../data/models/decision_record.dart';
import '../../../data/queries.dart';
import '../ledger_state.dart';

/// The debt ledger, with the decision history behind a second tab.
///
/// The history is a record, not a scoreboard. Continuing is listed in the same
/// shape and the same tone as pausing, with no score, no streak, and nothing
/// congratulatory: the user is looking at their own past decisions, not being
/// graded on them.
class LedgerScreen extends ConsumerWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(ledgerTabProvider);

    return PikirScaffold(
      currentTab: PikirTab.ledger,
      appBar: AppBar(title: const Text('Catatan utang')),
      floatingActionButton: tab == LedgerTab.utang
          ? FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.ledgerTambah),
              backgroundColor: PikirColors.primary,
              foregroundColor: PikirColors.onPrimary,
              icon: const Icon(Icons.add_rounded),
              label: Text('Tambah', style: PikirText.button),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          PikirSpacing.screenHorizontal,
          0,
          PikirSpacing.screenHorizontal,
          96,
        ),
        children: [
          const _TotalCard(),
          const SizedBox(height: PikirSpacing.cardGap),
          PikirSegmented<LedgerTab>(
            segments: [
              for (final value in LedgerTab.values)
                PikirSegment(value: value, label: value.label),
            ],
            selected: tab,
            onSelect: (value) =>
                ref.read(ledgerTabProvider.notifier).select(value),
          ),
          const SizedBox(height: PikirSpacing.cardGap),
          if (tab == LedgerTab.utang)
            const _DebtList()
          else
            const _DecisionHistory(),
        ],
      ),
    );
  }
}

class _TotalCard extends ConsumerWidget {
  const _TotalCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(debtSummaryProvider);

    return PikirCard(
      hero: true,
      child: summary.when(
        loading: () => const PikirCardLoading(height: 130),
        error: (_, _) =>
            PikirLoadFailure(onRetry: () => ref.invalidate(debtSummaryProvider)),
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total utang aktif', style: PikirText.body),
            const SizedBox(height: 8),
            Text(
              formatRupiah(data.totalActiveDebt),
              style: PikirText.displayNumber,
            ),
            const SizedBox(height: 14),
            ThresholdGauge(
              value: data.ratio,
              threshold: DebtSummary.safeThreshold,
              caption: 'dari penghasilan bulananmu',
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtList extends ConsumerWidget {
  const _DebtList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtsProvider);

    return debts.when(
      loading: () => const PikirCardLoading(height: 200),
      error: (_, _) => PikirCard(
        child: PikirLoadFailure(onRetry: () => ref.invalidate(debtsProvider)),
      ),
      data: (list) {
        if (list.isEmpty) {
          return PikirCard(
            outlined: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Belum ada catatan utang', style: PikirText.title),
                const SizedBox(height: 6),
                Text(
                  'Kalau nanti kamu ambil cicilan, kami catat di sini supaya '
                  'totalnya kelihatan.',
                  style: PikirText.bodySecondary,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            for (final debt in list) ...[
              _DebtCard(debt: debt),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _DebtCard extends StatelessWidget {
  const _DebtCard({required this.debt});

  final DebtEntry debt;

  @override
  Widget build(BuildContext context) {
    return PikirCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: PikirColors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              debtIcon(debt.category),
              size: 22,
              color: PikirColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(debt.purpose, style: PikirText.title),
                    ),
                    if (debt.category != null) ...[
                      const SizedBox(width: 8),
                      // Flexible, not fixed: a long category label at a large
                      // system text size would otherwise push the row past
                      // the card edge.
                      Flexible(
                        child: _CategoryChip(category: debt.category!),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  formatRupiah(debt.principal),
                  style: PikirText.number.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cicilan ${formatRupiah(debt.monthlyInstalment)} per bulan',
                  style: PikirText.captionSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  '${debt.source.label} ${formatShortDate(debt.recordedAt)}',
                  style: PikirText.captionSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final DebtCategory category;

  @override
  Widget build(BuildContext context) {
    // Productive debt is tinted green and consumptive is left neutral grey.
    // The distinction is informational, never a verdict: a consumptive debt
    // is not marked in red or wrong, it is simply labelled.
    final productive = category.isProductive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: productive
            ? PikirColors.primaryContainer
            : PikirColors.background,
        borderRadius: BorderRadius.circular(PikirRadius.chip),
        border: productive ? null : Border.all(color: PikirColors.outline),
      ),
      child: Text(
        category.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: PikirText.caption.copyWith(
          color: productive ? PikirColors.primary : PikirColors.textSecondary,
        ),
      ),
    );
  }
}

class _DecisionHistory extends ConsumerWidget {
  const _DecisionHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisions = ref.watch(decisionsProvider);
    final stats = ref.watch(decisionStatsProvider);

    return Column(
      children: [
        PikirCard(
          outlined: true,
          child: stats.when(
            loading: () => const PikirCardLoading(height: 70),
            error: (_, _) => PikirLoadFailure(
              onRetry: () => ref.invalidate(decisionStatsProvider),
            ),
            data: (data) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Stat(value: '${data.paused}', label: 'kali ditahan'),
                _Stat(value: '${data.continued}', label: 'kali dilanjutkan'),
                _Stat(
                  value: formatRupiah(data.interestAvoided),
                  label: 'bunga tidak jadi dibayar',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: PikirSpacing.cardGap),
        decisions.when(
          loading: () => const PikirCardLoading(height: 200),
          error: (_, _) => PikirCard(
            child: PikirLoadFailure(
              onRetry: () => ref.invalidate(decisionsProvider),
            ),
          ),
          data: (list) {
            if (list.isEmpty) {
              return PikirCard(
                outlined: true,
                child: Text(
                  'Belum ada keputusan yang tercatat.',
                  style: PikirText.bodySecondary,
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatMonthYear(list.first.occurredAt),
                  style: PikirText.label.copyWith(
                    color: PikirColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                for (final record in list) ...[
                  _DecisionCard(record: record),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: PikirText.number.copyWith(fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label, style: PikirText.captionSecondary),
        ],
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({required this.record});

  final DecisionRecord record;

  @override
  Widget build(BuildContext context) {
    // Every outcome gets the same card, the same size, and the same neutral
    // wording. Continuing is amber at most, never red, because taking a loan
    // is a choice the user is allowed to make.
    final status = switch (record.outcome) {
      DecisionOutcome.ditunda => PikirStatus.safe,
      DecisionOutcome.dilanjutkan => PikirStatus.neutral,
      DecisionOutcome.diabaikan => PikirStatus.caution,
    };

    return PikirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  formatDateTime(record.occurredAt),
                  style: PikirText.captionSecondary,
                ),
              ),
              StatusChip(
                status: status,
                label: record.outcome.label,
                quiet: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(record.triggerContext, style: PikirText.title),
          const SizedBox(height: 4),
          Text(record.resultLine, style: PikirText.bodySecondary),
        ],
      ),
    );
  }
}
