import 'package:flutter/material.dart';

import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';

/// One tile in the Beranda grid.
///
/// Every feature is reachable manually from here. Waiting for a trigger is not
/// an acceptable only-route into a feature: someone who wants to check their
/// own debt at midnight should not have to open a loan app first.
class QuickTile extends StatelessWidget {
  const QuickTile({
    super.key,
    required this.icon,
    required this.label,
    required this.subline,
    required this.onTap,
  });

  final IconData icon;
  final String label;

  /// A short line of real information, such as "3 catatan aktif", rather than
  /// a restatement of the label.
  final String subline;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PikirCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: PikirColors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 24, color: PikirColors.primary),
          ),
          const SizedBox(height: 12),
          // The text block takes exactly the height the grid cell has left,
          // and each line inside may shrink. Sizing it to its natural height
          // instead would overflow the moment a label wraps or the user runs
          // their phone at a larger text size, which many of them do.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: PikirText.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    subline,
                    style: PikirText.captionSecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
