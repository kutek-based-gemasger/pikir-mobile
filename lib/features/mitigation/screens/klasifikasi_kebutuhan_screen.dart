import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/mitigation.dart';
import '../mitigation_state.dart';
import '../widgets/step_indicator.dart';

/// Step one: what is the money for.
///
/// This single question is what splits the whole feature into three, and the
/// split is the product's argument. A want goes to the cost of waiting, an
/// emergency goes to assistance and rights, and only working capital ever
/// reaches a financing option. Nothing here is marked recommended or popular,
/// and tapping advances immediately.
class KlasifikasiKebutuhanScreen extends ConsumerWidget {
  const KlasifikasiKebutuhanScreen({super.key});

  static const _icons = {
    NeedTopic.kesehatan: Icons.local_hospital_outlined,
    NeedTopic.kebutuhanHidup: Icons.rice_bowl_outlined,
    NeedTopic.pendidikan: Icons.school_outlined,
    NeedTopic.modalAtauAlatKerja: Icons.storefront_outlined,
    NeedTopic.keinginan: Icons.shopping_bag_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PikirScaffold(
      currentTab: PikirTab.mitigasi,
      appBar: AppBar(title: const Text('Cari jalan keluar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          PikirSpacing.screenHorizontal,
          0,
          PikirSpacing.screenHorizontal,
          24,
        ),
        children: [
          // Two steps is the honest floor here: only the productive branch
          // asks a third question, and the user has not chosen a branch yet.
          const StepIndicator(step: 1, total: 2),
          const SizedBox(height: 20),
          Text('Uangnya buat apa?', style: PikirText.headlineLarge),
          const SizedBox(height: 8),
          Text('Pilih yang paling dekat.', style: PikirText.bodySecondary),
          const SizedBox(height: 20),
          for (final topic in NeedTopic.values) ...[
            OptionCard(
              icon: _icons[topic]!,
              label: topic.label,
              example: topic.example,
              onTap: () {
                ref
                    .read(mitigationControllerProvider.notifier)
                    .chooseTopic(topic);
                Navigator.of(context).pushNamed(Routes.mitigasiNominal);
              },
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          Text(
            'Tidak ada jawaban yang salah. Kami tidak menyimpan ini ke mana '
            'pun selain HP-mu.',
            style: PikirText.captionSecondary,
          ),
        ],
      ),
    );
  }
}
