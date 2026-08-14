import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/rupiah.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../chat/chat_handover.dart';
import '../mitigation_state.dart';
import '../widgets/route_card.dart';

/// Financing options, on the productive branch only.
///
/// Ordered fastest-first by default, and the screen says so out loud. Cost
/// ordering is available as a switch the user throws, never as the silent
/// default: someone whose motorbike broke this morning cannot use the
/// cheapest option if it arrives in three weeks, and the app should not
/// quietly decide that trade for them.
///
/// No card is promoted. There is no "rekomendasi kami" badge and no
/// highlighted border, because the moment one option is favoured this screen
/// stops being routing and starts being selling.
class HasilProduktifScreen extends ConsumerWidget {
  const HasilProduktifScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mitigationControllerProvider);
    final controller = ref.read(mitigationControllerProvider.notifier);
    final options = state.sortedFinancing;
    final feasibility = state.result?.feasibility;

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
          if (feasibility != null) ...[
            PikirCard(
              outlined: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: PikirColors.safe,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Balik modal sekitar ${feasibility.paybackDays} hari.',
                      style: PikirText.body,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PikirSpacing.cardGap),
          ],
          Text(
            state.sort == FinancingSort.cepatCair
                ? 'Diurutkan dari yang paling cepat cair'
                : 'Diurutkan dari biaya terkecil',
            style: PikirText.captionSecondary,
          ),
          const SizedBox(height: 10),
          PikirSegmented<FinancingSort>(
            segments: [
              for (final sort in FinancingSort.values)
                PikirSegment(value: sort, label: sort.label),
            ],
            selected: state.sort,
            onSelect: controller.setSort,
          ),
          const SizedBox(height: PikirSpacing.cardGap),
          if (options.isEmpty)
            PikirCard(
              outlined: true,
              child: Text(
                'Belum ada pilihan yang bisa ditampilkan.',
                style: PikirText.bodySecondary,
              ),
            )
          else
            for (final option in options) ...[
              FinancingRouteCard(
                option: option,
                onDetail: () => Navigator.of(context).pushNamed(
                  Routes.mitigasiDetailPembiayaan,
                  arguments: option.id,
                ),
                onAsk: () => openChatWithContext(
                  context,
                  ref,
                  label: 'rute ${option.name}',
                  detail:
                      '${option.name}, '
                      '${formatRupiah(option.principal)}, cair '
                      '${option.disbursementLabel}, total kembali '
                      '${formatRupiah(option.totalReturn)}.',
                ),
              ),
              const SizedBox(height: 14),
            ],
          const SizedBox(height: 6),
          Text(
            'Angka di atas perkiraan. Pastikan lagi ke pemberi pinjamannya '
            'sebelum tanda tangan.',
            style: PikirText.captionSecondary,
          ),
        ],
      ),
    );
  }
}
