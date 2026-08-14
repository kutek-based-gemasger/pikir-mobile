import 'package:flutter/material.dart';

import '../theme/text_styles.dart';
import '../theme/tokens.dart';

/// The standing disclaimer strip, pinned directly above the chat input.
///
/// PIKIR gives information, not licensed financial advice, and says so in the
/// place where the user is about to ask for advice rather than buried in a
/// settings page.
class DisclaimerBand extends StatelessWidget {
  const DisclaimerBand({
    super.key,
    this.text =
        'PIKIR memberi informasi, bukan nasihat keuangan resmi. '
        'Untuk aduan, hubungi OJK 157.',
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: PikirColors.cautionContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: PikirColors.caution,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: PikirText.caption)),
        ],
      ),
    );
  }
}
