/// A chat session closes after this long without a message and becomes
/// read-only history. The input bar is removed rather than greyed out.
const kChatSessionTimeout = Duration(hours: 2);

/// Chat history is deleted permanently after this long, for privacy.
/// The UI states this to the user rather than doing it quietly.
const kChatHistoryLifetime = Duration(hours: 24);

/// Only the last this many messages are ever sent upstream, to keep latency
/// and token cost down.
const kChatSlidingWindow = 10;

enum ChatRole { user, assistant }

/// A citation attached to an assistant answer.
///
/// Every factual claim carries one. This is the difference between an answer
/// the user can check and one they simply have to trust.
class ChatSource {
  const ChatSource({required this.label, this.url});

  /// Such as "OJK - POJK Pinjaman Daring".
  final String label;

  final String? url;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.sentAt,
    this.sources = const [],
    this.calculation,
    this.isRefusal = false,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime sentAt;

  final List<ChatSource> sources;

  /// An arithmetic strip shown inside the bubble, such as
  /// "0,4% x 365 hari = 146%". Showing the working is what turns a number
  /// into something the user can carry into a conversation with a lender.
  final String? calculation;

  /// Marks a polite out-of-domain refusal.
  ///
  /// Rendered as a normal answer, never as an error state: no red, no warning
  /// icon. Being told "I can't help with that" should not feel like a fault.
  final bool isRefusal;
}

/// Context handed over from an intervention or a mitigation route.
///
/// Shown as a distinct card above the conversation, clearly not a chat bubble,
/// so the user can see exactly what the assistant was told about them.
class ChatContext {
  const ChatContext({required this.label, required this.detail});

  final String label;
  final String detail;
}

class ChatSession {
  const ChatSession({
    required this.id,
    required this.createdAt,
    required this.lastActivityAt,
    this.messages = const [],
    this.context,
  });

  final String id;
  final DateTime createdAt;
  final DateTime lastActivityAt;
  final List<ChatMessage> messages;
  final ChatContext? context;

  /// Whether the session has gone quiet long enough to close.
  bool isReadOnlyAt(DateTime now) =>
      now.difference(lastActivityAt) >= kChatSessionTimeout;

  /// Whether the session is old enough to be deleted.
  bool isExpiredAt(DateTime now) =>
      now.difference(createdAt) >= kChatHistoryLifetime;

  /// How long until this session is deleted, for the calm informational line
  /// on the privacy screen.
  Duration timeUntilDeletion(DateTime now) {
    final remaining = kChatHistoryLifetime - now.difference(createdAt);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// The tail of the conversation that would be sent upstream.
  List<ChatMessage> get windowedMessages {
    if (messages.length <= kChatSlidingWindow) return messages;
    return messages.sublist(messages.length - kChatSlidingWindow);
  }

  ChatSession copyWith({
    DateTime? lastActivityAt,
    List<ChatMessage>? messages,
    ChatContext? context,
  }) {
    return ChatSession(
      id: id,
      createdAt: createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      messages: messages ?? this.messages,
      context: context ?? this.context,
    );
  }
}
