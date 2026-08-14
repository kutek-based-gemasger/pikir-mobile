import 'package:flutter/widgets.dart';

/// Design tokens for PIKIR.
///
/// CLAUDE.md section 5: do not invent colors, sizes, or fonts outside this
/// list. If a screen seems to need a value that is not here, that is a signal
/// the design is drifting, not a signal to add a token.

/// The palette. There is deliberately no blue token and no dark theme:
/// secondary actions are outlined green.
abstract final class PikirColors {
  static const primary = Color(0xFF0B6B3A);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFDCF2E4);

  /// Amber from the logo dot. Used for the pause state and brand highlights.
  /// Never on a button that leads the user toward borrowing money.
  static const accent = Color(0xFFF2B441);

  static const safe = Color(0xFF1E9E5A);
  static const caution = Color(0xFFE8A33D);
  static const cautionContainer = Color(0xFFFFF7E6);

  /// Used sparingly, only for genuinely suspicious content. Over-warning
  /// destroys trust. Never used anywhere in the Mode Tahan reflection flow.
  static const danger = Color(0xFFD64545);
  static const dangerContainer = Color(0xFFFDECEC);

  static const background = Color(0xFFF6F8F5);
  static const surface = Color(0xFFFFFFFF);
  static const outline = Color(0xFFE3E8E2);
  static const textPrimary = Color(0xFF10231A);
  static const textSecondary = Color(0xFF5C6B62);
}

/// Corner radii. Rounded and sharp corners are never mixed in one view; the
/// only exception is a chat bubble, which squares one corner toward its
/// speaker.
abstract final class PikirRadius {
  static const card = 24.0;
  static const hero = 28.0;
  static const button = 28.0;
  static const chip = 20.0;
  static const input = 16.0;
  static const sheet = 28.0;
}

/// Spacing and metrics.
abstract final class PikirSpacing {
  static const screenHorizontal = 20.0;
  static const cardPadding = 20.0;
  static const cardGap = 16.0;

  /// Gap between stacked choice buttons.
  static const buttonGap = 12.0;

  /// Nothing tappable is ever smaller than this.
  static const minTapTarget = 48.0;

  /// Every PikirButton and HoldToConfirmButton is exactly this tall, in every
  /// variant. See CLAUDE.md section 6 rule 3.
  static const buttonHeight = 56.0;

  /// Selectable option cards are at least this tall.
  static const optionCardMinHeight = 96.0;
}

/// The one and only shadow in the app: y 4, blur 20, black at 6 percent.
/// A surface gets either this shadow or a 1dp outline, never both.
abstract final class PikirShadow {
  static const soft = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 4),
      blurRadius: 20,
    ),
  ];
}

/// How long a deliberate-friction hold lasts. The friction lives in the
/// gesture, never in shrinking or fading the option being held.
const kHoldToConfirmDuration = Duration(seconds: 5);
