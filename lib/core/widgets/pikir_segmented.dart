import 'package:flutter/material.dart';

import '../theme/text_styles.dart';
import '../theme/tokens.dart';

/// One choice in a [PikirSegmented].
class PikirSegment<T> {
  const PikirSegment({required this.value, required this.label});

  final T value;
  final String label;
}

/// A segmented control with equal-width options.
///
/// [selected] is nullable, and that is the point. Two of these exist in the
/// app and they are different in kind: the ledger's tabs are a view switch,
/// where having one active is just where the user currently is, while the
/// savings reminder's modes are a decision, and CLAUDE.md section 6 rule 2
/// forbids arriving at a decision with an answer already filled in. Passing
/// null covers the second case honestly instead of quietly highlighting one.
///
/// Every segment shares a width and a text style, so no option can be made to
/// look like the expected one.
class PikirSegmented<T> extends StatelessWidget {
  const PikirSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelect,
  });

  final List<PikirSegment<T>> segments;

  /// Null means nothing is chosen yet.
  final T? selected;

  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PikirColors.background,
        borderRadius: BorderRadius.circular(PikirRadius.button),
        border: Border.all(color: PikirColors.outline),
      ),
      child: Row(
        children: [
          for (final segment in segments)
            Expanded(
              child: _Segment(
                label: segment.label,
                active: selected != null && segment.value == selected,
                onTap: () => onSelect(segment.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: active ? PikirColors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(PikirRadius.button),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(PikirRadius.button),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              // Same size and weight in both states. Only the fill and the
              // text colour move, so an unselected option never reads as
              // discouraged.
              style: PikirText.label.copyWith(
                color: active
                    ? PikirColors.primary
                    : PikirColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
