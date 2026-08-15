import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../intervention_state.dart';
import '../widgets/intervention_overlay.dart';

/// The local fallback, shown when the analysis cannot answer in time.
///
/// Mandatory, not a nicety. This screen is covering another app, so failing
/// silently would leave the user staring at a spinner on a phone they cannot
/// use. It carries no error code, no technical wording, and no red: from the
/// user's side nothing has gone wrong, and the question worth asking is the
/// same one the online path would have asked.
///
/// The breathing prompt is the whole intervention when the numbers are
/// unavailable. Ten seconds is often enough for the urgency to pass.
class FallbackLuringScreen extends ConsumerStatefulWidget {
  const FallbackLuringScreen({super.key});

  @override
  ConsumerState<FallbackLuringScreen> createState() =>
      _FallbackLuringScreenState();
}

class _FallbackLuringScreenState extends ConsumerState<FallbackLuringScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;

  @override
  void initState() {
    super.initState();
    // A slow, continuous pulse to breathe along with. Deliberately not a
    // countdown to a deadline: nothing expires, and nothing is lost by
    // watching it for a while.
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InterventionOverlay(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PikirSpacing.screenHorizontal,
        ),
        child: Column(
          children: [
            const Spacer(),
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: PikirColors.onPrimary.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 20),
            Text(
              'Internet mati',
              textAlign: TextAlign.center,
              style: PikirText.headlineLarge.copyWith(
                color: PikirColors.onPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Yakin mau ngutang sekarang? Coba tarik napas 10 detik dan cek '
              'dulu saldomu.',
              textAlign: TextAlign.center,
              style: PikirText.body.copyWith(
                height: 1.6,
                color: PikirColors.onPrimary.withValues(alpha: 0.92),
              ),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _breath,
              builder: (context, child) {
                final scale = 0.82 + (_breath.value * 0.28);
                return Column(
                  children: [
                    Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: PikirColors.onPrimary.withValues(
                            alpha: 0.14,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: PikirColors.onPrimary.withValues(
                              alpha: 0.55,
                            ),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _breath.status == AnimationStatus.reverse
                          ? 'Hembuskan...'
                          : 'Tarik napas...',
                      style: PikirText.body.copyWith(
                        color: PikirColors.onPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            // Two equal buttons. Continuing is not hidden and not shamed; the
            // app has just told the user it cannot check anything right now,
            // so it is in no position to insist.
            PikirButtonRow(
              buttons: [
                PikirButton(
                  label: 'Oke, saya tunda',
                  variant: PikirButtonVariant.overlayFilled,
                  // Postponing means not going back to the loan app, so this
                  // one lands on the dashboard rather than handing the app
                  // underneath straight back.
                  onPressed: () {
                    ref.read(interventionControllerProvider.notifier).reset();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.beranda,
                      (_) => false,
                    );
                  },
                ),
                PikirButton(
                  label: 'Lanjut ke aplikasi',
                  variant: PikirButtonVariant.overlayOutlined,
                  onPressed: () => leaveIntervention(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
