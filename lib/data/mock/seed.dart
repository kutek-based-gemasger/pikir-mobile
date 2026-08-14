import '../models/chat.dart';
import '../models/debt_entry.dart';
import '../models/decision_record.dart';
import '../models/emergency_fund.dart';
import '../models/income_profile.dart';
import '../models/mitigation.dart';
import '../models/notification_log.dart';

/// The fixed starting state for the demo.
///
/// CLAUDE.md section 8 pins three figures so the screen recording always looks
/// the same: three ledger entries totalling Rp3.150.000, a debt ratio of 18
/// percent, and an emergency fund at Rp450.000 of a Rp1.000.000 tier one
/// target. Everything else here is derived to stay consistent with those, and
/// the derivations are spelled out because a demo whose numbers do not add up
/// is worse than one with no numbers at all.
abstract final class Seed {
  /// All dates are relative to this instant rather than to the real clock, so
  /// the demo does not drift as days pass.
  static final now = DateTime(2026, 8, 13, 21, 40);

  // --- Profil ---------------------------------------------------------

  /// Rp4.000.000 in, Rp2.400.000 of it already spoken for.
  static const profile = IncomeProfile(
    rhythm: IncomeRhythm.harian,
    monthlyIncome: 4000000,
    mandatoryMonthlyExpense: 2400000,
    dependents: 2,
    risk: JobRisk.kadang,
  );

  // --- Ledger ---------------------------------------------------------

  /// Principals total Rp3.150.000 and instalments total Rp720.000.
  ///
  /// Rp720.000 against Rp4.000.000 of income is exactly the 18 percent the
  /// brief calls for. The instalments are what make that number true, so they
  /// cannot be adjusted independently of it.
  static List<DebtEntry> debts() => [
    DebtEntry(
      id: 'debt-hp',
      purpose: 'HP baru',
      principal: 1250000,
      monthlyInstalment: 280000,
      category: DebtCategory.konsumtif,
      source: DebtSource.otomatis,
      recordedAt: DateTime(2026, 8, 12, 21, 40),
    ),
    DebtEntry(
      id: 'debt-dagangan',
      purpose: 'Modal dagangan',
      principal: 900000,
      monthlyInstalment: 190000,
      category: DebtCategory.modalKerjaHarian,
      source: DebtSource.manual,
      recordedAt: DateTime(2026, 8, 9, 8, 15),
    ),
    DebtEntry(
      id: 'debt-motor',
      purpose: 'Servis motor',
      principal: 1000000,
      monthlyInstalment: 250000,
      category: DebtCategory.perbaikiAlat,
      source: DebtSource.otomatis,
      recordedAt: DateTime(2026, 8, 5, 19, 2),
    ),
  ];

  // --- Riwayat keputusan ----------------------------------------------

  static List<DecisionRecord> decisions() => [
    DecisionRecord(
      id: 'dec-1',
      occurredAt: DateTime(2026, 8, 12, 21, 40),
      triggerContext: 'Checkout paylater Rp1.250.000',
      outcome: DecisionOutcome.ditunda,
      resultLine: 'Kamu memilih menabung 21 hari.',
    ),
    DecisionRecord(
      id: 'dec-2',
      occurredAt: DateTime(2026, 8, 9, 8, 15),
      triggerContext: 'Buka aplikasi pinjaman',
      outcome: DecisionOutcome.dilanjutkan,
      resultLine: 'Tercatat di ledger.',
    ),
    DecisionRecord(
      id: 'dec-3',
      occurredAt: DateTime(2026, 8, 5, 19, 2),
      triggerContext: 'Notifikasi ditahan',
      outcome: DecisionOutcome.diabaikan,
      resultLine: 'Kamu tidak jadi klik tautannya.',
    ),
  ];

