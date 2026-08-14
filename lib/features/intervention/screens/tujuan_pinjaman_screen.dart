import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/intervention.dart';
import '../intervention_state.dart';
import '../widgets/intervention_overlay.dart';

/// Shown the instant a whitelisted loan app opens.
///
/// One question, two answers, and a way out. The urgent answer hands straight
/// over to mitigation without asking anything else: somebody whose child is
/// ill should not have to fill in a form about what they want to buy. Only the
/// consumptive answer goes on to ask for an item name.
class TujuanPinjamanScreen extends ConsumerWidget {
  const TujuanPinjamanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(interventionControllerProvider.notifier);

    void choose(BorrowReason reason) {
      controller
        ..startLoanApp()
        ..chooseReason(reason);

      // Urgent or working capital goes to mitigation, which never shows a
      // loan product on those branches. A want goes on to the item question.
      final route = reason == BorrowReason.urgentAtauModal
          ? Routes.mitigasiKebutuhan
          : Routes.intervensiBarang;
      Navigator.of(context).pushNamed(route);
    }

    return InterventionOverlay(
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: PikirSpacing.screenHorizontal,
        ),
        children: [
          const SizedBox(height: 12),
          Text(
            'Kamu mau ngutang buat apa?',
            style: PikirText.headlineLarge.copyWith(
              color: PikirColors.onPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Jawab satu hal dulu, 10 detik saja.',
            style: PikirText.body.copyWith(
              color: PikirColors.onPrimary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 28),
          // Neither card is pre-selected and neither is marked as the expected
          // answer. Tapping advances immediately.
          for (final reason in BorrowReason.values) ...[
            OptionCard(
              icon: reason == BorrowReason.urgentAtauModal
                  ? Icons.medical_services_outlined
                  : Icons.shopping_bag_outlined,
              label: reason.label,
              example: reason.example,
              onTap: () => choose(reason),
            ),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 10),
          // The way out keeps full size and full contrast. It is not a bare
          // text link and it is not worded to make leaving feel like a
          // failure.
          PikirButton(
            label: 'Lanjut ke aplikasi',
            variant: PikirButtonVariant.overlayOutlined,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(height: 12),
          Text(
            'Pilihan tetap di tanganmu.',
            textAlign: TextAlign.center,
            style: PikirText.caption.copyWith(
              color: PikirColors.onPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
