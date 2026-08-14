import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/rupiah.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../chat/chat_handover.dart';
import '../mitigation_state.dart';

/// The cost of waiting, on the consumptive branch only.
///
/// Two things are deliberately absent. There is no financing option, because
/// a want is not a financing problem. And there is no social assistance
/// either: sending somebody to the Dinas Sosial because they would like a new
/// phone would be both useless and insulting.
///
/// Nothing here is red and nothing scolds. Wanting things is not a character
/// flaw, and the screen's only job is to put the price of borrowing next to
/// the price of waiting and then get out of the way.
class HasilKonsumtifScreen extends ConsumerWidget {
  const HasilKonsumtifScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mitigationControllerProvider);
    final cost = state.result?.opportunityCost;
    final amount = state.draft.amount ?? cost?.price ?? 0;

    if (cost == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pilihanmu')),
        body: const PikirCardLoading(height: 300),
      );
    }

    final perDay = cost.daysToSave == 0
        ? amount
        : (amount / cost.daysToSave).ceil();

    return Scaffold(
      appBar: AppBar(title: const Text('Pilihanmu')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          PikirSpacing.screenHorizontal,
          0,
          PikirSpacing.screenHorizontal,
          32,
        ),
        children: [
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
            'Kalau ${cost.itemName.toLowerCase()} ini dibeli sekarang',
            style: PikirText.headline,
          ),
          const SizedBox(height: PikirSpacing.cardGap),
          PikirCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatRupiah(cost.interestIfBorrowed),
                  style: PikirText.displayNumber.copyWith(
                    color: PikirColors.caution,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'bunga yang kamu bayar kalau nyicil',
                  style: PikirText.bodySecondary,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
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
                      Expanded(
                        child: Text(cost.comparison, style: PikirText.body),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PikirSpacing.cardGap),
          PikirCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kalau ditunda ${cost.daysToSave} hari',
                  style: PikirText.title,
                ),
                const SizedBox(height: 10),
                Text(
                  formatRupiah(perDay),
                  style: PikirText.displayNumber.copyWith(
                    color: PikirColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text('disisihkan per hari', style: PikirText.bodySecondary),
                const SizedBox(height: 12),
                Text(
                  'Kamu bisa kumpulkan ${formatRupiah(amount)} tanpa bunga '
                  'sama sekali.',
                  style: PikirText.body,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Two equal actions. Neither is a loan, and neither is worded to
          // make the user feel judged for wanting the thing.
          PikirButtonStack(
            buttons: [
              PikirButton(
                label: 'Atur target menabung',
                onPressed: () => Navigator.of(
                  context,
                ).pushNamed(Routes.danaDaruratHitung),
              ),
              PikirButton(
                label: 'Tanya lebih lanjut',
                variant: PikirButtonVariant.outlined,
                onPressed: () => openChatWithContext(
                  context,
                  ref,
                  label: 'rencana beli ${cost.itemName}',
                  detail:
                      '${cost.itemName}, ${formatRupiah(amount)}. Kalau '
                      'dicicil, bunganya '
                      '${formatRupiah(cost.interestIfBorrowed)}.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