  /// Counts, plus the interest not paid.
  ///
  /// Rp512.000 is eight pauses at the Rp64.000 of interest the opportunity
  /// cost screen quotes. SCREENS.md prints Rp1.250.000 in this slot, which is
  /// the purchase price rather than its interest and would show judges a
  /// figure that does not survive being asked about.
  static const decisionStats = DecisionStats(
    paused: 8,
    continued: 2,
    interestAvoided: 512000,
  );

  // --- Dana darurat ---------------------------------------------------

  /// Rp450.000 saved against a Rp1.000.000 first tier: 45 percent of the way.
  ///
  /// Tier three is three months of the Rp2.400.000 mandatory spend and is
  /// marked optional, because that target is out of reach on a daily income
  /// and pretending otherwise would just leave a bar permanently unfinished.
  static EmergencyFundPlan emergencyFund() => EmergencyFundPlan(
    currentAmount: 450000,
    tiers: const [
      EmergencyFundTier(
        level: 1,
        target: 1000000,
        covers: 'Menutup satu kejadian: servis motor atau berobat mendadak.',
      ),
      EmergencyFundTier(
        level: 2,
        target: 2000000,
        covers: 'Dua kejadian sekaligus, atau sepi order seminggu.',
      ),
      EmergencyFundTier(
        level: 3,
        target: 7200000,
        covers: 'Tiga bulan biaya hidup.',
        optional: true,
      ),
    ],
    deposits: [
      SavingsDeposit(
        id: 'dep-1',
        amount: 200000,
        recordedAt: DateTime(2026, 7, 28),
      ),
      SavingsDeposit(
        id: 'dep-2',
        amount: 150000,
        recordedAt: DateTime(2026, 8, 4),
      ),
      SavingsDeposit(
        id: 'dep-3',
        amount: 100000,
        recordedAt: DateTime(2026, 8, 11),
      ),
    ],
  );

  // --- Pemindai notifikasi --------------------------------------------

  /// Seven checked this week, two held back.
  static List<NotificationLog> notificationLogs() => [
    NotificationLog(
      id: 'log-1',
      time: DateTime(2026, 8, 12, 23, 41),
      sourceApp: 'DanaKilat',
      snippet:
          'Selamat! Limit kamu naik Rp5.000.000. Cair 3 menit tanpa BI '
          'Checking. Klik sekarang!',
      status: NotificationStatus.mencurigakan,
      reason:
          'Janji cair cepat tanpa cek riwayat kredit adalah ciri pinjaman '
          'ilegal.',
    ),
    NotificationLog(
      id: 'log-2',
      time: DateTime(2026, 8, 11, 20, 12),
      sourceApp: 'PinjamCepat',
      snippet: 'Pinjaman disetujui! Dana talangan langsung cair tanpa survey.',
      status: NotificationStatus.mencurigakan,
      reason: 'Menawarkan utang yang tidak kamu minta.',
    ),
    NotificationLog(
      id: 'log-3',
      time: DateTime(2026, 8, 11, 9, 30),
      sourceApp: 'Bank Sejahtera',
      snippet: 'Tagihan kartu kredit jatuh tempo 16 Agustus. Bayar minimum '
          'Rp320.000.',
      status: NotificationStatus.tagihan,
      reason: 'Terdeteksi sebagai pengingat jatuh tempo.',
    ),
    NotificationLog(
      id: 'log-4',
      time: DateTime(2026, 8, 10, 17, 5),
      sourceApp: 'DompetKu',
      snippet: 'Cicilan bulan ini jatuh tempo 3 hari lagi, Rp750.000.',
      status: NotificationStatus.tagihan,
      reason: 'Terdeteksi sebagai pengingat jatuh tempo.',
    ),
    NotificationLog(
      id: 'log-5',
      time: DateTime(2026, 8, 10, 12, 44),
      sourceApp: 'Chat',
      snippet: 'Bang, order sampai jam berapa hari ini?',
      status: NotificationStatus.aman,
    ),
    NotificationLog(
      id: 'log-6',
      time: DateTime(2026, 8, 9, 19, 20),
      sourceApp: 'Toko Online',
      snippet: 'Pesananmu sudah dikirim dan sedang dalam perjalanan.',
      status: NotificationStatus.aman,
    ),
    NotificationLog(
      id: 'log-7',
      time: DateTime(2026, 8, 9, 7, 2),
      sourceApp: 'Cuaca',
      snippet: 'Hujan ringan diperkirakan sore ini.',
      status: NotificationStatus.aman,
    ),
  ];

