import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/routes.dart';
import '../../data/models/chat.dart';
import 'chat_state.dart';

/// Opens Tanya PIKIR carrying what the previous screen was showing.
///
/// The user does not have to retype the numbers, and, more importantly, the
/// context is drawn as a visible card above the conversation rather than
/// smuggled into a hidden prompt. Someone handing their situation to an
/// assistant should be able to see exactly what it was told about them.
Future<void> openChatWithContext(
  BuildContext context,
  WidgetRef ref, {
  required String label,
  required String detail,
}) async {
  await ref
      .read(chatControllerProvider.notifier)
      .startNewSession(context: ChatContext(label: label, detail: detail));

  if (!context.mounted) return;
  await Navigator.of(context).pushNamed(Routes.chat);
}
