import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../chat/chat_handover.dart';
import '../mitigation_state.dart';
import '../widgets/route_card.dart';

/// Assistance and rights, on the urgent-need branch only.
///
/// This screen shows no loan product, at any interest rate, from any
/// provider. CLAUDE.md section 6 rule 7 calls that a hard product rule, and
/// the data layer enforces it too: a MitigationResult on this branch cannot
/// physically hold a financing option. What somebody in a medical emergency
/// needs is the programme they are already entitled to, not a faster way into
/// debt.
class HasilBantuanScreen extends ConsumerWidget {
  const HasilBantuanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mitigationControllerProvider);
    final programs = state.result?.assistancePrograms ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Yang bisa kamu urus')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          PikirSpacing.screenHorizontal,
          0,
          PikirSpacing.screenHorizontal,
          32,
        ),
        children: [
          PikirCard(
            hero: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StatusChip(
                  status: PikirStatus.safe,
                  label: 'Tanpa utang',
                  icon: Icons.volunteer_activism_outlined,
                ),
                const SizedBox(height: 14),
                Text(
                  'Ini hakmu, bukan pinjaman',
                  style: PikirText.headline,
                ),
                const SizedBox(height: 8),
                Text(
                  'Untuk kebutuhan mendesak, ada program yang memang '
                  'disediakan negara. Tidak ada yang perlu dikembalikan.',
                  style: PikirText.bodySecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: PikirSpacing.cardGap),
          if (programs.isEmpty)
            PikirCard(
              outlined: true,
              child: Text(
                'Belum ada program yang bisa ditampilkan.',
                style: PikirText.bodySecondary,
              ),
            )
          else
            for (final program in programs) ...[
              AssistanceRouteCard(
                program: program,
                onDetail: () => Navigator.of(context).pushNamed(
                  Routes.mitigasiDetailBantuan,
                  arguments: program.id,
                ),
                onAsk: () => openChatWithContext(
                  context,
                  ref,
                  label: 'program ${program.name}',
                  detail:
                      '${program.name} dari ${program.provider}. '
                      '${program.whatYouGet}',
                ),
              ),
              const SizedBox(height: 14),
            ],
          const SizedBox(height: 6),
          PikirCard(
            outlined: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.support_agent_outlined,
                  color: PikirColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ditolak atau dipersulit?', style: PikirText.title),
                      const SizedBox(height: 4),
                      Text(
                        'Bantuan ini hakmu. Kalau dipersulit, kamu bisa '
                        'mengadu ke kantor kelurahan atau Dinas Sosial.',
                        style: PikirText.bodySecondary,
                      ),
                    ],
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
