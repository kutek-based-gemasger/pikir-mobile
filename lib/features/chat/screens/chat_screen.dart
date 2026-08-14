import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/tanggal.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/mock/seed.dart';
import '../../../data/models/chat.dart';
import '../chat_state.dart';
import '../widgets/chat_bubble.dart';

/// Tanya PIKIR.
///
/// Two lifecycle rules shape this screen. After two hours of quiet the session
/// closes and the input is removed entirely, not disabled, leaving the history
/// fully readable. And every conversation is deleted after twenty-four hours,
/// which the screen states plainly rather than doing quietly.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // The 24 hour sweep runs on open, per the handoff's local cleanup job.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatControllerProvider.notifier).purgeExpired();
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    _input.clear();
    await ref.read(chatControllerProvider.notifier).send(text);
    if (!mounted || !_scroll.hasClients) return;
    await _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);
    final readOnly = state.isReadOnlyAt(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Flexible(
              child: Text(
                'Tanya PIKIR',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: PikirColors.primaryContainer,
                borderRadius: BorderRadius.circular(PikirRadius.chip),
              ),
              child: Text(
                'AI',
                style: PikirText.caption.copyWith(
                  color: PikirColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: state.hasConversation
                ? _Conversation(
                    state: state,
                    controller: _scroll,
                    readOnly: readOnly,
                    onSuggestion: _send,
                  )
                : _EmptyState(onSuggestion: _send),
          ),
          const DisclaimerBand(),
          if (readOnly)
            _SessionClosedCard(
              onStartNew: () async {
                await ref
                    .read(chatControllerProvider.notifier)
                    .startNewSession();
              },
            )
          else
            _InputBar(
              controller: _input,
              isSending: state.isSending,
              onSend: _send,
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSuggestion});

  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        PikirSpacing.screenHorizontal,
        8,
        PikirSpacing.screenHorizontal,
        16,
      ),
      children: [
        const _RetentionNotice(),
        const SizedBox(height: 24),
        const Center(child: PikirMark(size: 64, showWordmark: false)),
        const SizedBox(height: 20),
        Text(
          'Tanya apa saja soal utang dan bantuan',
          style: PikirText.headline,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.link_rounded,
              size: 15,
              color: PikirColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Jawaban kami selalu menyertakan sumbernya.',
                style: PikirText.bodySecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        // Suggestions, not defaults. Nothing here is pre-selected and none is
        // marked as the recommended thing to ask.
        for (final suggestion in Seed.chatSuggestions) ...[
          SuggestionChip(
            label: suggestion,
            onTap: () => onSuggestion(suggestion),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _Conversation extends StatelessWidget {
  const _Conversation({
    required this.state,
    required this.controller,
    required this.readOnly,
    required this.onSuggestion,
  });

  final ChatState state;
  final ScrollController controller;
  final bool readOnly;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    final session = state.session;
    final messages = session?.messages ?? const <ChatMessage>[];

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(
        PikirSpacing.screenHorizontal,
        8,
        PikirSpacing.screenHorizontal,
        16,
      ),
      children: [
        const _RetentionNotice(),
        const SizedBox(height: 16),
        if (session?.context != null) ...[
          ChatContextCard(context: session!.context!),
          const SizedBox(height: 16),
        ],
        if (readOnly) ...[
          Center(
            child: Text(
              'Sesi ditutup ${formatTime(session!.lastActivityAt)}',
              style: PikirText.captionSecondary,
            ),
          ),
          const SizedBox(height: 16),
        ],
        for (final message in messages) ...[
          ChatBubble(message: message),
          const SizedBox(height: 14),
        ],
        if (state.pendingQuestion != null && state.isSending) ...[
          ChatBubble(
            message: ChatMessage(
              id: 'pending',
              role: ChatRole.user,
              text: state.pendingQuestion!,
              sentAt: DateTime.now(),
            ),
          ),
          const SizedBox(height: 14),
          const _TypingIndicator(),
        ],
        if (state.failed) ...[
          const SizedBox(height: 8),
          Text(
            'Jawabannya belum sampai. Coba kirim lagi.',
            style: PikirText.captionSecondary,
          ),
        ],
      ],
    );
  }
}

/// The plain statement that this conversation does not last.
class _RetentionNotice extends StatelessWidget {
  const _RetentionNotice();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Obrolan ini terhapus otomatis setelah '
      '${formatRemaining(kChatHistoryLifetime)}.',
      style: PikirText.captionSecondary,
      textAlign: TextAlign.center,
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: PikirCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: PikirColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'PIKIR sedang mencari sumbernya',
                style: PikirText.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: PikirColors.surface,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                style: PikirText.body,
                decoration: InputDecoration(
                  hintText: 'Tulis pertanyaanmu...',
                  filled: true,
                  fillColor: PikirColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(PikirRadius.button),
                    borderSide: const BorderSide(color: PikirColors.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(PikirRadius.button),
                    borderSide: const BorderSide(color: PikirColors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(PikirRadius.button),
                    borderSide: const BorderSide(
                      color: PikirColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                onSubmitted: isSending ? null : onSend,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: PikirSpacing.minTapTarget,
              height: PikirSpacing.minTapTarget,
              child: Material(
                color: PikirColors.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: isSending ? null : () => onSend(controller.text),
                  child: const Icon(
                    Icons.send_rounded,
                    color: PikirColors.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What replaces the input once a session has closed.
///
/// The input is gone, not greyed out. A disabled box invites tapping at
/// something that will never answer; a card that explains what happened and
/// offers the way forward does not.
class _SessionClosedCard extends StatelessWidget {
  const _SessionClosedCard({required this.onStartNew});

  final Future<void> Function() onStartNew;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: PikirColors.surface,
        padding: const EdgeInsets.fromLTRB(
          PikirSpacing.screenHorizontal,
          16,
          PikirSpacing.screenHorizontal,
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: PikirColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sesi obrolan ini sudah ditutup',
                    style: PikirText.title,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Kamu masih bisa membacanya. Obrolan akan terhapus otomatis '
              '24 jam setelah dibuat.',
              style: PikirText.captionSecondary,
            ),
            const SizedBox(height: PikirSpacing.cardGap),
            PikirButton(
              label: 'Mulai obrolan baru',
              onPressed: onStartNew,
            ),
          ],
        ),
      ),
    );
  }
}
