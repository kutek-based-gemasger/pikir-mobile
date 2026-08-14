import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/chat.dart';
import '../../data/providers.dart';

/// Everything the chat screen needs to draw itself.
class ChatState {
  const ChatState({
    this.session,
    this.isSending = false,
    this.pendingQuestion,
    this.failed = false,
  });

  /// Null before the first message. The session is created lazily so opening
  /// the screen and backing out does not leave an empty conversation behind
  /// to be deleted later.
  final ChatSession? session;

  final bool isSending;

  /// Shown as the user's bubble while the answer is still coming, so their
  /// own words appear the instant they send them.
  final String? pendingQuestion;

  final bool failed;

  bool get hasConversation =>
      (session?.messages.isNotEmpty ?? false) || pendingQuestion != null;

  /// Whether the session has gone quiet long enough to close.
  ///
  /// When true the input is removed entirely rather than disabled: a greyed
  /// out box invites tapping at something that will not respond.
  bool isReadOnlyAt(DateTime now) => session?.isReadOnlyAt(now) ?? false;

  ChatState copyWith({
    ChatSession? session,
    bool? isSending,
    String? pendingQuestion,
    bool? failed,
    bool clearPending = false,
  }) {
    return ChatState(
      session: session ?? this.session,
      isSending: isSending ?? this.isSending,
      pendingQuestion: clearPending
          ? null
          : (pendingQuestion ?? this.pendingQuestion),
      failed: failed ?? this.failed,
    );
  }
}

class ChatController extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  /// Sends [text], starting a session first if there is not one yet.
  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;

    final repository = ref.read(chatRepositoryProvider);

    state = state.copyWith(
      isSending: true,
      pendingQuestion: trimmed,
      failed: false,
    );

    try {
      var session = state.session;
      session ??= await repository.startSession();

      // TODO(backend): POST /api/v1/chat/advisor
      final updated = await repository.send(session.id, trimmed);

      state = ChatState(session: updated);
    } on Object {
      // The question stays on screen rather than vanishing. Losing what
      // someone just typed is worse than showing them it did not go through.
      state = state.copyWith(isSending: false, failed: true);
    }
  }

  /// Opens a fresh session after the previous one closed.
  Future<void> startNewSession({ChatContext? context}) async {
    final repository = ref.read(chatRepositoryProvider);
    final session = await repository.startSession(context: context);
    state = ChatState(session: session);
  }

  /// Drops sessions past their 24 hour life. Called when the screen opens.
  Future<void> purgeExpired() async {
    await ref.read(chatRepositoryProvider).purgeExpired();
    final session = state.session;
    if (session != null && session.isExpiredAt(DateTime.now())) {
      state = const ChatState();
    }
  }
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(
  ChatController.new,
);
