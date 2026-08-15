import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../settings/izin_state.dart';

/// The way in, in place of a sign-in screen.
///
/// This is where a normal app would ask who you are. PIKIR does not have that
/// question to ask: there are no accounts, so there is nothing to log into and
/// nothing to lose if the phone is lost. CLAUDE.md section 2 rule 2.
///
/// It is kept as a deliberate step rather than skipped straight to the
/// dashboard, because the absence of an account is the product's first promise
/// and a promise nobody reads is not made. One tap, then the permissions, then
/// the app.
class AnonimScreen extends ConsumerWidget {
  const AnonimScreen({super.key});

  /// Goes on to the app, stopping at the permission page while anything is
  /// still off.
  ///
  /// Beranda is put in place first and the permission page pushed on top, so
  /// "Nanti saja" lands on the dashboard rather than back here.
  Future<void> _enter(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final status = await ref.read(permissionStatusProvider.future);

    navigator.pushReplacementNamed(Routes.beranda);
    if (!status.allGranted) {
      unawaited(
        navigator.pushNamed(
          Routes.pengaturanIzin,
          arguments: kIzinLaunchPrompt,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        // The text scrolls and the button stays put, rather than a Column with
        // Spacers that has nowhere to go once the user's text size grows. The
        // way in must never be the thing pushed off the bottom of the screen.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  PikirSpacing.screenHorizontal,
                  24,
                  PikirSpacing.screenHorizontal,
                  8,
                ),
                children: [
                  const PikirMark(),
                  const SizedBox(height: 32),
                  Text('Halo', style: PikirText.headlineLarge),
                  const SizedBox(height: 10),
                  Text(
                    'PIKIR tidak punya akun, jadi tidak ada yang perlu kamu '
                    'daftarkan dan tidak ada kata sandi yang bisa lupa.',
                    style: PikirText.bodySecondary,
                  ),
                  const SizedBox(height: PikirSpacing.cardGap),
                  const _Promises(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PikirSpacing.screenHorizontal,
                8,
                PikirSpacing.screenHorizontal,
                20,
              ),
              child: Column(
                children: [
                  PikirButton(
                    label: 'Mulai pakai PIKIR',
                    onPressed: () => _enter(context, ref),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Semua catatanmu tersimpan di HP ini saja.',
                    textAlign: TextAlign.center,
                    style: PikirText.captionSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Promises extends StatelessWidget {
  const _Promises();

  /// Stated as things the app does not do, because that is the part a user has
  /// no way to check for themselves.
  static const _lines = [
    (Icons.person_off_outlined, 'Tidak minta nama, nomor HP, atau email'),
    (Icons.cloud_off_outlined, 'Tidak mengirim datamu ke mana pun'),
    (Icons.contacts_outlined, 'Tidak membaca kontak atau galerimu'),
  ];

  @override
  Widget build(BuildContext context) {
    return PikirCard(
      child: Column(
        children: [
          for (final (index, line) in _lines.indexed) ...[
            if (index > 0) const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(line.$1, size: 20, color: PikirColors.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(line.$2, style: PikirText.body)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
