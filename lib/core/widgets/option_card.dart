import 'package:flutter/material.dart';

import '../theme/text_styles.dart';
import '../theme/tokens.dart';

/// A large tappable card, used for every classification question.
///
/// Deliberately has no "recommended", "popular", or "best value" affordance.
/// CLAUDE.md section 6 rule 2 forbids pre-selecting or promoting an option,
/// so there is no parameter to do it with: adding one would mean editing this
/// file, which is a conversation rather than an accident.
///
/// Tapping advances immediately. A separate confirm button would invite a
/// default-highlighted primary action on the next screen.
class OptionCard extends StatelessWidget {
  const OptionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.example,
    this.selected = false,
  });

  final IconData icon;

  /// The choice in plain Bahasa Indonesia, such as "Kebutuhan hidup".
  final String label;

  /// A one-line concrete example, such as "makan, listrik, kontrakan".
  /// This is what makes the card usable for someone reading under stress.
  final String? example;

  final VoidCallback? onTap;

  /// Whether this card is currently chosen.
  ///
  /// Defaults to false and must stay false until the user taps. Never wire
  /// this to a "suggested" value.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: example == null ? label : '$label. $example',
      excludeSemantics: true,
      child: Material(
        color: PikirColors.surface,
        borderRadius: BorderRadius.circular(PikirRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(PikirRadius.card),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: PikirSpacing.optionCardMinHeight,
            ),
            padding: const EdgeInsets.all(PikirSpacing.cardPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PikirRadius.card),
              border: Border.all(
                color: selected ? PikirColors.primary : PikirColors.outline,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Approximates the duotone icon style: brand green mark on a
                // tinted green plate.
                // TODO(design): replace with the custom duotone icon set.
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: PikirColors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 28, color: PikirColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: PikirText.title),
                      if (example != null) ...[
                        const SizedBox(height: 4),
                        Text(example!, style: PikirText.captionSecondary),
                      ],
                    ],
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: PikirColors.primary,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
