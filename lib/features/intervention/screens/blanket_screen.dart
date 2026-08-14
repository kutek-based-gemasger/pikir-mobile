import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../intervention_state.dart';
import '../widgets/intervention_overlay.dart';

/// The instant block over a paylater checkout.
///
/// It appears the moment a checkout screen is detected AND paylater is
/// selected, and stays for the second or two the analysis takes, so it is
/// deliberately almost empty. There is nothing to read and nothing to press:
/// a busy screen here would just be one more thing competing for the
/// attention of someone already mid-purchase.
class BlanketScreen extends ConsumerStatefulWidget {
  const BlanketScreen({super.key});

  @override
  ConsumerState<BlanketScreen> createState() => _BlanketScreenState();
}

class _BlanketScreenState extends ConsumerState<BlanketScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final controller = ref.read(interventionControllerProvider.notifier);

    // Seeded by the demo trigger; a bare visit to this route still analyses
    // something rather than sitting on a spinner forever.
    if (ref.read(interventionControllerProvider).trigger == null) {
      controller.startCheckout(amount: 1250000);
    }

    final outcome = await controller.analyze();
    if (!mounted) return;

    final route = switch (outcome) {
      InterventionOutcome.opportunityCost => Routes.intervensiOpportunityCost,
      InterventionOutcome.recordToLedger => Routes.intervensiCatatLedger,
      InterventionOutcome.offline => Routes.intervensiLuring,
    };

    // Replaced, not pushed: there is nothing useful about being able to go
    // back to a loading screen.
    await Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return InterventionOverlay(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PikirSpacing.screenHorizontal,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                // Amber, the pause colour. Nothing has gone wrong here.
                color: PikirColors.accent,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Sebentar ya',
              textAlign: TextAlign.center,
              style: PikirText.headlineLarge.copyWith(
                color: PikirColors.onPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'PIKIR sedang menghitung biaya cicilanmu.',
              textAlign: TextAlign.center,
              style: PikirText.body.copyWith(
                color: PikirColors.onPrimary.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
