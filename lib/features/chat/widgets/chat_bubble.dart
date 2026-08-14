import 'package:flutter/material.dart';

import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/chat.dart';

/// One message.
///
/// Chat bubbles are the app's single exception to the "do not mix rounded and
/// sharp corners" rule: each squares the one corner pointing at its speaker,
/// which is what makes a conversation readable at a glance without colour
/// doing the work alone.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: isUser ? PikirColors.primary : PikirColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(PikirRadius.card),
                  topRight: const Radius.circular(PikirRadius.card),
                  bottomLeft: Radius.circular(isUser ? PikirRadius.card : 4),
                  bottomRight: Radius.circular(isUser ? 4 : PikirRadius.card),
                ),
                boxShadow: isUser ? null : PikirShadow.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isRefusal) ...[
                    // A refusal is drawn as an ordinary answer. No red, no
                    // warning icon, no error styling: being told the assistant
                    // cannot help should not feel like the user did something
                    // wrong.
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: PikirColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    message.text,
                    style: PikirText.body.copyWith(
                      color: isUser
                          ? PikirColors.onPrimary
                          : PikirColors.textPrimary,
                    ),
                  ),
                  if (message.calculation != null) ...[
                    const SizedBox(height: 12),
                    _CalculationStrip(text: message.calculation!),
                  ],
                ],
              ),
            ),
            if (message.sources.isNotEmpty) ...[
              const SizedBox(height: 8),
              SourceChipRow(
                chips: [
                  for (final source in message.sources)
                    SourceChip(label: source.label),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The arithmetic behind an answer, shown rather than asserted.
///
/// Someone who can see "0,4% x 365 hari = 146%" can repeat the calculation to
/// a lender. Someone given only the conclusion has to take it on trust, which
/// is the position the app is trying to get them out of.
class _CalculationStrip extends StatelessWidget {
  const _CalculationStrip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: PikirColors.primaryContainer,
        borderRadius: BorderRadius.circular(PikirRadius.input),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calculate_outlined,
            size: 18,
            color: PikirColors.primary,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: PikirText.number.copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable suggestion.
class SuggestionChip extends StatelessWidget {
  const SuggestionChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PikirColors.surface,
      borderRadius: BorderRadius.circular(PikirRadius.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PikirRadius.button),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: PikirSpacing.minTapTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PikirRadius.button),
            border: Border.all(color: PikirColors.primary),
          ),
          child: Text(
            label,
            style: PikirText.label.copyWith(color: PikirColors.primary),
          ),
        ),
      ),
    );
  }
}

/// The context handed over from an intervention or a mitigation route.
///
/// Drawn as a distinct card rather than a chat bubble, so the user can see
/// exactly what the assistant was told about them before they said anything.
class ChatContextCard extends StatelessWidget {
  const ChatContextCard({super.key, required this.context});

  final ChatContext context;

  @override
  Widget build(BuildContext buildContext) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PikirColors.primaryContainer,
        borderRadius: BorderRadius.circular(PikirRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.alt_route_rounded,
                size: 16,
                color: PikirColors.primary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Konteks dari layar sebelumnya',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PikirText.captionSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(context.detail, style: PikirText.body),
        ],
      ),
    );
  }
}
