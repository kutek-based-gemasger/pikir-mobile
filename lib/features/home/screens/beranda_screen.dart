import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/rupiah.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/debt_entry.dart';
import '../../../data/queries.dart';
import '../widgets/quick_tile.dart';

/// The home dashboard.
///
/// Two things about this screen are product decisions rather than layout
/// choices. There is no avatar and no name anywhere, because the app has no
/// accounts and the greeting is simply "Halo". And there is no red on it at
/// all: the home screen is where someone lands when nothing is wrong, and
/// colouring it with alarm would make the real warnings mean less.
class BerandaScreen extends ConsumerWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PikirScaffold(
      currentTab: PikirTab.beranda,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: PikirColors.primary,
          onRefresh: () async {
            ref.invalidate(debtSummaryProvider);
            ref.invalidate(emergencyFundProvider);
            ref.invalidate(debtsProvider);
            ref.invalidate(scannerLogsProvider);
            ref.invalidate(billsDueSoonProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              PikirSpacing.screenHorizontal,
              8,
              PikirSpacing.screenHorizontal,
              24,
            ),
            children: const [
              _TopBar(),
              SizedBox(height: PikirSpacing.cardGap),
              _DebtRatioCard(),
              SizedBox(height: PikirSpacing.cardGap),
              _EmergencyFundCard(),
              SizedBox(height: PikirSpacing.cardGap),
              _QuickAccessGrid(),
              SizedBox(height: PikirSpacing.cardGap),
              _ProtectionCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const PikirMark(size: 36, showWordmark: false),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // No name. The app never learns one, and a greeting that
              // pretends otherwise would be the first small lie it tells.
              Text('Halo', style: PikirText.titleLarge),
              Text('Semoga harimu lancar', style: PikirText.captionSecondary),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.pengaturan),
          icon: const Icon(Icons.settings_outlined),
          iconSize: 26,
          tooltip: 'Pengaturan',
          // Settings lives behind this gear, not in the bottom bar. There is
          // no profile tab because there is no profile.
          constraints: const BoxConstraints(
            minWidth: PikirSpacing.minTapTarget,
            minHeight: PikirSpacing.minTapTarget,
          ),
        ),
      ],
    );
  }
}

class _DebtRatioCard extends ConsumerWidget {
  const _DebtRatioCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(debtSummaryProvider);

    return PikirCard(
      hero: true,
      child: summary.when(
        loading: () => const PikirCardLoading(height: 150),
        error: (_, _) => PikirLoadFailure(
          onRetry: () => ref.invalidate(debtSummaryProvider),
        ),
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Beban utangmu bulan ini', style: PikirText.body),
            const SizedBox(height: 14),
            ThresholdGauge(
              value: data.ratio,
              threshold: DebtSummary.safeThreshold,
              caption: 'dari penghasilanmu',
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${formatRupiah(data.monthlyInstalmentTotal)} dari '
                    '${formatRupiah(data.monthlyIncome)}',
                    style: PikirText.captionSecondary,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(Routes.rasioUtang),
                  child: Text(
                    'Lihat rincian',
                    style: PikirText.label.copyWith(
                      color: PikirColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyFundCard extends ConsumerWidget {
  const _EmergencyFundCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fund = ref.watch(emergencyFundProvider);

    return PikirCard(
      child: fund.when(
        loading: () => const PikirCardLoading(height: 150),
        error: (_, _) => PikirLoadFailure(
          onRetry: () => ref.invalidate(emergencyFundProvider),
        ),
        data: (plan) {
          final tier = plan.activeTier;
          final percent = (plan.progressToActiveTier * 100).round();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.savings_outlined,
                    color: PikirColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Dana daruratmu',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PikirText.title,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                formatRupiah(plan.currentAmount),
                style: PikirText.displayNumber,
              ),
              const SizedBox(height: 4),
              Text(
                tier == null
                    ? 'Semua tingkat sudah tercapai.'
                    : 'Kamu sudah $percent% menuju Tingkat ${tier.level}',
                style: PikirText.captionSecondary,
              ),
              const SizedBox(height: 14),
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
                showLabels: false,
              ),
              const SizedBox(height: PikirSpacing.cardGap),
              PikirButton(
                label: 'Catat setoran',
                variant: PikirButtonVariant.outlined,
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.danaDaruratSetoran),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickAccessGrid extends ConsumerWidget {
  const _QuickAccessGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtsProvider);
    final billsDueSoon = ref.watch(billsDueSoonProvider);

    final debtCount = debts.value?.length;
    final billCount = billsDueSoon.value?.length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.98,
      children: [
        QuickTile(
          icon: Icons.alt_route_rounded,
          label: 'Kalkulator Mitigasi',
          subline: 'cari jalan tanpa nambah utang',
          onTap: () =>
              Navigator.of(context).pushNamed(Routes.mitigasiKebutuhan),
        ),
        QuickTile(
          icon: Icons.receipt_long_outlined,
          label: 'Ledger Utang',
          // Counts come from the data, never from a literal typed into the
          // layout, so the tile cannot quietly disagree with the ledger.
          subline: debtCount == null
              ? 'lihat catatan utangmu'
              : '$debtCount catatan aktif',
          onTap: () => Navigator.of(context).pushNamed(Routes.ledger),
        ),
        QuickTile(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Tanya PIKIR',
          subline: 'tanya bebas soal utang',
          onTap: () => Navigator.of(context).pushNamed(Routes.chat),
        ),
        QuickTile(
          icon: Icons.event_note_outlined,
          label: 'Tagihan terdeteksi',
          subline: billCount == null
              ? 'dari notifikasi yang masuk'
              : '$billCount jatuh tempo minggu ini',
          onTap: () => Navigator.of(context).pushNamed(Routes.scannerTagihan),
        ),
      ],
    );
  }
}

class _ProtectionCard extends ConsumerWidget {
  const _ProtectionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerEnabled = ref.watch(scannerEnabledProvider);
    final held = ref.watch(heldNotificationCountProvider);

    final enabled = scannerEnabled.value ?? false;
    final heldCount = held.value;

    return PikirCard(
      outlined: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status perlindungan', style: PikirText.title),
          const SizedBox(height: 12),
          const _ProtectionRow(
            active: true,
            label: 'Deteksi layar aktif',
          ),
          const SizedBox(height: 10),
          _ProtectionRow(
            active: enabled,
            label: enabled
                ? 'Pemindai notifikasi aktif'
                : 'Pemindai notifikasi belum aktif',
            detail: enabled && heldCount != null
                ? '$heldCount peringatan minggu ini'
                : null,
          ),
        ],
      ),
    );
  }
}

class _ProtectionRow extends StatelessWidget {
  const _ProtectionRow({
    required this.active,
    required this.label,
    this.detail,
  });

  final bool active;
  final String label;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colour, icon, and words together. An inactive protection is amber
        // and says so; it is never a red alarm, because nothing has gone
        // wrong, and never colour alone.
        StatusChip(
          status: active ? PikirStatus.safe : PikirStatus.caution,
          label: active ? 'Aktif' : 'Belum aktif',
          quiet: true,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: PikirText.body),
              if (detail != null)
                Text(detail!, style: PikirText.captionSecondary),
            ],
          ),
        ),
      ],
    );
  }
}
