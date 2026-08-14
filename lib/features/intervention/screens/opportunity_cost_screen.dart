import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/rupiah.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/mock/seed.dart';
import '../../../data/models/debt_entry.dart';
import '../../../data/models/mitigation.dart';
import '../../../data/queries.dart';
import '../../chat/chat_handover.dart';
import '../intervention_state.dart';
import '../widgets/intervention_overlay.dart';

/// The reflection overlay: what this instalment actually costs.
///
/// The rule that shapes every colour choice here is that nothing on this
/// screen is red. The user has done nothing wrong; they are weighing a
/// decision, and the state is amber because it is a pause, not a fault. Going
/// over the safe threshold is reported in amber with an icon and in words, so
/// the meaning survives without colour and without alarm.
///
/// All three actions are the same width, the same height, and the same font
/// weight. The one that continues is not shrunk, faded, or greyed: its
/// friction is a five second hold, which lives in the gesture.
class OpportunityCostScreen extends ConsumerWidget {
  const OpportunityCostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(interventionControllerProvider);
    final controller = ref.read(interventionControllerProvider.notifier);
    final analysis = state.analysis;
    final cost = analysis?.opportunityCost ?? Seed.opportunityCost;

    final instalment = analysis?.instalmentAmount ??
        Seed.paylaterMonthlyInstalment;
    final ratioBefore = analysis?.ratioBefore ?? 0.18;
    final ratioAfter = analysis?.ratioAfter ?? 0.34;

    Future<void> postpone() async {
      await controller.recordPostponed();
      ref.invalidate(decisionsProvider);
      if (!context.mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Routes.danaDarurat, (_) => false);
    }

    Future<void> askPikir() async {
      // Hands the numbers over so the user does not have to retype them, and
      // so they can see exactly what the assistant was told.
      await openChatWithContext(
        context,
        ref,
        label: 'cicilan ${cost.itemName}',
        detail:
            '${cost.itemName}, ${formatRupiah(cost.price)}, bunga '
            '${formatRupiah(cost.interestIfBorrowed)}, beban utang naik '
            'dari ${formatPercent(ratioBefore)} ke '
            '${formatPercent(ratioAfter)}.',
      );
    }

