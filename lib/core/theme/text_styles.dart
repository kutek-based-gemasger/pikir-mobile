import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// Typography for PIKIR.
///
/// CLAUDE.md section 5: display number 40-44sp, headline 26-28sp, title
/// 18-20sp, body 16sp minimum, caption 13sp minimum. Nothing smaller than
/// 13sp anywhere, including legal and source text.
///
/// The bundled font is a single variable file, so weight is applied through
/// the `wght` axis with [FontVariation] as well as [FontWeight]. Setting only
/// [FontWeight] would leave the renderer free to synthesise a fake bold.
abstract final class PikirText {
  static const family = 'PlusJakartaSans';

  static TextStyle _style({
    required double size,
    required int weight,
    double height = 1.4,
    bool tabular = false,
    Color color = PikirColors.textPrimary,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      height: height,
      color: color,
      fontWeight: FontWeight.values[(weight ~/ 100) - 1],
      fontVariations: [FontVariation('wght', weight.toDouble())],
      fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    );
  }

  /// The hero figure of a card: an amount, a percentage, a number of days.
  /// On every card the most important figure is the largest element.
  static final displayNumber = _style(
    size: 40,
    weight: 800,
    height: 1.1,
    tabular: true,
  );

  /// The largest display size, for a screen whose entire point is one number.
  static final displayNumberLarge = _style(
    size: 44,
    weight: 800,
    height: 1.1,
    tabular: true,
  );

  /// One per screen: the question or the verdict.
  static final headline = _style(size: 26, weight: 700, height: 1.25);
  static final headlineLarge = _style(size: 28, weight: 700, height: 1.25);

  /// Card titles and list item names.
  static final title = _style(size: 18, weight: 600, height: 1.3);
  static final titleLarge = _style(size: 20, weight: 600, height: 1.3);

  /// All explanatory text. Never smaller than this for content.
  static final body = _style(size: 16, weight: 400);

  /// Body copy in the secondary colour, for sublines and helper text.
  static final bodySecondary = _style(
    size: 16,
    weight: 400,
    color: PikirColors.textSecondary,
  );

  /// Field labels, chips, nav labels.
  static final label = _style(size: 14, weight: 500);

  /// Source lines, disclaimers, fine print. The floor of the type scale.
  static final caption = _style(size: 13, weight: 400);

  static final captionSecondary = _style(
    size: 13,
    weight: 400,
    color: PikirColors.textSecondary,
  );

  /// The single style used by every button in every variant.
  ///
  /// This exists as one value on purpose. CLAUDE.md section 6 rule 3 requires
  /// choice buttons to share identical font weight, so a decline option can
  /// never be quietly set lighter than the option beside it.
  static final button = _style(size: 16, weight: 600, height: 1.2);

  /// Inline numbers inside body text, kept tabular so columns line up.
  static final number = _style(size: 16, weight: 700, tabular: true);
}
