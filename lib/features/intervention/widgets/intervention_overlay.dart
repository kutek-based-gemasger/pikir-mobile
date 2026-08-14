import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';

/// The frame every interception screen sits in.
///
/// These screens are drawn on top of somebody else's app, so CLAUDE.md
/// section 6 rule 9 requires a visible PIKIR mark: an app that covers your
/// screen without saying who it is behaves exactly like the thing this one
/// exists to warn about. The mark and the attribution line are part of the
/// frame rather than something each screen remembers to add.
class InterventionOverlay extends StatelessWidget {
  const InterventionOverlay({
    super.key,
    required this.child,
    this.onDark = true,
    this.showAttribution = true,
    this.onClose,
  });

  final Widget child;

  /// Green full-bleed, for the screens drawn directly over another app.
  final bool onDark;

  final bool showAttribution;

  /// An explicit way out.
  ///
  /// Always full size and full contrast when present. The exit from an
  /// interception is never hidden, shrunk, or made to feel like a mistake.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: onDark
          ? PikirColors.primary
          : PikirColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PikirSpacing.screenHorizontal,
                8,
                8,
                0,
              ),
              child: Row(
                children: [
                  PikirMark(size: 36, onDark: onDark),
                  const Spacer(),
                  if (onClose != null)
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close_rounded),
                      color: onDark
                          ? PikirColors.onPrimary
                          : PikirColors.textPrimary,
                      iconSize: 26,
                      tooltip: 'Tutup',
                      constraints: const BoxConstraints(
                        minWidth: PikirSpacing.minTapTarget,
                        minHeight: PikirSpacing.minTapTarget,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: child),
            if (showAttribution)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PikirSpacing.screenHorizontal,
                  8,
                  PikirSpacing.screenHorizontal,
                  12,
                ),
                child: PikirOverlayAttribution(onDark: onDark),
              ),
          ],
        ),
      ),
    );
  }
}
