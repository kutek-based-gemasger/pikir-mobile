import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/rupiah.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/providers.dart';
import '../../../data/queries.dart';
import '../widgets/settings_row.dart';

/// Settings.
///
/// There is no profile header, no avatar, and no account section, because the
/// app has none of those things. The list starts straight at what the user can
/// actually change.
class PengaturanScreen extends ConsumerWidget {
  const PengaturanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(incomeProfileProvider);
    final scannerEnabled = ref.watch(scannerEnabledProvider);
    final fund = ref.watch(emergencyFundProvider);

    final income = profile.value?.monthlyIncome;
    final tierOne = fund.value?.tiers.firstOrNull?.target;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          PikirSpacing.screenHorizontal,
          8,
          PikirSpacing.screenHorizontal,
          32,
        ),
        children: [
          SettingsGroup(
            title: 'Kondisi keuanganku',
            rows: [
              SettingsRow(
                label: 'Penghasilan dan risiko pekerjaan',
                detail: income == null
                    ? null
                    : '${formatRupiah(income)} per bulan',
                onTap: () =>
                    Navigator.of(context).pushNamed(Routes.profilFinansial),
              ),
              SettingsRow(
                label: 'Target dana darurat',
                detail: tierOne == null
                    ? null
                    : 'Tingkat 1 ${formatRupiah(tierOne)}',
                onTap: () =>
                    Navigator.of(context).pushNamed(Routes.danaDaruratHitung),
              ),
            ],
          ),
          const SizedBox(height: PikirSpacing.cardGap),
          SettingsGroup(
            title: 'Perlindungan',
            rows: [
              SettingsRow(
                label: 'Deteksi layar',
                detail: 'Aktif saat kamu buka aplikasi pinjaman atau checkout',
                onTap: () =>
                    Navigator.of(context).pushNamed(Routes.izinLayar),
              ),
              SettingsToggleRow(
                label: 'Pemindai notifikasi',
                detail: 'Diperiksa di dalam HP-mu, tanpa internet',
                value: scannerEnabled.value ?? false,
                onChanged: (value) async {
                  await ref
                      .read(notificationScannerRepositoryProvider)
                      .setEnabled(enabled: value);
                  ref.invalidate(scannerEnabledProvider);
                },
              ),
              SettingsRow(
                label: 'Riwayat pemindaian',
                onTap: () =>
                    Navigator.of(context).pushNamed(Routes.scannerPengaturan),
              ),
            ],
          ),
          const SizedBox(height: PikirSpacing.cardGap),
          SettingsGroup(
            title: 'Privasi',
            rows: [
              SettingsRow(
                label: 'Privasi dan data saya',
                onTap: () => Navigator.of(context).pushNamed(Routes.privasi),
              ),
              SettingsRow(
                label: 'Hapus semua data di HP ini',
                destructive: true,
                onTap: () => _confirmWipe(context, ref),
              ),
            ],
          ),
          const SizedBox(height: PikirSpacing.cardGap),
          SettingsGroup(
            title: 'Bantuan',
            rows: [
              SettingsRow(
                label: 'Hubungi OJK 157',
                detail: 'Untuk aduan soal pinjaman dan penagihan',
                icon: Icons.support_agent_outlined,
                onTap: null,
              ),
            ],
          ),
          const SizedBox(height: PikirSpacing.cardGap),
          SettingsGroup(
            title: 'Lainnya',
            rows: [
              SettingsRow(
                label: 'Mode demo',
                detail: 'Untuk perekaman layar',
                onTap: () => Navigator.of(context).pushNamed(Routes.demo),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Confirms before wiping, without shaming the choice.
  ///
  /// Both buttons are ordinary size and ordinary weight. The one that deletes
  /// is not made harder to reach than the one that backs out, and neither is
  /// worded to make the user feel bad for picking it.
  Future<void> _confirmWipe(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PikirColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PikirRadius.card),
        ),
        title: Text('Hapus semua data di HP ini?', style: PikirText.title),
        content: Text(
          'Catatan utang, target dana darurat, dan riwayat obrolan akan '
          'hilang. Ini tidak bisa dibatalkan.',
          style: PikirText.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Batal',
              style: PikirText.button.copyWith(
                color: PikirColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Hapus',
              style: PikirText.button.copyWith(color: PikirColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(demoRepositoryProvider).resetToSeed();
    ref.invalidate(debtsProvider);
    ref.invalidate(debtSummaryProvider);
    ref.invalidate(emergencyFundProvider);
    ref.invalidate(scannerLogsProvider);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Data di HP ini sudah dihapus.',
          style: PikirText.body.copyWith(color: PikirColors.onPrimary),
        ),
        backgroundColor: PikirColors.textPrimary,
      ),
    );
  }
}