    Future<void> proceed() async {
      await controller.recordContinued(category: DebtCategory.konsumtif);
      ref.invalidate(debtsProvider);
      ref.invalidate(debtSummaryProvider);
      ref.invalidate(decisionsProvider);
      if (!context.mounted) return;

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Routes.ledger, (_) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sudah dicatat di ledger.',
            style: PikirText.body.copyWith(color: PikirColors.onPrimary),
          ),
          backgroundColor: PikirColors.textPrimary,
        ),
      );
    }

    return InterventionOverlay(
      onDark: false,
      showAttribution: false,
      onClose: () => Navigator.of(context).maybePop(),
      // The evidence scrolls; the three choices do not. Three cards of
      // reasoning plus three full-width buttons cannot both fit on a 393x852
      // screen, and CLAUDE.md section 9 will not let the actions be the part
      // that falls off. Someone deciding under stress should never have to
      // scroll to discover that pausing was an option.
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                PikirSpacing.screenHorizontal,
                0,
                PikirSpacing.screenHorizontal,
                16,
              ),
              children: [
          // Amber, with a pause icon and the word "Jeda". Never red.
          const Align(
            alignment: Alignment.centerLeft,
            child: StatusChip(
              status: PikirStatus.caution,
              label: 'Jeda sebentar',
              icon: Icons.pause_circle_outline_rounded,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Kalau ambil cicilan ${formatRupiah(cost.price)}...',
            style: PikirText.headline,
          ),
          const SizedBox(height: PikirSpacing.cardGap),
          _InterestCard(cost: cost),
          const SizedBox(height: PikirSpacing.cardGap),
          _RatioCard(
            ratioBefore: ratioBefore,
            ratioAfter: ratioAfter,
            instalment: instalment,
          ),
                const SizedBox(height: PikirSpacing.cardGap),
                _DelayCard(cost: cost),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PikirSpacing.screenHorizontal,
              4,
              PikirSpacing.screenHorizontal,
              12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Identical width and height, stacked with a consistent gap.
                // No option here is visually demoted relative to the others.
                PikirButtonStack(
                  buttons: [
                    PikirButton(
                      label: 'Tunda dulu, saya nabung',
                      onPressed: postpone,
                    ),
                    PikirButton(
                      label: 'Tanya PIKIR soal ini',
                      variant: PikirButtonVariant.outlined,
                      onPressed: askPikir,
                    ),
                    HoldToConfirmButton(
                      label: 'Saya tetap lanjut',
                      onConfirmed: proceed,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Setelah ini, pinjamanmu otomatis dicatat di ledger supaya '
                  'totalnya kelihatan.',
                  textAlign: TextAlign.center,
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

class _InterestCard extends StatelessWidget {
  const _InterestCard({required this.cost});

  final OpportunityCost cost;

  @override
  Widget build(BuildContext context) {
    return PikirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The number is the hero, and it is the cost, not the purchase.
          Text(
            formatRupiah(cost.interestIfBorrowed),
            style: PikirText.displayNumber.copyWith(
              color: PikirColors.caution,
            ),
          ),
          const SizedBox(height: 2),
          Text('bunga yang kamu bayar', style: PikirText.bodySecondary),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: PikirColors.background,
              borderRadius: BorderRadius.circular(PikirRadius.input),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.rice_bowl_outlined,
                  size: 20,
                  color: PikirColors.accent,
                ),
                const SizedBox(width: 10),
                // Rupiah is abstract to someone who is tired at midnight. A
                // comparison in meals is not.
                Expanded(
                  child: Text(
                    cost.comparison,
                    style: PikirText.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatioCard extends StatelessWidget {
  const _RatioCard({
    required this.ratioBefore,
    required this.ratioAfter,
    required this.instalment,
  });

  final double ratioBefore;
  final double ratioAfter;
  final int instalment;

  @override
  Widget build(BuildContext context) {
    final over = ratioAfter > DebtSummary.safeThreshold;

    return PikirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Forced to caution even when the ratio is over the threshold. The
          // gauge would otherwise derive danger and paint this red, which is
          // exactly what this flow must not do.
          ThresholdGauge(
            value: ratioAfter,
            threshold: DebtSummary.safeThreshold,
            caption: 'beban utangmu setelah cicilan ini',
            status: PikirStatus.caution,
            statusLabel: over ? 'Di atas batas aman' : 'Masih di bawah batas',
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.trending_up_rounded,
                size: 18,
                color: PikirColors.caution,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Naik dari ${formatPercent(ratioBefore)}. '
                  '${over ? 'Di atas batas aman.' : 'Masih di bawah batas aman.'}',
                  // Amber, not red, and the meaning is in the words as much
                  // as in the colour.
                  style: PikirText.body.copyWith(color: PikirColors.caution),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Cicilan baru ${formatRupiah(instalment)} per bulan.',
            style: PikirText.captionSecondary,
          ),
        ],
      ),
    );
  }
}

class _DelayCard extends StatelessWidget {
  const _DelayCard({required this.cost});

  final OpportunityCost cost;

  @override
  Widget build(BuildContext context) {
    return PikirCard(
      outlined: true,
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
            child: const Icon(
              Icons.calendar_month_outlined,
              color: PikirColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kalau ditunda ${cost.daysToSave} hari',
                  style: PikirText.title,
                ),
                const SizedBox(height: 4),
                Text(
                  'Kamu bisa kumpulkan '
                  '${formatRupiah(cost.price)} tanpa bunga sama '
                  'sekali.',
                  style: PikirText.bodySecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
