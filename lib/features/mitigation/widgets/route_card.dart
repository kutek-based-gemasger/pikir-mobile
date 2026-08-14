import 'package:flutter/material.dart';

import '../../../core/format/rupiah.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/mitigation.dart';

/// One financing option, on the productive branch only.
///
/// Every card carries the same elements in the same order and none is
/// visually promoted: no "rekomendasi kami" badge, no highlighted border, no
/// affiliate styling. The full cost is on the card rather than behind the
/// detail screen, because a cost the user has to tap to discover is a cost
/// they can be walked past.
class FinancingRouteCard extends StatelessWidget {
  const FinancingRouteCard({
    super.key,
    required this.option,
    required this.onDetail,
    required this.onAsk,
  });

  final FinancingOption option;
  final VoidCallback onDetail;

  /// Hands this route's numbers to Tanya PIKIR.
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    return PikirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onDetail,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(option.name, style: PikirText.title),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: PikirColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Time to money, stated with an icon and words rather
                    // than left to a colour.
                    StatusChip(
                      status: PikirStatus.safe,
                      label: option.disbursementLabel,
                      icon: Icons.schedule_rounded,
                    ),
                    StatusChip(
                      status: PikirStatus.neutral,
                      label: option.trustBadge,
                      icon: Icons.verified_outlined,
                      quiet: true,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Total kembali ${formatRupiah(option.totalReturn)}',
                  style: PikirText.number.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pokok ${formatRupiah(option.principal)} + biaya '
                  '${formatRupiah(option.costOnTop)}',
                  style: PikirText.captionSecondary,
                ),
                const SizedBox(height: 12),
                // One honest caution, stated plainly rather than buried in
                // fine print or revealed later in the flow.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: PikirColors.cautionContainer,
                    borderRadius: BorderRadius.circular(PikirRadius.input),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: PikirColors.caution,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          option.cautionLine,
                          style: PikirText.caption,
                        ),
                      ),
                    ],
                  ),
                ),
                if (option.sourceLabel != null) ...[
                  const SizedBox(height: 12),
                  SourceChip(label: option.sourceLabel!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Present on every single card, at full width. A route the user
          // cannot ask about is a route they have to accept on trust.
          PikirButton(
            label: 'Tanya lebih lanjut',
            variant: PikirButtonVariant.outlined,
            onPressed: onAsk,
          ),
        ],
      ),
    );
  }
}

/// One assistance programme, on the urgent-need branch only.
///
/// Structurally the same card as a financing route, minus everything about
/// repayment, because there is nothing to repay. No loan product appears on
/// this branch at any interest rate.
class AssistanceRouteCard extends StatelessWidget {
  const AssistanceRouteCard({
    super.key,
    required this.program,
    required this.onDetail,
    required this.onAsk,
  });

  final AssistanceProgram program;
  final VoidCallback onDetail;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    return PikirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onDetail,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(program.name, style: PikirText.title),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: PikirColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(program.provider, style: PikirText.captionSecondary),
                const SizedBox(height: 12),
                Text(program.whatYouGet, style: PikirText.body),
                if (program.sourceLabel != null) ...[
                  const SizedBox(height: 12),
                  SourceChip(label: program.sourceLabel!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          PikirButton(
            label: 'Tanya lebih lanjut',
            variant: PikirButtonVariant.outlined,
            onPressed: onAsk,
          ),
        ],
      ),
    );
  }
}
