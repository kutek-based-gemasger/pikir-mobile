import 'package:flutter/material.dart';

import '../theme/text_styles.dart';
import '../theme/tokens.dart';

/// One savings tier.
class SavingsTier {
  const SavingsTier({
    required this.label,
    required this.target,
    this.optional = false,
  });

  /// Such as "Tingkat 1".
  final String label;

  /// The cumulative rupiah target for this tier.
  final int target;

  /// Marks a tier the user is explicitly not expected to reach. The three
  /// month target is unrealistic on a daily income, and saying so is kinder
  /// and more honest than letting the bar sit unfinished forever.
  final bool optional;
}

/// Segmented progress toward the emergency-fund tiers.
///
/// Cooperative and self-referential by design. CLAUDE.md section 6 rule 5:
/// no streaks, no points, no badges, no leaderboards, no comparison with
/// other users. Those are the mechanics the predatory apps use, and the
/// product's whole argument is that it does not borrow them.
class TierProgressBar extends StatelessWidget {
  // No assert on tiers being non-empty: List.length cannot be read in a const
  // expression, and keeping this constructor const matters more than guarding
  // a case that renders as an empty row rather than a crash.
  const TierProgressBar({
    super.key,
    required this.currentAmount,
    required this.tiers,
    this.showLabels = true,
  });

  /// Rupiah saved so far.
  final int currentAmount;

  /// Tiers in ascending order of [SavingsTier.target].
  final List<SavingsTier> tiers;

  final bool showLabels;

  /// How full segment [index] is, 0 to 1.
  double _fillOf(int index) {
    final floor = index == 0 ? 0 : tiers[index - 1].target;
    final span = tiers[index].target - floor;
    if (span <= 0) return currentAmount >= tiers[index].target ? 1 : 0;
    return ((currentAmount - floor) / span).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < tiers.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: _Segment(
                  fill: _fillOf(i),
                  reached: _fillOf(i) >= 1,
                ),
              ),
            ],
          ],
        ),
        if (showLabels) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < tiers.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tiers[i].label,
                        style: PikirText.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (tiers[i].optional) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: PikirColors.background,
                            borderRadius: BorderRadius.circular(
                              PikirRadius.chip,
                            ),
                            border: Border.all(color: PikirColors.outline),
                          ),
                          child: Text(
                            'Opsional',
                            style: PikirText.captionSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.fill, required this.reached});

  final double fill;
  final bool reached;

  static const _height = 12.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: PikirColors.outline,
              borderRadius: BorderRadius.circular(_height / 2),
            ),
          ),
          FractionallySizedBox(
            widthFactor: fill,
            child: Container(
              decoration: BoxDecoration(
                color: PikirColors.primary,
                borderRadius: BorderRadius.circular(_height / 2),
              ),
            ),
          ),
          // The milestone dot sits at the end of a completed segment. It marks
          // a boundary the user has passed, not a reward.
          if (reached)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: PikirColors.onPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
