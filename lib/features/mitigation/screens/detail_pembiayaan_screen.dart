import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/rupiah.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/mitigation.dart';
import '../../../data/providers.dart';
import '../../chat/chat_handover.dart';

/// The full cost of one financing route, itemised.
///
/// Nothing hidden, no asterisks, no fee introduced later in the flow. If a
/// number is zero it is still listed as zero, because a blank line is where a
/// charge hides.
class DetailPembiayaanScreen extends ConsumerWidget {
  const DetailPembiayaanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(title: const Text('Rincian pembiayaan')),
      body: FutureBuilder<FinancingOption?>(
        future: id == null
            ? Future.value(null)
            : ref.read(mitigationRepositoryProvider).financingOption(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const PikirCardLoading(height: 300);
          }

          final option = snapshot.data;
          if (option == null) {
            return Padding(
              padding: const EdgeInsets.all(PikirSpacing.screenHorizontal),
              child: Text(
                'Rincian ini belum bisa ditampilkan.',
                style: PikirText.bodySecondary,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              PikirSpacing.screenHorizontal,
              0,
              PikirSpacing.screenHorizontal,
              32,
            ),
            children: [
              Text(option.name, style: PikirText.headline),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusChip(
                    status: PikirStatus.safe,
                    label: option.disbursementLabel,
                    icon: Icons.schedule_rounded,
                  ),
                  StatusChip(
                    status: PikirStatus.neutral,
                    label: option.trustBadge,
                    icon: Icons.verified_outlined,
                    quiet: true,
                  ),
                ],
              ),
              const SizedBox(height: PikirSpacing.cardGap),
              PikirCard(
                hero: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatRupiah(option.totalReturn),
                      style: PikirText.displayNumber,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'total yang kamu kembalikan',
                      style: PikirText.bodySecondary,
                    ),
                    const SizedBox(height: 18),
                    _CostLine(
                      label: 'Pokok pinjaman',
                      value: option.principal,
                    ),
                    const Divider(height: 22),
                    _CostLine(label: 'Jasa atau bunga', value: option.serviceFee),
                    const Divider(height: 22),
                    // Listed even at zero. A missing line is where a fee
                    // hides.
                    _CostLine(label: 'Biaya admin', value: option.adminFee),
                  ],
                ),
              ),
              const SizedBox(height: PikirSpacing.cardGap),
              PikirCard(
                color: PikirColors.cautionContainer,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: PikirColors.caution,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Perlu kamu tahu', style: PikirText.title),
                          const SizedBox(height: 6),
                          Text(option.cautionLine, style: PikirText.body),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (option.sourceLabel != null) ...[
                const SizedBox(height: PikirSpacing.cardGap),
                SourceChip(label: option.sourceLabel!),
              ],
              const SizedBox(height: 24),
              PikirButton(
                label: 'Tanya lebih lanjut',
                variant: PikirButtonVariant.outlined,
                onPressed: () => openChatWithContext(
                  context,
                  ref,
                  label: 'rute ${option.name}',
                  detail:
                      '${option.name}, pokok '
                      '${formatRupiah(option.principal)}, total kembali '
                      '${formatRupiah(option.totalReturn)}, cair '
                      '${option.disbursementLabel}.',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CostLine extends StatelessWidget {
  const _CostLine({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: PikirText.body)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            formatRupiah(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PikirText.number,
          ),
        ),
      ],
    );
  }
}
