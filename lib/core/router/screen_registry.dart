import 'package:flutter/widgets.dart';

import '../../features/chat/screens/catat_ke_ledger_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/chat/screens/sumber_screen.dart';
import '../../features/emergency_fund/screens/dana_darurat_screen.dart';
import '../../features/emergency_fund/screens/hitung_screen.dart';
import '../../features/emergency_fund/screens/pengingat_screen.dart';
import '../../features/emergency_fund/screens/setoran_screen.dart';
import '../../features/home/screens/beranda_screen.dart';
import '../../features/home/screens/rasio_utang_screen.dart';
import '../../features/intervention/screens/barang_konsumtif_screen.dart';
import '../../features/intervention/screens/blanket_screen.dart';
import '../../features/intervention/screens/catat_ledger_screen.dart';
import '../../features/intervention/screens/fallback_luring_screen.dart';
import '../../features/intervention/screens/opportunity_cost_screen.dart';
import '../../features/intervention/screens/tujuan_pinjaman_screen.dart';
import '../../features/ledger/screens/ledger_screen.dart';
import '../../features/ledger/screens/tambah_utang_screen.dart';
import '../../features/mitigation/screens/detail_bantuan_screen.dart';
import '../../features/mitigation/screens/detail_pembiayaan_screen.dart';
import '../../features/mitigation/screens/hasil_bantuan_screen.dart';
import '../../features/mitigation/screens/hasil_konsumtif_screen.dart';
import '../../features/mitigation/screens/hasil_produktif_screen.dart';
import '../../features/mitigation/screens/klasifikasi_kebutuhan_screen.dart';
import '../../features/mitigation/screens/klasifikasi_urgensi_screen.dart';
import '../../features/mitigation/screens/nominal_screen.dart';
import '../../features/mitigation/screens/uji_kelayakan_screen.dart';
import '../../features/mitigation/screens/untung_screen.dart';
import '../../features/notification_scanner/screens/peringatan_screen.dart';
import '../../features/notification_scanner/screens/scanner_pengaturan_screen.dart';
import '../../features/notification_scanner/screens/tagihan_screen.dart';
import '../../features/onboarding/screens/anonim_screen.dart';
import '../../features/onboarding/screens/izin_layar_screen.dart';
import '../../features/onboarding/screens/izin_notifikasi_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/penyiapan_selesai_screen.dart';
import '../../features/onboarding/screens/profil_finansial_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/settings/screens/demo_screen.dart';
import '../../features/settings/screens/pengaturan_screen.dart';
import '../../features/settings/screens/privasi_screen.dart';
import '../dev/screen_map_page.dart';
import 'routes.dart';

/// How screens are grouped when listed.
enum ScreenGroup {
  pemasangan('Pemasangan'),
  dasbor('Dasbor'),
  pengaturan('Pengaturan'),
  intervensi('Fitur 1, intervensi preventif'),
  mitigasi('Fitur 2, routing mitigasi'),
  scanner('Fitur 3, pemindai notifikasi'),
  danaDarurat('Fitur 4, dana darurat'),
  chat('Fitur 5, Tanya PIKIR'),
  ledger('Ledger'),
  perkakas('Perkakas pengembangan');

  const ScreenGroup(this.label);

  final String label;
}

/// One routable destination.
class ScreenEntry {
  const ScreenEntry({
    required this.route,
    required this.title,
    required this.group,
    required this.builder,
  });

  final String route;
  final String title;
  final ScreenGroup group;
  final WidgetBuilder builder;
}

