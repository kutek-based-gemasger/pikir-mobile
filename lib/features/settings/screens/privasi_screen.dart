import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/tanggal.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/chat.dart';
import '../../chat/chat_state.dart';

/// Privacy and data.
///
/// The point of this screen is to be checkable. It says what is kept and what
/// is never kept, in two columns, so the claim can be held against the app's
/// behaviour rather than taken on faith.
class PrivasiScreen extends ConsumerWidget {
  const PrivasiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(chatControllerProvider).session;

    return Scaffold(
      appBar: AppBar(title: const Text('Privasi dan data saya')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          PikirSpacing.screenHorizontal,
          8,
          PikirSpacing.screenHorizontal,
          32,
        ),
        children: [
          PikirCard(
            hero: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: PikirColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: PikirColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'PIKIR tidak punya akun, tidak punya datamu, dan tidak '
                    'pernah terhubung ke rekeningmu.',
                    style: PikirText.title,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PikirSpacing.cardGap),
          const _KeptCard(),
          const SizedBox(height: PikirSpacing.cardGap),
          const _NeverKeptCard(),
          const SizedBox(height: PikirSpacing.cardGap),
          _ExplainerCard(session: session),
          const SizedBox(height: PikirSpacing.cardGap),
          PikirButton(
            label: 'Baca kebijakan lengkap',
            variant: PikirButtonVariant.outlined,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _KeptCard extends StatelessWidget {
  const _KeptCard();

  @override
  Widget build(BuildContext context) {
    return PikirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tersimpan di HP-mu', style: PikirText.title),
          const SizedBox(height: 12),
          // The scan log belongs on this side of the page, not the other.
          // PIKIR keeps a short excerpt of a flagged notification, and the
          // original text of one it dismissed, because the replacement has to
          // be able to show the user the message it took away. Listing it as
          // never stored would be a promise the code does not keep.
          for (final item in const [
            'Catatan utang',
            'Target dana darurat',
            'Profil penghasilan',
            'Cuplikan notifikasi yang ditandai, terhapus otomatis 24 jam',
          ]) ...[
            _Line(text: item, kept: true),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _NeverKeptCard extends StatelessWidget {
  const _NeverKeptCard();

  @override
  Widget build(BuildContext context) {
    return PikirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tidak pernah kami simpan', style: PikirText.title),
          const SizedBox(height: 12),
          for (final item in const [
            'Nama dan nomor HP',
            'Isi notifikasi yang aman, tidak pernah dicatat',
            'Riwayat SMS dan chat lama',
            'Nomor rekening',
          ]) ...[
            _Line(text: item, kept: false),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.text, required this.kept});

  final String text;
  final bool kept;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon and colour together, and the column heading supplies the words.
        // Neither list is readable by colour alone.
        Icon(
          kept ? Icons.check_circle_outline_rounded : Icons.block_outlined,
          size: 20,
          color: kept ? PikirColors.safe : PikirColors.textSecondary,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: PikirText.body)),
      ],
    );
  }
}

class _ExplainerCard extends StatelessWidget {
  const _ExplainerCard({required this.session});

  final ChatSession? session;

  @override
  Widget build(BuildContext context) {
    final remaining = session?.timeUntilDeletion(DateTime.now());

    return PikirCard(
      outlined: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Explainer(
            icon: Icons.wifi_off_rounded,
            text: 'Notifikasi diperiksa tanpa internet.',
          ),
          const SizedBox(height: 14),
          const _Explainer(
            icon: Icons.auto_delete_outlined,
            text: 'Riwayat obrolan terhapus otomatis setelah 24 jam.',
          ),
          if (remaining != null) ...[
            const SizedBox(height: 14),
            // Informational and calm. This is a statement about the app's own
            // housekeeping, not a deadline pressuring the user to act, so it
            // is phrased flatly and carries no urgency.
            _Explainer(
              icon: Icons.schedule_rounded,
              text:
                  'Obrolan terakhirmu akan terhapus dalam '
                  '${formatRemaining(remaining)}.',
            ),
          ],
        ],
      ),
    );
  }
}

class _Explainer extends StatelessWidget {
  const _Explainer({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: PikirColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: PikirText.body)),
      ],
    );
  }
}
