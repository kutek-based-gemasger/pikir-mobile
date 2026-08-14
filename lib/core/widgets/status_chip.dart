import 'package:flutter/material.dart';

import '../theme/text_styles.dart';
import '../theme/tokens.dart';

/// The status states PIKIR can report.
enum PikirStatus {
  /// Under the threshold, on track, nothing to act on.
  safe,

  /// Approaching a threshold, or the Mode Tahan pause state. Amber, never
  /// red: the user has done nothing wrong.
  caution,

  /// Genuinely suspicious content only. Over-warning destroys trust and
  /// teaches users to ignore the real warnings.
  danger,

  /// Not yet started, not yet due, no judgement attached.
  neutral,
}

/// A status pill carrying colour, icon, and text label together.
///
/// CLAUDE.md section 6 rule 1: every status is shown with all three at once,
/// never colour alone. [label] is required and asserted non-empty for exactly
/// that reason, so a colour-only chip cannot be built by accident.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
    required this.label,
    this.icon,
    this.quiet = false,
  }) : assert(label.length > 0, 'A status is never carried by colour alone.');

  final PikirStatus status;

  /// The plain-language state, such as "Aman" or "Di atas batas aman".
  final String label;

  /// Overrides the default icon for the status. The icon still appears; it
  /// cannot be removed.
  final IconData? icon;

  /// Drops the tinted fill and renders on a neutral grey ground, keeping the
  /// coloured icon. Used where a status is reassuring rather than actionable,
  /// such as the "Aman" marker beside an ordinary notification, so the screen
  /// does not fill up with colour that means nothing.
  final bool quiet;

  Color get _color => switch (status) {
    PikirStatus.safe => PikirColors.safe,
    PikirStatus.caution => PikirColors.caution,
    PikirStatus.danger => PikirColors.danger,
    PikirStatus.neutral => PikirColors.textSecondary,
  };

  Color get _fill => switch (status) {
    PikirStatus.safe => PikirColors.primaryContainer,
    PikirStatus.caution => PikirColors.cautionContainer,
    PikirStatus.danger => PikirColors.dangerContainer,
    PikirStatus.neutral => PikirColors.background,
  };

  IconData get _icon =>
      icon ??
      switch (status) {
        PikirStatus.safe => Icons.check_circle_outline_rounded,
        PikirStatus.caution => Icons.warning_amber_rounded,
        PikirStatus.danger => Icons.warning_rounded,
        PikirStatus.neutral => Icons.schedule_rounded,
      };

  @override
  Widget build(BuildContext context) {
    // Text sits in the primary text colour rather than the status colour so
    // it stays above 4.5:1 on the tinted fill at 14sp. The status is still
    // carried three ways: fill, icon colour, and the words themselves.
    return Semantics(
      label: 'Status: $label',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: quiet ? PikirColors.background : _fill,
          borderRadius: BorderRadius.circular(PikirRadius.chip),
          border: quiet
              ? Border.all(color: PikirColors.outline)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 16, color: _color),
            const SizedBox(width: 6),
            // Flexible so a long status in a tight row shortens the words
            // rather than pushing the chip past its container. The icon and
            // the fill stay, so the state is still carried three ways.
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PikirText.label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