  /// The two inside the seven-day window total Rp1.070.000.
  static List<DetectedBill> detectedBills() => [
    DetectedBill(
      id: 'bill-1',
      sourceApp: 'DompetKu',
      amount: 750000,
      dueDate: DateTime(2026, 8, 16),
    ),
    DetectedBill(
      id: 'bill-2',
      sourceApp: 'Bank Sejahtera',
      amount: 320000,
      dueDate: DateTime(2026, 8, 13),
    ),
    DetectedBill(
      id: 'bill-3',
      sourceApp: 'KreditAman',
      amount: 300000,
      dueDate: DateTime(2026, 8, 25),
    ),
  ];

  // --- Mitigasi, jalur produktif ---------------------------------------

  /// Financing for a Rp1.800.000 need, ordered fastest first.
  ///
  /// Note the ordering costs money: Pegadaian pays out today and costs
  /// Rp135.000, while KUR is the cheapest at Rp90.000 but takes up to a week.
  /// That trade is the user's to make, so both numbers are on the card. What
  /// the app will not do is silently sort by price and leave someone whose
  /// motorbike broke this morning scrolling for an option that arrives in
  /// time.
  static List<FinancingOption> financingOptions() => const [
    FinancingOption(
      id: 'fin-pegadaian',
      name: 'Gadai barang di Pegadaian',
      disbursementLabel: 'Hari ini',
      disbursementDays: 0,
      principal: 1800000,
      totalReturn: 1935000,
      serviceFee: 135000,
      cautionLine:
          'Biaya titip dihitung per 15 hari. Barangmu ditahan sampai lunas.',
      trustBadge: 'BUMN',
      sourceLabel: 'Pegadaian - Tarif Gadai',
    ),
    FinancingOption(
      id: 'fin-koperasi',
      name: 'Koperasi simpan pinjam terdaftar',
      disbursementLabel: '1-2 hari',
      disbursementDays: 1,
      principal: 1800000,
      totalReturn: 1980000,
      serviceFee: 180000,
      cautionLine:
          'Kalau telat bayar, dendanya berjalan harian. Pastikan cicilan '
          'tetap di bawah 30% penghasilanmu.',
      trustBadge: 'Terdaftar OJK',
      sourceLabel: 'OJK - Daftar Koperasi Berizin',
    ),
    FinancingOption(
      id: 'fin-kur',
      name: 'KUR Mikro bank himbara',
      disbursementLabel: '3-7 hari',
      disbursementDays: 3,
      principal: 1800000,
      totalReturn: 1890000,
      serviceFee: 90000,
      cautionLine:
          'Butuh surat keterangan usaha. Prosesnya paling lama, tapi '
          'biayanya paling kecil.',
      trustBadge: 'Program pemerintah',
      sourceLabel: 'Kemenko Perekonomian - KUR',
    ),
  ];

  // --- Mitigasi, jalur kebutuhan mendesak ------------------------------