/// Every destination in the app, in one list.
///
/// This is the single source for both the router and the screen map, so the
/// two cannot drift apart: a screen that is not here has no route, and a
/// route that exists is always listed. That is what makes CLAUDE.md section
/// 4's "no screen may exist without an entry point" checkable rather than
/// merely intended.
///
/// Two surfaces are deliberately absent. The notification shade treatments
/// (SCREENS.md layar 24A and 24B) are drawn by Android from a posted
/// notification, not by a Flutter route, and the hold-to-confirm state
/// (layar 16) is a state of the opportunity cost screen rather than a
/// separate destination.
final List<ScreenEntry> kScreenRegistry = [
  // --- Pemasangan -----------------------------------------------------
  ScreenEntry(
    route: Routes.splash,
    title: 'Splash',
    group: ScreenGroup.pemasangan,
    builder: (_) => const SplashScreen(),
  ),
  ScreenEntry(
    route: Routes.onboarding,
    title: 'Onboarding',
    group: ScreenGroup.pemasangan,
    builder: (_) => const OnboardingScreen(),
  ),
  ScreenEntry(
    route: Routes.anonim,
    title: 'Tanpa Akun, Tanpa Data Pribadi',
    group: ScreenGroup.pemasangan,
    builder: (_) => const AnonimScreen(),
  ),
  ScreenEntry(
    route: Routes.izinLayar,
    title: 'Izin Deteksi Layar',
    group: ScreenGroup.pemasangan,
    builder: (_) => const IzinLayarScreen(),
  ),
  ScreenEntry(
    route: Routes.izinNotifikasi,
    title: 'Izin Akses Notifikasi',
    group: ScreenGroup.pemasangan,
    builder: (_) => const IzinNotifikasiScreen(),
  ),
  ScreenEntry(
    route: Routes.profilFinansial,
    title: 'Profil Finansial Lokal',
    group: ScreenGroup.pemasangan,
    builder: (_) => const ProfilFinansialScreen(),
  ),
  ScreenEntry(
    route: Routes.penyiapanSelesai,
    title: 'Penyiapan Selesai',
    group: ScreenGroup.pemasangan,
    builder: (_) => const PenyiapanSelesaiScreen(),
  ),

  // --- Dasbor ---------------------------------------------------------
  ScreenEntry(
    route: Routes.beranda,
    title: 'Beranda',
    group: ScreenGroup.dasbor,
    builder: (_) => const BerandaScreen(),
  ),
  ScreenEntry(
    route: Routes.rasioUtang,
    title: 'Detail Rasio Utang',
    group: ScreenGroup.dasbor,
    builder: (_) => const RasioUtangScreen(),
  ),

  // --- Pengaturan -----------------------------------------------------
  ScreenEntry(
    route: Routes.pengaturan,
    title: 'Pengaturan',
    group: ScreenGroup.pengaturan,
    builder: (_) => const PengaturanScreen(),
  ),
  ScreenEntry(
    route: Routes.privasi,
    title: 'Privasi dan Data Saya',
    group: ScreenGroup.pengaturan,
    builder: (_) => const PrivasiScreen(),
  ),
  ScreenEntry(
    route: Routes.demo,
    title: 'Mode Demo',
    group: ScreenGroup.pengaturan,
    builder: (_) => const DemoScreen(),
  ),

  // --- Fitur 1 --------------------------------------------------------
  ScreenEntry(
    route: Routes.intervensiBlanket,
    title: 'Blanket Checkout Paylater',
    group: ScreenGroup.intervensi,
    builder: (_) => const BlanketScreen(),
  ),
  ScreenEntry(
    route: Routes.intervensiTujuan,
    title: 'Prompt Intervensi Aplikasi Pinjol',
    group: ScreenGroup.intervensi,
    builder: (_) => const TujuanPinjamanScreen(),
  ),
  ScreenEntry(
    route: Routes.intervensiBarang,
    title: 'Input Barang Konsumtif',
    group: ScreenGroup.intervensi,
    builder: (_) => const BarangKonsumtifScreen(),
  ),
  ScreenEntry(
    route: Routes.intervensiOpportunityCost,
    title: 'Overlay Opportunity Cost',
    group: ScreenGroup.intervensi,
    builder: (_) => const OpportunityCostScreen(),
  ),
  ScreenEntry(
    route: Routes.intervensiCatatLedger,
    title: 'Pengalihan ke Form Ledger',
    group: ScreenGroup.intervensi,
    builder: (_) => const CatatLedgerScreen(),
  ),
  ScreenEntry(
    route: Routes.intervensiLuring,
    title: 'Fallback Luring',
    group: ScreenGroup.intervensi,
    builder: (_) => const FallbackLuringScreen(),
  ),

  // --- Fitur 2 --------------------------------------------------------
  ScreenEntry(
    route: Routes.mitigasiKebutuhan,
    title: 'Klasifikasi Kebutuhan',
    group: ScreenGroup.mitigasi,
    builder: (_) => const KlasifikasiKebutuhanScreen(),
  ),
  ScreenEntry(
    route: Routes.mitigasiUrgensi,
    title: 'Klasifikasi Urgensi',
    group: ScreenGroup.mitigasi,
    builder: (_) => const KlasifikasiUrgensiScreen(),
  ),
  ScreenEntry(
    route: Routes.mitigasiNominal,
    title: 'Nominal yang Dibutuhkan',
    group: ScreenGroup.mitigasi,
    builder: (_) => const NominalScreen(),
  ),
  ScreenEntry(
    route: Routes.mitigasiUntung,
    title: 'Untung Bersih per Bulan',
    group: ScreenGroup.mitigasi,
    builder: (_) => const UntungScreen(),
  ),
  ScreenEntry(
    route: Routes.mitigasiUjiKelayakan,
    title: 'Uji Kelayakan Produktif',
    group: ScreenGroup.mitigasi,
    builder: (_) => const UjiKelayakanScreen(),
  ),
  ScreenEntry(
    route: Routes.mitigasiHasilKonsumtif,
    title: 'Hasil Jalur Konsumtif',
    group: ScreenGroup.mitigasi,
    builder: (_) => const HasilKonsumtifScreen(),
  ),
  ScreenEntry(
    route: Routes.mitigasiHasilBantuan,
    title: 'Hasil Jalur Kebutuhan Mendesak',
    group: ScreenGroup.mitigasi,
    builder: (_) => const HasilBantuanScreen(),
  ),
  ScreenEntry(
    route: Routes.mitigasiHasilProduktif,
    title: 'Hasil Jalur Produktif',
    group: ScreenGroup.mitigasi,
    builder: (_) => const HasilProduktifScreen(),
  ),
  ScreenEntry(
    route: Routes.mitigasiDetailBantuan,
    title: 'Detail Program Bantuan',
    group: ScreenGroup.mitigasi,
    builder: (_) => const DetailBantuanScreen(),
  ),
  ScreenEntry(
    route: Routes.mitigasiDetailPembiayaan,
    title: 'Detail Opsi Pembiayaan',
    group: ScreenGroup.mitigasi,
    builder: (_) => const DetailPembiayaanScreen(),
  ),

  // --- Fitur 3 --------------------------------------------------------
  ScreenEntry(
    route: Routes.scannerPeringatan,
    title: 'Detail Peringatan',
    group: ScreenGroup.scanner,
    builder: (_) => const PeringatanScreen(),
  ),
  ScreenEntry(
    route: Routes.scannerTagihan,
    title: 'Tagihan Terdeteksi',
    group: ScreenGroup.scanner,
    builder: (_) => const TagihanScreen(),
  ),
  ScreenEntry(
    route: Routes.scannerPengaturan,
    title: 'Pengaturan dan Riwayat Pemindaian',
    group: ScreenGroup.scanner,
    builder: (_) => const ScannerPengaturanScreen(),
  ),

  // --- Fitur 4 --------------------------------------------------------
  ScreenEntry(
    route: Routes.danaDarurat,
    title: 'Dasbor Target Dana Darurat',
    group: ScreenGroup.danaDarurat,
    builder: (_) => const DanaDaruratScreen(),
  ),
  ScreenEntry(
    route: Routes.danaDaruratHitung,
    title: 'Hitung Dana Darurat',
    group: ScreenGroup.danaDarurat,
    builder: (_) => const HitungDanaDaruratScreen(),
  ),
  ScreenEntry(
    route: Routes.danaDaruratSetoran,
    title: 'Catat Setoran',
    group: ScreenGroup.danaDarurat,
    builder: (_) => const SetoranScreen(),
  ),
  ScreenEntry(
    route: Routes.danaDaruratPengingat,
    title: 'Pengingat Menabung',
    group: ScreenGroup.danaDarurat,
    builder: (_) => const PengingatScreen(),
  ),

  // --- Fitur 5 --------------------------------------------------------
  ScreenEntry(
    route: Routes.chat,
    title: 'Tanya PIKIR',
    group: ScreenGroup.chat,
    builder: (_) => const ChatScreen(),
  ),
  ScreenEntry(
    route: Routes.chatSumber,
    title: 'Sumber Jawaban',
    group: ScreenGroup.chat,
    builder: (_) => const SumberJawabanScreen(),
  ),
  ScreenEntry(
    route: Routes.chatCatatLedger,
    title: 'Konfirmasi Catat ke Ledger',
    group: ScreenGroup.chat,
    builder: (_) => const CatatKeLedgerScreen(),
  ),

  // --- Ledger ---------------------------------------------------------
  ScreenEntry(
    route: Routes.ledger,
    title: 'Ledger Utang',
    group: ScreenGroup.ledger,
    builder: (_) => const LedgerScreen(),
  ),
  ScreenEntry(
    route: Routes.ledgerTambah,
    title: 'Tambah Utang Manual',
    group: ScreenGroup.ledger,
    builder: (_) => const TambahUtangScreen(),
  ),

  // --- Perkakas -------------------------------------------------------
  ScreenEntry(
    route: Routes.petaLayar,
    title: 'Peta Layar',
    group: ScreenGroup.perkakas,
    builder: (_) => const ScreenMapPage(),
  ),
];

/// Route name to entry, built once.
final Map<String, ScreenEntry> kScreenByRoute = {
  for (final entry in kScreenRegistry) entry.route: entry,
};
