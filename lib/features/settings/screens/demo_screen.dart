import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/scanner_channel.dart';
import '../../../core/platform/screen_channel.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/providers.dart';
import '../../../data/queries.dart';
import '../../intervention/intervention_state.dart';
import '../../mitigation/mitigation_state.dart';
import '../izin_state.dart';

/// Mode demo.
///
/// The real triggers are hard to stage on camera: a paylater checkout needs a
/// real cart, and a predatory notification needs a predatory app. These
/// buttons fire the same flows directly so the submission recording shows the
/// product rather than a setup process.
///
/// This is a recording tool, not a feature. It stays behind a settings row and
/// adds no celebration of its own: firing a flow here lands the user on the
/// same screen the real trigger would, with the same seeded numbers.
class DemoScreen extends ConsumerStatefulWidget {
  const DemoScreen({super.key});

  @override
  ConsumerState<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends ConsumerState<DemoScreen> {
  bool _busy = false;
  String? _note;

  /// The one place every read is refreshed after the seed is restored.
  ///
  /// Listed explicitly rather than looped, because a provider missing from
  /// here is a screen showing stale numbers on camera.
  void _refreshEverything() {
    ref.invalidate(debtsProvider);
    ref.invalidate(debtSummaryProvider);
    ref.invalidate(decisionsProvider);
    ref.invalidate(decisionStatsProvider);
    ref.invalidate(emergencyFundProvider);
    ref.invalidate(incomeProfileProvider);
    ref.invalidate(scannerLogsProvider);
    ref.invalidate(scannerEnabledProvider);
    ref.invalidate(detectedBillsProvider);
    ref.invalidate(billsDueSoonProvider);
    ref.invalidate(heldNotificationCountProvider);
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _note = null;
    });
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _simulateCheckout() => _run(() async {
    ref
        .read(interventionControllerProvider.notifier)
        .startCheckout(amount: 1250000);
    if (!mounted) return;
    await Navigator.of(context).pushNamed(Routes.intervensiBlanket);
  });

  Future<void> _simulateLoanApp() => _run(() async {
    ref.read(interventionControllerProvider.notifier).startLoanApp();
    if (!mounted) return;
    await Navigator.of(context).pushNamed(Routes.intervensiTujuan);
  });

  Future<void> _simulateNotification() => _run(() async {
    // Runs the real classify-log-replace path in the Android service's code,
    // so what appears in the shade is the genuine replacement notification
    // with its two actions, not a picture of one.
    final result = await ScannerChannel.simulateFlagged(
      appLabel: 'DanaKilat',
      title: 'Selamat! Limit kamu naik Rp5.000.000',
      text: 'Cair 3 menit tanpa BI Checking. Klik sekarang!',
    );
    _refreshEverything();
    if (!mounted) return;

    setState(() {
      _note = result == null
          ? 'Simulasi notifikasi hanya jalan di HP Android. Pastikan juga '
                'izin akses notifikasi sudah aktif.'
          : 'Notifikasi PIKIR sudah muncul. Tarik panel notifikasi untuk '
                'melihatnya, lengkap dengan tombol menampilkan pesan asli.';
    });
  });

