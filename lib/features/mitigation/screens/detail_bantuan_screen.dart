import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/mitigation.dart';
import '../../../data/providers.dart';
import '../../chat/chat_handover.dart';

/// How to actually claim one assistance programme.
///
/// The requirements and the steps are the whole point. Knowing a programme
/// exists is useless without knowing which door to knock on and what to bring,
/// which is usually where people give up and take the loan instead.
class DetailBantuanScreen extends ConsumerWidget {
  const DetailBantuanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(title: const Text('Rincian program')),
      body: FutureBuilder<AssistanceProgram?>(
        future: id == null
            ? Future.value(null)
            : ref.read(mitigationRepositoryProvider).assistanceProgram(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const PikirCardLoading(height: 300);
          }

          final program = snapshot.data;
          if (program == null) {
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
              Text(program.name, style: PikirText.headline),
              const SizedBox(height: 6),
              Text(program.provider, style: PikirText.bodySecondary),
              const SizedBox(height: PikirSpacing.cardGap),
              PikirCard(
                hero: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StatusChip(
                      status: PikirStatus.safe,
                      label: 'Tidak perlu dikembalikan',
                      icon: Icons.volunteer_activism_outlined,
                    ),
                    const SizedBox(height: 14),
                    Text(program.whatYouGet, style: PikirText.body),
                  ],
                ),
              ),
              const SizedBox(height: PikirSpacing.cardGap),
              _Section(
                title: 'Syaratnya',
                icon: Icons.checklist_rounded,
                items: program.requirements,
                numbered: false,
              ),
              const SizedBox(height: PikirSpacing.cardGap),
              _Section(
                title: 'Cara mengurusnya',
                icon: Icons.directions_walk_rounded,
                items: program.howToApply,
                numbered: true,
              ),
              if (program.sourceLabel != null) ...[
                const SizedBox(height: PikirSpacing.cardGap),
                SourceChip(label: program.sourceLabel!),
              ],
              const SizedBox(height: 24),
              PikirButton(
                label: 'Tanya lebih lanjut',
                variant: PikirButtonVariant.outlined,
                onPressed: () => openChatWithContext(
                  context,
                  ref,
                  label: 'program ${program.name}',
                  detail:
                      '${program.name} dari ${program.provider}. '
                      '${program.whatYouGet}',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.items,
    required this.numbered,
  });

  final String title;
  final IconData icon;
  final List<String> items;
  final bool numbered;

  @override
  Widget build(BuildContext context) {
    return PikirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: PikirColors.primary),
              const SizedBox(width: 10),
              Text(title, style: PikirText.title),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (numbered)
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: PikirColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: PikirText.caption.copyWith(
                        color: PikirColors.primary,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 20,
                    color: PikirColors.safe,
                  ),
                const SizedBox(width: 12),
                Expanded(child: Text(items[i], style: PikirText.body)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
