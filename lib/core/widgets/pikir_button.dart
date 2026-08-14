import 'package:flutter/material.dart';

import '../theme/text_styles.dart';
import '../theme/tokens.dart';

/// The visual treatments a [PikirButton] can take.
///
/// Every variant is the same height, the same radius, and the same font
/// weight. They differ only in fill and outline colour. That is deliberate:
/// CLAUDE.md section 6 rule 3 forbids shrinking, fading, or greying out the
/// option that declines or exits, so there is no "weak" variant to reach for.
enum PikirButtonVariant {
  /// Filled brand green. One primary action per screen, and never on a button
  /// that leads the user toward borrowing money.
  filled,

  /// Outlined green. The secondary action. There is no blue in this app.
  outlined,

  /// Outlined neutral grey, for an option that is neither encouraged nor
  /// discouraged, such as "Saya tetap lanjut".
  neutral,

  /// White fill with green text, for use on a green overlay.
  overlayFilled,

  /// White outline with white text, for use on a green overlay.
  overlayOutlined,
}

/// The one button in PIKIR.
///
/// Defaults to full width. When two or more choices sit beside each other,
/// wrap them in a [PikirButtonRow] so equal width is structural rather than
/// something a future edit can quietly break.
class PikirButton extends StatelessWidget {
  const PikirButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PikirButtonVariant.filled,
    this.icon,
    this.helperText,
  });

  final String label;

  /// Null renders the button as unavailable.
  ///
  /// Never pass null to an option that declines, exits, or dismisses. Those
  /// must stay live and at full contrast at all times.
  final VoidCallback? onPressed;

  final PikirButtonVariant variant;

  /// Optional leading icon. A status is never carried by an icon alone, so
  /// this is decoration beside the label, not a replacement for it.
  final IconData? icon;

  /// A short line rendered beneath the button, such as
  /// "tekan dan tahan 5 detik". Kept at caption size, never below 13sp.
  final String? helperText;

  bool get _enabled => onPressed != null;

  Color get _background => switch (variant) {
    PikirButtonVariant.filled => PikirColors.primary,
    PikirButtonVariant.outlined => PikirColors.surface,
    PikirButtonVariant.neutral => PikirColors.surface,
    PikirButtonVariant.overlayFilled => PikirColors.surface,
    PikirButtonVariant.overlayOutlined => Colors.transparent,
  };

  Color get _foreground => switch (variant) {
    PikirButtonVariant.filled => PikirColors.onPrimary,
    PikirButtonVariant.outlined => PikirColors.primary,
    PikirButtonVariant.neutral => PikirColors.textPrimary,
    PikirButtonVariant.overlayFilled => PikirColors.primary,
    PikirButtonVariant.overlayOutlined => PikirColors.onPrimary,
  };

  Color? get _border => switch (variant) {
    PikirButtonVariant.filled => null,
    PikirButtonVariant.outlined => PikirColors.primary,
    PikirButtonVariant.neutral => PikirColors.outline,
    PikirButtonVariant.overlayFilled => null,
    PikirButtonVariant.overlayOutlined => PikirColors.onPrimary,
  };

  @override
  Widget build(BuildContext context) {
    final border = _border;

    final button = Semantics(
      button: true,
      enabled: _enabled,
      label: label,
      child: Material(
        color: _enabled ? _background : _background.withValues(alpha: 0.5),
        // Material accepts either borderRadius or shape, never both, so the
        // radius travels inside the shape and a borderless variant simply
        // uses BorderSide.none.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PikirRadius.button),
          side: border == null
              ? BorderSide.none
              : BorderSide(
                  color: _enabled ? border : border.withValues(alpha: 0.5),
                  width: 1.5,
                ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(PikirRadius.button),
          child: SizedBox(
            height: PikirSpacing.buttonHeight,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: _foreground),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: PikirText.button.copyWith(color: _foreground),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (helperText == null) return button;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        button,
        const SizedBox(height: 6),
        Text(
          helperText!,
          textAlign: TextAlign.center,
          style: PikirText.captionSecondary,
        ),
      ],
    );
  }
}

/// Lays out two or more choice buttons at exactly equal width.
///
/// Use this instead of a hand-rolled [Row] wherever the user is choosing
/// between options. Equal width then comes from the layout itself, so a later
/// edit cannot make the decline option narrower without deleting this widget
/// and being obvious about it.
class PikirButtonRow extends StatelessWidget {
  const PikirButtonRow({super.key, required this.buttons});

  final List<PikirButton> buttons;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0) const SizedBox(width: PikirSpacing.buttonGap),
            Expanded(child: buttons[i]),
          ],
        ],
      ),
    );
  }
}

/// Stacks choice buttons full width with a consistent gap.
///
/// Full width already guarantees equal width; this exists so the gap is not
/// respelled on every screen.
class PikirButtonStack extends StatelessWidget {
  const PikirButtonStack({super.key, required this.buttons});

  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(height: PikirSpacing.buttonGap),
          buttons[i],
        ],
      ],
    );
  }
}