  /// Rights and assistance. No loan product appears on this branch, ever.
  static List<AssistanceProgram> assistancePrograms() => const [
    AssistanceProgram(
      id: 'aid-pbi',
      name: 'BPJS Kesehatan PBI',
      provider: 'Dinas Sosial dan BPJS Kesehatan',
      whatYouGet: 'Iuran BPJS dibayar pemerintah, berobat tidak bayar.',
      requirements: [
        'KTP dan KK',
        'Terdaftar di data kesejahteraan sosial kelurahan',
      ],
      howToApply: [
        'Datang ke kelurahan, minta surat pengantar',
        'Bawa ke Dinas Sosial untuk didaftarkan',
        'Cek status kepesertaan di kantor BPJS terdekat',
      ],
      sourceLabel: 'BPJS Kesehatan - Peserta PBI',
    ),
    AssistanceProgram(
      id: 'aid-sembako',
      name: 'Program Sembako',
      provider: 'Kementerian Sosial',
      whatYouGet: 'Bantuan pangan bulanan lewat kartu, dicairkan di e-warong.',
      requirements: ['KTP dan KK', 'Terdaftar di DTKS'],
      howToApply: [
        'Cek nama di cekbansos.kemensos.go.id',
        'Kalau belum ada, ajukan lewat kelurahan',
      ],
      sourceLabel: 'Kemensos - Program Sembako',
    ),
    AssistanceProgram(
      id: 'aid-pkh',
      name: 'Program Keluarga Harapan',
      provider: 'Kementerian Sosial',
      whatYouGet:
          'Bantuan tunai berkala untuk keluarga dengan anak sekolah, ibu '
          'hamil, atau lansia.',
      requirements: ['Terdaftar di DTKS', 'Memenuhi komponen PKH'],
      howToApply: [
        'Cek nama di cekbansos.kemensos.go.id',
        'Hubungi pendamping PKH di kecamatan',
      ],
      sourceLabel: 'Kemensos - PKH',
    ),
  ];

  // --- Mitigasi, jalur konsumtif ---------------------------------------

  /// What a Rp1.250.000 paylater actually costs.
  ///
  /// Rp64.000 of interest, and an instalment of Rp657.000 a month over two
  /// months. Added to the existing Rp720.000, that is Rp1.377.000 against
  /// Rp4.000.000, or 34 percent, up from 18. Those two numbers are what the
  /// reflection screen shows side by side.
  static const opportunityCost = OpportunityCost(
    itemName: 'HP baru',
    price: 1250000,
    interestIfBorrowed: 64000,
    comparison: 'Setara 8 kali makan, atau 1,5 hari penghasilanmu.',
    daysToSave: 21,
    suggestedMonthlySaving: 420000,
  );

  /// The instalment the opportunity cost figures above are built from.
  static const paylaterMonthlyInstalment = 657000;

  // --- Tanya PIKIR ------------------------------------------------------

  static const chatSuggestions = [
    'Bunga 0,4% per hari itu berapa setahun?',
    'Aplikasi ini legal atau tidak?',
    'Saya telat bayar 3 hari, apa yang terjadi?',
    'Bagaimana cara daftar BPJS PBI?',
  ];

  /// A canned answer, complete with its working and its sources.
  ///
  /// Every assistant reply in the mock carries citations, because an answer
  /// the user cannot check is exactly what the predatory apps also offer.
  static ChatMessage cannedAnswer(String id, DateTime at) => ChatMessage(
    id: id,
    role: ChatRole.assistant,
    text:
        '0,4% per hari berarti sekitar 146% per tahun. Artinya, pinjaman '
        'Rp1.000.000 selama setahun bisa jadi Rp2.460.000.',
    sentAt: at,
    calculation: '0,4% x 365 hari = 146%',
    sources: const [
      ChatSource(label: 'OJK - POJK Pinjaman Daring'),
      ChatSource(label: 'AFPI - Pedoman Bunga'),
    ],
  );

  /// The polite out-of-domain refusal, styled as a normal answer.
  static ChatMessage refusal(String id, DateTime at) => ChatMessage(
    id: id,
    role: ChatRole.assistant,
    text:
        'Maaf, aku hanya bisa bantu soal utang, pinjaman, dan program '
        'bantuan. Untuk investasi, sebaiknya tanya ke perencana keuangan '
        'berizin.',
    sentAt: at,
    isRefusal: true,
  );
}
