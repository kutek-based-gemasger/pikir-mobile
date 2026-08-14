import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/rupiah.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/emergency_fund.dart';
import '../../../data/queries.dart';

/// The tiered emergency-fund dashboard.
///
/// The whole design of this screen is an argument against a savings app's
/// usual mechanics. Progress is measured against the user's own tiers and
/// nobody else's, the third tier is labelled optional because it is genuinely
/// out of reach on a daily income, and reaching a tier produces a plain
/// status chip rather than a celebration. No streaks, no points, no confetti.
class DanaDaruratScreen extends ConsumerWidget {
  const DanaDaruratScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fund = ref.watch(emergencyFundProvider);

    return PikirScaffold(
      currentTab: PikirTab.danaDarurat,
      appBar: AppBar(
        title: const Text('Targetmu bertingkat'),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(Routes.danaDaruratHitung),
            icon: const Icon(Icons.calculate_outlined),
            tooltip: 'Hitung ulang target',
          ),
        ],
      ),
      body: fund.when(
        loading: () => const PikirCardLoading(height: 400),
        error: (_, _) => Padding(
          padding: const EdgeInsets.all(PikirSpacing.screenHorizontal),
          child: PikirLoadFailure(
            onRetry: () => ref.invalidate(emergencyFundProvider),
          ),
        ),
        // The list scrolls; the primary action does not. Three tier cards
        // plus the reminder run past the bottom of a 393x852 screen, and
        // CLAUDE.md section 9 requires the primary action to stay above the
        // fold, so it is pinned rather than parked at the end of the scroll.
        data: (plan) => Column(
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
                  _HeroCard(plan: plan),
                  const SizedBox(height: PikirSpacing.cardGap),
                  for (final tier in plan.tiers) ...[
                    _TierCard(tier: tier, plan: plan),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 4),
                  _ReminderCard(reminder: plan.reminder),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: PikirColors.background,
              padding: const EdgeInsets.fromLTRB(
                PikirSpacing.screenHorizontal,
                12,
                PikirSpacing.screenHorizontal,
                12,
              ),
              child: PikirButton(
                label: 'Catat setoran',
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.danaDaruratSetoran),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.plan});

  final EmergencyFundPlan plan;

  @override
  Widget build(BuildContext context) {
    final tier = plan.activeTier;
    final percent = (plan.progressToActiveTier * 100).round();

    return PikirCard(
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatRupiah(plan.currentAmount),
            style: PikirText.displayNumberLarge,
          ),
          const SizedBox(height: 4),
          Text(
            tier == null
                ? 'terkumpul. Semua tingkat sudah tercapai.'
                : 'terkumpul, $percent% menuju Tingkat ${tier.level}',
            style: PikirText.bodySecondary,
          ),
          const SizedBox(height: 18),
          TierProgressBar(
            currentAmount: plan.currentAmount,
            tiers: plan.tiers
                .map(
                  (t) => SavingsTier(
                    label: 'Tingkat ${t.level}',
                    target: t.target,
                    optional: t.optional,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.tier, required this.plan});

  final EmergencyFundTier tier;
  final EmergencyFundPlan plan;

  @override
  Widget build(BuildContext context) {
    final reached = plan.currentAmount >= tier.target;
    final active = plan.activeTier?.level == tier.level;

    // Each state carries colour, icon, and words together. "Nanti" is
    // deliberately flat: a tier the user has not started is not a failure and
    // is not marked as one. An optional tier says so on its own card, rather
    // than only in the progress bar's labels, so someone who scrolls straight
    // to the biggest number learns immediately that it is not expected of
    // them.
    final (status, label) = switch ((reached, active, tier.optional)) {
      (true, _, _) => (PikirStatus.safe, 'Sudah tercapai'),
      (_, true, _) => (PikirStatus.safe, 'Sedang dikejar'),
      (_, _, true) => (PikirStatus.neutral, 'Opsional'),
      _ => (PikirStatus.neutral, 'Nanti'),
    };

    return PikirCard(
      outlined: !active,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active || reached
                      ? PikirColors.primaryContainer
                      : PikirColors.background,
                  shape: BoxShape.circle,
                  border: active || reached
                      ? null
                      : Border.all(color: PikirColors.outline),
                ),
                child: Text(
                  '${tier.level}',
                  style: PikirText.number.copyWith(
                    fontSize: 15,
                    color: active || reached
                        ? PikirColors.primary
                        : PikirColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Tingkat ${tier.level}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PikirText.title,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Flexible so a longer status such as "Sudah tercapai" shortens
              // instead of pushing the row past the card edge on a narrow
              // phone or at a larger text size.
              Flexible(
                child: StatusChip(
                  status: status,
                  label: label,
                  quiet: !active,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(formatRupiah(tier.target), style: PikirText.displayNumber),
          const SizedBox(height: 6),
          Text(tier.covers, style: PikirText.bodySecondary),
          if (tier.optional) ...[
            const SizedBox(height: 8),
            Text(
              'Tidak apa-apa kalau belum sampai sini.',
              style: PikirText.captionSecondary,
            ),
          ],
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder});

  final SavingsReminder reminder;

  @override
  Widget build(BuildContext context) {
    return PikirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pengingat menabung', style: PikirText.title),
          const SizedBox(height: 6),
          Text(
            'Pengingat berjalan dari HP-mu sendiri, tanpa server.',
            style: PikirText.captionSecondary,
          ),
          const SizedBox(height: 14),
          // Nothing is pre-selected. The stitch reference highlights
          // "Persentase tiap pemasukan" by default; that is a decision the
          // user has not made yet, so both options start equal here.
          PikirSegmented<SavingsMode>(
            segments: [
              for (final mode in SavingsMode.values)
                PikirSegment(value: mode, label: mode.label),
            ],
            selected: reminder.mode,
            onSelect: (_) =>
                Navigator.of(context).pushNamed(Routes.danaDaruratPengingat),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Flexible(
                child: StatusChip(
                  status: reminder.enabled
                      ? PikirStatus.safe
                      : PikirStatus.neutral,
                  label: reminder.enabled ? 'Aktif' : 'Belum diatur',
                  quiet: true,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: TextButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(Routes.danaDaruratPengingat),
                  child: Text(
                    'Atur pengingat',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PikirText.label.copyWith(
                      color: PikirColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
