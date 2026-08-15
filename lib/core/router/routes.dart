/// Every named route in PIKIR.
///
/// CLAUDE.md section 4: every screen is reachable from a named route, and no
/// screen may exist without an entry point. Route names live here as
/// constants so a typo is a compile error rather than a dead end at runtime.
abstract final class Routes {
  // --- Pemasangan -----------------------------------------------------
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const anonim = '/onboarding/anonim';
  static const izinLayar = '/onboarding/izin-layar';
  static const izinNotifikasi = '/onboarding/izin-notifikasi';
  static const profilFinansial = '/onboarding/profil';
  static const penyiapanSelesai = '/onboarding/selesai';

  // --- Dasbor ---------------------------------------------------------
  static const beranda = '/beranda';
  static const rasioUtang = '/beranda/rasio-utang';

  // --- Pengaturan -----------------------------------------------------
  static const pengaturan = '/pengaturan';
  static const privasi = '/pengaturan/privasi';

  /// The one place the three permissions are explained and switched on.
  ///
  /// Also shown once at launch while any of them is off, so the launch prompt
  /// and the settings entry cannot drift apart.
  static const pengaturanIzin = '/pengaturan/izin';
  static const demo = '/pengaturan/demo';

  // --- Fitur 1, intervensi preventif ----------------------------------
  static const intervensiBlanket = '/intervensi/blanket';
  static const intervensiTujuan = '/intervensi/tujuan';
  static const intervensiBarang = '/intervensi/barang';
  static const intervensiOpportunityCost = '/intervensi/opportunity-cost';
  static const intervensiCatatLedger = '/intervensi/catat';
  static const intervensiLuring = '/intervensi/luring';

  // --- Fitur 2, routing mitigasi --------------------------------------
  //
  // Need classification branches into three, not two, and the branches must
  // stay separate all the way to their results. See CLAUDE.md section 7.
  static const mitigasiKebutuhan = '/mitigasi/kebutuhan';
  static const mitigasiUrgensi = '/mitigasi/urgensi';
  static const mitigasiNominal = '/mitigasi/nominal';
  static const mitigasiUntung = '/mitigasi/untung';
  static const mitigasiUjiKelayakan = '/mitigasi/uji-kelayakan';
  static const mitigasiHasilKonsumtif = '/mitigasi/hasil-konsumtif';
  static const mitigasiHasilBantuan = '/mitigasi/hasil-bantuan';
  static const mitigasiHasilProduktif = '/mitigasi/hasil-produktif';
  static const mitigasiDetailBantuan = '/mitigasi/detail-bantuan';
  static const mitigasiDetailPembiayaan = '/mitigasi/detail-pembiayaan';

  // --- Fitur 3, pemindai notifikasi -----------------------------------
  static const scannerPeringatan = '/scanner/peringatan';
  static const scannerTagihan = '/scanner/tagihan';
  static const scannerPengaturan = '/scanner/pengaturan';

  // --- Fitur 4, dana darurat ------------------------------------------
  static const danaDarurat = '/dana-darurat';
  static const danaDaruratHitung = '/dana-darurat/hitung';
  static const danaDaruratSetoran = '/dana-darurat/setoran';
  static const danaDaruratPengingat = '/dana-darurat/pengingat';

  // --- Fitur 5, Tanya PIKIR -------------------------------------------
  static const chat = '/chat';
  static const chatSumber = '/chat/sumber';
  static const chatCatatLedger = '/chat/catat-ledger';

  // --- Ledger ---------------------------------------------------------
  static const ledger = '/ledger';
  static const ledgerTambah = '/ledger/tambah';

  // The decision history is a tab inside the ledger, not a screen of its
  // own: one door to it, not two, and the tab already works.

  // --- Perkakas pengembangan ------------------------------------------
  static const petaLayar = '/peta-layar';
}
