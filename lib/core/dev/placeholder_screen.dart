import 'package:flutter/material.dart';

import '../router/routes.dart';
import '../theme/text_styles.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// A labelled stand-in for a screen that has a route but no content yet.
///
/// Phase 1 wires every destination so navigation can be walked end to end
/// before any screen is built. This deliberately does not look finished: it
/// states what belongs here and which document specifies it, so an unbuilt
/// screen is never mistaken for a built one during a demo.
///
/// Remove this along with the last placeholder that uses it.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.reference,
    required this.note,
    this.showBottomNav = false,
    this.overlay = false,
  });

  /// The screen name, as used in docs/ai/SCREENS.md.
  final String title;

  /// Where it is specified, such as "SCREENS.md layar 12 - P0".
  final String reference;

  /// One line on what this screen has to do.
  final String note;

  /// Whether the finished screen carries the bottom navigation.
  final bool showBottomNav;

  /// Whether the finished screen is a full-screen overlay drawn on top of
  /// another app, and therefore must carry a visible PIKIR mark.
  final bool overlay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: overlay
          ? PikirColors.primary
          : PikirColors.background,
      appBar: overlay
          ? null
          : AppBar(
              title: Text(title),
              backgroundColor: PikirColors.background,
            ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PikirSpacing.screenHorizontal,
            vertical: PikirSpacing.cardGap,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (overlay) ...[
                PikirMark(onDark: true),
                const SizedBox(height: PikirSpacing.cardGap),
              ],
              PikirCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StatusChip(
                      status: PikirStatus.neutral,
                      label: 'Belum dibuat',
                    ),
                    const SizedBox(height: 14),
                    Text(title, style: PikirText.headline),
                    const SizedBox(height: 8),
                    Text(note, style: PikirText.bodySecondary),
                    const SizedBox(height: 14),
                    Text(reference, style: PikirText.captionSecondary),
                  ],
                ),
              ),
              const Spacer(),
              if (overlay) ...[
                const PikirOverlayAttribution(),
                const SizedBox(height: PikirSpacing.cardGap),
              ],
              // The splash placeholder is the root route and has nothing to
              // pop back to, so it offers the map instead of a dead end.
              Builder(
                builder: (context) {
                  final navigator = Navigator.of(context);
                  final canPop = navigator.canPop();
                  return PikirButton(
                    label: canPop ? 'Kembali' : 'Buka peta layar',
                    variant: overlay
                        ? PikirButtonVariant.overlayFilled
                        : PikirButtonVariant.outlined,
                    onPressed: () => canPop
                        ? navigator.pop()
                        : navigator.pushNamed(Routes.petaLayar),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: showBottomNav
          ? PikirBottomNav(
              current: null,
              onSelect: (_) {},
              onTanyaPikir: () {},
            )
          : null,
    );
  }
}
