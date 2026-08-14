import 'package:flutter/material.dart';

import '../theme/text_styles.dart';
import '../theme/tokens.dart';

/// A citation chip sitting directly beneath a factual claim.
///
/// Every AI answer and every program recommendation carries one. Labelling
/// where a number came from is what separates this app from the products it
/// is protecting people against.
class SourceChip extends StatelessWidget {
  const SourceChip({super.key, required this.label, this.onTap});

  /// The source, such as "OJK - POJK Pinjaman Daring".
  final String label;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: onTap != null,
      label: 'Sumber: $label',
      excludeSemantics: true,
      child: Material(
        color: PikirColors.surface,
        borderRadius: BorderRadius.circular(PikirRadius.chip),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(PikirRadius.chip),
          child: Container(
            constraints: const BoxConstraints(minHeight: 32),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PikirRadius.chip),
              border: Border.all(color: PikirColors.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.link_rounded,
                  size: 15,
                  color: PikirColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    // Caption size is the floor of the scale, 13sp. Fine print
                    // must stay legible.
                    style: PikirText.captionSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Wraps a set of [SourceChip]s beneath an answer.
class SourceChipRow extends StatelessWidget {
  const SourceChipRow({super.key, required this.chips});

  final List<SourceChip> chips;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }
}
