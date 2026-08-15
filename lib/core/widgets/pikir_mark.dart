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
          PikirLogo(size: size, onDark: onDark),
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

/// The shield on its own, without the wordmark.
///
/// The mark is green, so on a green ground only the pale head inside it would
/// carry. [onDark] puts it on a light plate for exactly that case rather than
/// leaving it to half disappear.
class PikirLogo extends StatelessWidget {
  const PikirLogo({super.key, this.size = 40, this.onDark = false});

  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      'assets/brand/pikir_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      // Announced once by the PikirMark around it, or by the screen using it.
      excludeFromSemantics: true,
    );

    if (!onDark) return SizedBox(width: size, height: size, child: logo);

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.16),
      decoration: const BoxDecoration(
        color: PikirColors.surface,
        shape: BoxShape.circle,
      ),
      child: logo,
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
