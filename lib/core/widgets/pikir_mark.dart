import 'package:flutter/material.dart';

import '../theme/text_styles.dart';
import '../theme/tokens.dart';

/// The PIKIR brand mark.
///
/// CLAUDE.md section 6 rule 9: overlay screens always carry a visible mark so
/// the user knows which app is speaking. An app that draws over other apps
/// without identifying itself behaves like the thing it is protecting people
/// against, so every interception surface must show this.
class PikirMark extends StatelessWidget {
  const PikirMark({
    super.key,
    this.size = 40,
    this.onDark = false,
    this.showWordmark = true,
  });

  /// Diameter of the logo plate.
  final double size;

  /// Renders for a green background: white plate, white wordmark.
  final bool onDark;

  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final wordmarkColor = onDark
        ? PikirColors.onPrimary
        : PikirColors.primary;

    return Semantics(
      label: 'PIKIR',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // TODO(design): replace with the real logo asset, a green
                // magnifier with "Rp" in the lens and an amber dot.
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: onDark
                        ? PikirColors.surface
                        : PikirColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    size: size * 0.55,
                    color: PikirColors.primary,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: size * 0.24,
                    height: size * 0.24,
                    decoration: const BoxDecoration(
                      color: PikirColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showWordmark) ...[
            const SizedBox(width: 8),
            Text(
              'PIKIR',
              style: PikirText.title.copyWith(
                color: wordmarkColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The attribution line for a full-screen overlay drawn on top of another
/// app, such as "Layar ini dari aplikasi PIKIR."
class PikirOverlayAttribution extends StatelessWidget {
  const PikirOverlayAttribution({super.key, this.onDark = true});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Layar ini dari aplikasi PIKIR.',
      textAlign: TextAlign.center,
      style: PikirText.caption.copyWith(
        color: onDark
            ? PikirColors.onPrimary.withValues(alpha: 0.85)
            : PikirColors.textSecondary,
      ),
    );
  }
}
