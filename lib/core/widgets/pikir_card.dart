import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The standard white surface.
///
/// Exists so radius, padding, and the single shadow are spelled once rather
/// than re-typed on every screen. CLAUDE.md section 9 counts scattered
/// literals as a screen not being done.
///
/// A card carries either the soft shadow or a 1dp outline, never both.
class PikirCard extends StatelessWidget {
  const PikirCard({
    super.key,
    required this.child,
    this.hero = false,
    this.outlined = false,
    this.padding,
    this.color,
    this.onTap,
  });

  final Widget child;

  /// Hero and summary cards use the larger 28dp radius.
  final bool hero;

  /// Swaps the shadow for a 1dp outline.
  final bool outlined;

  final EdgeInsetsGeometry? padding;

  final Color? color;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(
      hero ? PikirRadius.hero : PikirRadius.card,
    );

    final content = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(PikirSpacing.cardPadding),
      decoration: BoxDecoration(
        color: color ?? PikirColors.surface,
        borderRadius: radius,
        border: outlined ? Border.all(color: PikirColors.outline) : null,
        boxShadow: outlined ? null : PikirShadow.soft,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      ),
    );
  }
}