  Future<void> _resetSeed() => _run(() async {
    await ref.read(demoRepositoryProvider).resetToSeed();
    ref.read(interventionControllerProvider.notifier).reset();
    ref.read(mitigationControllerProvider.notifier).reset();
    _refreshEverything();
    if (!mounted) return;
    setState(
      () => _note =
          'Data kembali ke kondisi awal: 3 catatan utang Rp3.150.000, '
          'beban 18%, dana darurat Rp450.000.',
    );
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mode demo')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          PikirSpacing.screenHorizontal,
          0,
          PikirSpacing.screenHorizontal,
          32,
        ),
        children: [
          PikirCard(
            outlined: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Untuk perekaman layar', style: PikirText.title),
                const SizedBox(height: 6),
                Text(
                  'Pemicu aslinya sulit dipentaskan di depan kamera, jadi '
                  'tombol di bawah menjalankan alur yang sama secara '
                  'langsung.',
                  style: PikirText.bodySecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: PikirSpacing.cardGap),
          _DemoAction(
            icon: Icons.shopping_cart_outlined,
            label: 'Simulasi checkout paylater',
            detail:
                'Blokir instan Rp1.250.000, lalu layar biaya dan tiga pilihan.',
            enabled: !_busy,
            onTap: _simulateCheckout,
          ),
          const SizedBox(height: 12),
          _DemoAction(
            icon: Icons.phone_android_outlined,
            label: 'Simulasi buka aplikasi pinjaman',
            detail: 'Pertanyaan "Kamu mau ngutang buat apa?" dengan dua opsi.',
            enabled: !_busy,
            onTap: _simulateLoanApp,
          ),
          const SizedBox(height: 12),
          _DemoAction(
            icon: Icons.notifications_active_outlined,
            label: 'Simulasi notifikasi pinjol masuk',
            detail:
                'Menjalankan pemindai sungguhan, lalu memunculkan notifikasi '
                'pengganti dari PIKIR.',
            enabled: !_busy,
            onTap: _simulateNotification,
          ),
          const SizedBox(height: 12),
          _DemoAction(
            icon: Icons.restart_alt_rounded,
            label: 'Reset data ke kondisi awal',
            detail: 'Kembalikan semua angka ke kondisi seed sebelum merekam.',
            enabled: !_busy,
            onTap: _resetSeed,
          ),
          if (_note != null) ...[
            const SizedBox(height: PikirSpacing.cardGap),
            PikirCard(
              color: PikirColors.primaryContainer,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: PikirColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_note!, style: PikirText.body)),
                ],
              ),
            ),
          ],
          const SizedBox(height: PikirSpacing.cardGap),
          const _PermissionSummaryCard(),
        ],
      ),
    );
  }
}

class _DemoAction extends StatelessWidget {
  const _DemoAction({
    required this.icon,
    required this.label,
    required this.detail,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String detail;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PikirCard(
      onTap: enabled ? onTap : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: PikirColors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: PikirColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: PikirText.title),
                const SizedBox(height: 4),
                Text(detail, style: PikirText.captionSecondary),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: PikirColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

/// Whether the permissions the demo depends on are switched on.
///
/// Detail lives on the permission page rather than here; this only answers the
/// question somebody about to record has: is the detection actually live, or
/// will the buttons above be the only thing firing? Saying so plainly is more
/// useful than letting a recording be made in the belief that it is live.
class _PermissionSummaryCard extends ConsumerStatefulWidget {
  const _PermissionSummaryCard();

  @override
  ConsumerState<_PermissionSummaryCard> createState() =>
      _PermissionSummaryCardState();
}

class _PermissionSummaryCardState
    extends ConsumerState<_PermissionSummaryCard>
    with WidgetsBindingObserver {
  int _watchedCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _countWatchedApps();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Rechecked on return, because the user grants these in Android's own
    // settings and comes back expecting the app to have noticed.
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(permissionStatusProvider);
    }
  }

  Future<void> _countWatchedApps() async {
    final watched = await ScreenChannel.watchedApps();
    if (mounted) setState(() => _watchedCount = watched.length);
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(permissionStatusProvider).value;
    // Unknown counts as missing: better to under-promise on a screen whose
    // whole job is to say whether the real triggers are live.
    final missing = status?.missing.length ?? PikirPermission.values.length;
    final total = status?.total ?? PikirPermission.values.length;
    final allGranted = status?.allGranted ?? false;

    return PikirCard(
      outlined: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Izin perlindungan', style: PikirText.title),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: StatusChip(
                  status: allGranted ? PikirStatus.safe : PikirStatus.caution,
                  label: allGranted
                      ? 'Semua aktif'
                      : '$missing dari $total mati',
                  quiet: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            allGranted
                ? 'Pemicu asli sudah hidup: checkout paylater dan pembukaan '
                      'aplikasi pinjaman di $_watchedCount aplikasi terdaftar, '
                      'serta pemindaian notifikasi yang masuk.'
                : 'Selama izinnya belum lengkap, alur di atas hanya bisa '
                      'dipicu dari tombol ini, bukan dari aplikasi sungguhan.',
            style: PikirText.bodySecondary,
          ),
          const SizedBox(height: PikirSpacing.cardGap),
          PikirButton(
            label: 'Atur izin',
            variant: PikirButtonVariant.outlined,
            onPressed: () =>
                Navigator.of(context).pushNamed(Routes.pengaturanIzin),
          ),
        ],
      ),
    );
  }
}
