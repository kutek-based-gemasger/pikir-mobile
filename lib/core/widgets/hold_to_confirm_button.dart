import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/text_styles.dart';
import '../theme/tokens.dart';
import 'pikir_button.dart';

/// A button that confirms only after being held for five seconds.
///
/// This is the app's one deliberate-friction control. CLAUDE.md section 6
/// rule 4: the button keeps full size and full contrast the entire time while
/// a progress ring fills. The friction lives in the gesture, never in hiding,
/// shrinking, or fading the option.
///
/// Its metrics are identical to [PikirButton] so it can sit in a
/// [PikirButtonStack] beside ordinary buttons without looking demoted.
///
/// The "N detik lagi" label is not a countdown timer in the sense rule 5
/// forbids. Rule 5 is about manufactured scarcity, an invented deadline
/// pressuring a decision. This number is feedback on a gesture the user is
/// making right now, and it counts toward the thing they asked for.
class HoldToConfirmButton extends StatefulWidget {
  const HoldToConfirmButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.variant = PikirButtonVariant.neutral,
    this.icon = Icons.lock_open_outlined,
    this.helperText = 'tekan dan tahan 5 detik',
  });

  /// The resting label, such as "Saya tetap lanjut".
  final String label;

  final VoidCallback onConfirmed;

  /// Defaults to neutral. Deliberately never [PikirButtonVariant.filled] in
  /// practice: the primary fill is reserved for one action per screen, and an
  /// action needing this much friction is not it.
  final PikirButtonVariant variant;

  final IconData icon;

  final String? helperText;

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: kHoldToConfirmDuration,
      // Releasing springs back quickly. The hold is the friction; making the
      // reset slow as well would be punishing the user for letting go.
      reverseDuration: const Duration(milliseconds: 250),
    )..addStatusListener(_onStatus);
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    HapticFeedback.mediumImpact();
    _controller.value = 0;
    widget.onConfirmed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startHold() {
    HapticFeedback.selectionClick();
    _controller.forward();
  }

  void _cancelHold() {
    if (_controller.isAnimating || _controller.value > 0) {
      _controller.reverse();
    }
  }

  Color get _foreground => switch (widget.variant) {
    PikirButtonVariant.filled => PikirColors.onPrimary,
    PikirButtonVariant.outlined => PikirColors.primary,
    PikirButtonVariant.neutral => PikirColors.textPrimary,
    PikirButtonVariant.overlayFilled => PikirColors.primary,
    PikirButtonVariant.overlayOutlined => PikirColors.onPrimary,
  };

  Color get _background => switch (widget.variant) {
    PikirButtonVariant.filled => PikirColors.primary,
    PikirButtonVariant.outlined => PikirColors.surface,
    PikirButtonVariant.neutral => PikirColors.surface,
    PikirButtonVariant.overlayFilled => PikirColors.surface,
    PikirButtonVariant.overlayOutlined => Colors.transparent,
  };

  Color get _borderColor => switch (widget.variant) {
    PikirButtonVariant.filled => PikirColors.primary,
    PikirButtonVariant.outlined => PikirColors.primary,
    PikirButtonVariant.neutral => PikirColors.outline,
    PikirButtonVariant.overlayFilled => PikirColors.surface,
    PikirButtonVariant.overlayOutlined => PikirColors.onPrimary,
  };

  /// The ring reads as progress toward the user's own goal, so it uses the
  /// brand green rather than a warning colour. No red anywhere in this
  /// control: the user has done nothing wrong.
  Color get _ringColor => switch (widget.variant) {
    PikirButtonVariant.overlayOutlined => PikirColors.onPrimary,
    _ => PikirColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    final button = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        final holding = progress > 0;
        final remaining = (kHoldToConfirmDuration.inSeconds * (1 - progress))
            .ceil()
            .clamp(1, kHoldToConfirmDuration.inSeconds);

        return Semantics(
          button: true,
          label: widget.label,
          hint: 'Tekan dan tahan lima detik untuk melanjutkan',
          child: GestureDetector(
            onTapDown: (_) => _startHold(),
            onTapUp: (_) => _cancelHold(),
            onTapCancel: _cancelHold,
            child: Container(
              height: PikirSpacing.buttonHeight,
              decoration: BoxDecoration(
                // The fill never changes with progress. Only the ring moves,
                // so contrast stays constant from first touch to confirm.
                color: _background,
                borderRadius: BorderRadius.circular(PikirRadius.button),
                border: Border.all(color: _borderColor, width: 1.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CustomPaint(
                      painter: _HoldRingPainter(
                        progress: progress,
                        color: _ringColor,
                        trackColor: _ringColor.withValues(alpha: 0.2),
                      ),
                      child: Center(
                        child: Icon(
                          widget.icon,
                          size: 15,
                          color: _foreground,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      holding
                          ? 'Tahan terus... $remaining detik lagi'
                          : widget.label,
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
        );
      },
    );

    if (widget.helperText == null) return button;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        button,
        const SizedBox(height: 6),
        Text(
          widget.helperText!,
          textAlign: TextAlign.center,
          style: PikirText.captionSecondary,
        ),
      ],
    );
  }
}

class _HoldRingPainter extends CustomPainter {
  const _HoldRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 2.5;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height)
        .deflate(stroke / 2);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = trackColor;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    if (progress <= 0) return;

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    // Clockwise from twelve o'clock.
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, arc);
  }

  @override
  bool shouldRepaint(_HoldRingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor;
}
