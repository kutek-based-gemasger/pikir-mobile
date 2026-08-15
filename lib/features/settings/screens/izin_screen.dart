import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../izin_state.dart';

/// The one place the three permissions are explained and switched on.
///
/// Opened from Settings, and shown once on launch while any of them is off.
/// Every card states what the permission does, where it stops, and what breaks
/// without it. A permission screen that only says what it wants is asking to
/// be trusted blindly, which is the posture the apps this one warns about take.
///
/// Nothing here nags. The way out is a full-size button of equal weight to the
/// way forward, and the launch prompt appears once per session rather than
/// every time the user returns.
class IzinScreen extends ConsumerStatefulWidget {
  const IzinScreen({super.key, this.isLaunchPrompt = false});

  /// True when shown automatically at launch rather than opened from Settings.
  ///
  /// Only changes the framing and adds the dismiss button; the content is the
  /// same, so there is one screen to maintain rather than two that drift.
  /// Also arrives as the [kIzinLaunchPrompt] route argument, which is how the
  /// registry's single entry serves both entry points.
  final bool isLaunchPrompt;

  @override
  ConsumerState<IzinScreen> createState() => _IzinScreenState();
}

class _IzinScreenState extends ConsumerState<IzinScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Granting happens in Android's own settings, so the user comes back
    // expecting this page to have noticed.
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(permissionStatusProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(permissionStatusProvider);
    final isLaunchPrompt =
        widget.isLaunchPrompt ||
        ModalRoute.of(context)?.settings.arguments == kIzinLaunchPrompt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Izin perlindungan'),
        automaticallyImplyLeading: !isLaunchPrompt,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: status.when(
                loading: () => const PikirCardLoading(height: 300),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.all(PikirSpacing.screenHorizontal),
                  child: PikirLoadFailure(
                    onRetry: () => ref.invalidate(permissionStatusProvider),
                  ),
                ),
                data: (data) => ListView(
                  padding: const EdgeInsets.fromLTRB(
                    PikirSpacing.screenHorizontal,
                    0,
                    PikirSpacing.screenHorizontal,
                    16,
                  ),
                  children: [
                    _Intro(status: data, isLaunchPrompt: isLaunchPrompt),
                    const SizedBox(height: PikirSpacing.cardGap),
                    for (final permission in data.applicable) ...[
                      _PermissionCard(
                        permission: permission,
                        granted: data.isGranted(permission),
                        // Granted but switched off inside PIKIR is a state
                        // the user can otherwise only discover by wondering
                        // why nothing happens.
                        pausedInApp:
                            permission == PikirPermission.screenAccess &&
                            data.isGranted(permission) &&
                            ref.watch(screenWatchEnabledProvider).value ==
                                false,
                        // The dialog answers inside the app, so nothing else
                        // triggers a re-read the way returning from settings
                        // does.
                        onRequested: () =>
                            ref.invalidate(permissionStatusProvider),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Kamu bisa mematikan izin ini kapan saja lewat '
                      'pengaturan HP. PIKIR tetap bisa dipakai manual tanpa '
                      'satu pun izin di atas.',
                      style: PikirText.captionSecondary,
                    ),
                  ],
                ),
              ),
            ),
            if (isLaunchPrompt)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  PikirSpacing.screenHorizontal,
                  12,
                  PikirSpacing.screenHorizontal,
                  12,
                ),
                // Opaque with a hairline above it, so the list scrolls behind a
                // footer rather than appearing to be cut off by a floating
                // button.
                decoration: const BoxDecoration(
                  color: PikirColors.background,
                  border: Border(
                    top: BorderSide(color: PikirColors.outline),
                  ),
                ),
                // Full size, full contrast, same metrics as any other action.
                // Section 6 rule 3: the option that declines is never made
                // smaller than the one that proceeds, and declining here is a
                // legitimate answer.
                child: PikirButton(
                  label: 'Nanti saja',
                  variant: PikirButtonVariant.outlined,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.status, required this.isLaunchPrompt});

  final PermissionStatus status;
  final bool isLaunchPrompt;

  @override
  Widget build(BuildContext context) {
    if (status.allGranted) {
      return PikirCard(
        color: PikirColors.primaryContainer,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: PikirColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Semua izin sudah aktif. PIKIR bisa menemani kamu di '
                'titik-titik keputusan yang berisiko.',
                style: PikirText.body,
              ),
            ),
          ],
        ),
      );
    }

    final missing = status.missing.length;

    return PikirCard(
      outlined: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLaunchPrompt
                ? 'PIKIR belum bisa menjagamu sepenuhnya'
                : 'Ada $missing izin yang belum aktif',
            style: PikirText.title,
          ),
          const SizedBox(height: 6),
          // States the consequence without inventing urgency. No countdown, no
          // "segera", no warning colour: the app is describing its own
          // limitation, not pressuring the user.
          //
          // Counted rather than written out, because how many permissions
          // apply depends on the Android version.
          Text(
            '$missing dari ${status.total} izin belum aktif. Kamu tetap bisa '
            'memakai PIKIR sekarang, hanya saja bagian yang otomatis belum '
            'berjalan.',
            style: PikirText.bodySecondary,
          ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.permission,
    required this.granted,
    required this.onRequested,
    this.pausedInApp = false,
  });

  final PikirPermission permission;
  final bool granted;
  final VoidCallback onRequested;

  /// Android has granted it, but PIKIR's own switch is off.
  final bool pausedInApp;

  @override
  Widget build(BuildContext context) {
    return PikirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(permission.title, style: PikirText.title),
              ),
              const SizedBox(width: 8),
              // Colour, icon, and words together. A permission that is off is
              // amber rather than red: nothing has gone wrong, it simply has
              // not been switched on.
              Flexible(
                child: StatusChip(
                  status: granted ? PikirStatus.safe : PikirStatus.caution,
                  label: granted ? 'Aktif' : 'Belum aktif',
                  quiet: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(permission.what, style: PikirText.body),
          if (pausedInApp) ...[
            const SizedBox(height: 10),
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
                    Icons.pause_circle_outline_rounded,
                    size: 16,
                    color: PikirColors.caution,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Izinnya aktif, tapi deteksi layar sedang kamu matikan '
                      'lewat Pengaturan. Nyalakan lagi kalau mau PIKIR '
                      'menjaga.',
                      style: PikirText.caption,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: PikirColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(permission.limit, style: PikirText.captionSecondary),
              ),
            ],
          ),
          if (!granted) ...[
            const SizedBox(height: 12),
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
                    child: Text(permission.missing, style: PikirText.caption),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (!permission.usesSystemDialog) ...[
              // Android opens a list of apps rather than PIKIR's own row, and
              // on some phones it ignores the package we point it at entirely.
              // The user is left hunting through an alphabetical list, so the
              // page says where they are going before they get there.
              Text(
                'Nanti terbuka daftar aplikasi. Cari PIKIR di situ, lalu '
                'nyalakan.',
                style: PikirText.captionSecondary,
              ),
              const SizedBox(height: 12),
            ],
            PikirButton(
              // Named for what actually happens next, because these two are
              // different journeys: one shows a dialog right here, the other
              // hands the user over to Android's settings.
              label: permission.usesSystemDialog
                  ? 'Izinkan'
                  : 'Buka pengaturan',
              variant: PikirButtonVariant.outlined,
              onPressed: () async {
                await requestPermission(permission);
                onRequested();
              },
            ),
          ],
        ],
      ),
    );
  }
}
