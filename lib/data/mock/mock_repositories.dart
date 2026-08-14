/// In-memory implementations backed by [Seed].
///
/// No network, no database. Every method that stands where a real API call
/// would go carries the endpoint name from the handoff, so wiring a backend
/// later is a matter of following the TODOs rather than rediscovering them.
///
/// The small artificial delays are not decoration. They make the UI exercise
/// its own loading and timeout paths during the demo, which is the only way
/// the mandatory offline fallback ever gets seen before it matters.
library;

import '../models/chat.dart';
import '../models/debt_entry.dart';
import '../models/decision_record.dart';
import '../models/emergency_fund.dart';
import '../models/income_profile.dart';
import '../models/intervention.dart';
import '../models/mitigation.dart';
import '../models/notification_log.dart';
import '../repositories/repositories.dart';
import 'seed.dart';

/// Shared in-memory state, so the ledger a decision writes to is the same one
/// the home screen reads from.
class MockStore {
  MockStore() {
    resetToSeed();
  }

  late IncomeProfile profile;
  late List<DebtEntry> debts;
  late List<DecisionRecord> decisions;
  late DecisionStats decisionStats;
  late EmergencyFundPlan emergencyFund;
  late List<NotificationLog> notificationLogs;
  late List<DetectedBill> detectedBills;
  late bool scannerEnabled;
  ChatSession? chatSession;

  void resetToSeed() {
    profile = Seed.profile;
    debts = Seed.debts();
    decisions = Seed.decisions();
    decisionStats = Seed.decisionStats;
    emergencyFund = Seed.emergencyFund();
    notificationLogs = Seed.notificationLogs();
    detectedBills = Seed.detectedBills();
    scannerEnabled = true;
    chatSession = null;
  }
}

const _shortDelay = Duration(milliseconds: 220);
const _analysisDelay = Duration(milliseconds: 900);

class MockProfileRepository implements ProfileRepository {
  MockProfileRepository(this._store);

  final MockStore _store;

  @override
  Future<IncomeProfile> load() async {
    await Future<void>.delayed(_shortDelay);
    return _store.profile;
  }

  @override
  Future<void> save(IncomeProfile profile) async {
    await Future<void>.delayed(_shortDelay);
    _store.profile = profile;
  }
}

class MockLedgerRepository implements LedgerRepository {
  MockLedgerRepository(this._store);

  final MockStore _store;

  @override
  Future<List<DebtEntry>> debts() async {
    await Future<void>.delayed(_shortDelay);
    return List.unmodifiable(_store.debts);
  }

  @override
  Future<DebtSummary> summary() async {
    await Future<void>.delayed(_shortDelay);
    return _summarise();
  }

  DebtSummary _summarise() {
    var principal = 0;
    var instalment = 0;
    for (final debt in _store.debts) {
      principal += debt.principal;
      instalment += debt.monthlyInstalment;
    }
    return DebtSummary(
      totalActiveDebt: principal,
      monthlyInstalmentTotal: instalment,
      monthlyIncome: _store.profile.monthlyIncome,
    );
  }

  @override
  Future<void> addDebt(DebtEntry entry) async {
    await Future<void>.delayed(_shortDelay);
    _store.debts = [entry, ..._store.debts];
  }

  @override
  Future<void> removeDebt(String id) async {
    await Future<void>.delayed(_shortDelay);
    _store.debts = _store.debts.where((debt) => debt.id != id).toList();
  }

  @override
  Future<List<DecisionRecord>> decisions() async {
    await Future<void>.delayed(_shortDelay);
    return List.unmodifiable(_store.decisions);
  }

  @override
  Future<DecisionStats> decisionStats() async {
    await Future<void>.delayed(_shortDelay);
    return _store.decisionStats;
  }

  @override
  Future<void> recordDecision(DecisionRecord record) async {
    await Future<void>.delayed(_shortDelay);
    _store.decisions = [record, ..._store.decisions];
  }
}

class MockEmergencyFundRepository implements EmergencyFundRepository {
  MockEmergencyFundRepository(this._store);

  final MockStore _store;

  @override
  Future<EmergencyFundPlan> plan() async {
    await Future<void>.delayed(_shortDelay);
    return _store.emergencyFund;
  }

  @override
  Future<EmergencyFundPlan> calculatePlan(IncomeProfile profile) async {
    // TODO(backend): POST /api/v1/planning/emergency-fund
    await Future<void>.delayed(_analysisDelay);

    // Sized from the user's own numbers rather than a "three to six months of
    // salary" rule that does not survive contact with a daily income. Tier one
    // is one month of mandatory spend scaled by how often work stops; tier
    // three is three months and is marked optional precisely because it is out
    // of reach for most people this app is for.
    final base = profile.mandatoryMonthlyExpense;
    final risk = profile.risk ?? JobRisk.kadang;
    final tier1 = _roundToNearest(base * risk.weight ~/ 2, 50000);
    final tier2 = _roundToNearest(tier1 * 2, 50000);
    final tier3 = _roundToNearest(base * 3, 50000);

    final plan = EmergencyFundPlan(
      currentAmount: _store.emergencyFund.currentAmount,
      deposits: _store.emergencyFund.deposits,
      reminder: _store.emergencyFund.reminder,
      tiers: [
        EmergencyFundTier(
          level: 1,
          target: tier1,
          covers:
              'Menutup satu kejadian: servis motor atau berobat mendadak.',
        ),
        EmergencyFundTier(
          level: 2,
          target: tier2,
          covers: 'Dua kejadian sekaligus, atau sepi order seminggu.',
        ),
        EmergencyFundTier(
          level: 3,
          target: tier3,
          covers: 'Tiga bulan biaya hidup.',
          optional: true,
        ),
      ],
    );

    _store.emergencyFund = plan;
    return plan;
  }

  static int _roundToNearest(int value, int step) =>
      ((value / step).round() * step).clamp(step, 1 << 40);

  @override
  Future<void> addDeposit(SavingsDeposit deposit) async {
    await Future<void>.delayed(_shortDelay);
    final current = _store.emergencyFund;
    _store.emergencyFund = EmergencyFundPlan(
      currentAmount: current.currentAmount + deposit.amount,
      tiers: current.tiers,
      deposits: [deposit, ...current.deposits],
      reminder: current.reminder,
    );
  }

  @override
  Future<void> saveReminder(SavingsReminder reminder) async {
    await Future<void>.delayed(_shortDelay);
    final current = _store.emergencyFund;
    _store.emergencyFund = EmergencyFundPlan(
      currentAmount: current.currentAmount,
      tiers: current.tiers,
      deposits: current.deposits,
      reminder: reminder,
    );
  }
}

class MockInterventionRepository implements InterventionRepository {
  MockInterventionRepository(this._store);

  final MockStore _store;

  @override
  Future<InterventionAnalysis> analyze(InterventionRequest request) async {
    // TODO(backend): POST /api/v1/intervene/analyze
    //
    // Callers must race this against kInterventionTimeout and fall back to the
    // local offline screen. The mock stays comfortably inside the budget; a
    // real network call will not always.
    await Future<void>.delayed(_analysisDelay);

    var instalmentTotal = 0;
    for (final debt in _store.debts) {
      instalmentTotal += debt.monthlyInstalment;
    }
    final income = _store.profile.monthlyIncome;
    final ratioBefore = income <= 0 ? 0.0 : instalmentTotal / income;

    final newInstalment =
        request.amount ?? Seed.paylaterMonthlyInstalment;
    final ratioAfter =
        income <= 0 ? 0.0 : (instalmentTotal + newInstalment) / income;

    // Nothing to reflect on when the amount is small enough not to move the
    // ratio; offering to record it is more useful than a lecture.
    final trivial = ratioAfter - ratioBefore < 0.02;

    return InterventionAnalysis(
      action: trivial
          ? InterventionAction.recordToLedger
          : InterventionAction.showOpportunityCost,
      instalmentAmount: newInstalment,
      ratioBefore: ratioBefore,
      ratioAfter: ratioAfter,
      opportunityCost: trivial ? null : Seed.opportunityCost,
    );
  }
}

class MockMitigationRepository implements MitigationRepository {
  @override
  Future<MitigationResult> route(MitigationRequest request) async {
    // TODO(backend): POST /api/v1/mitigation/routing
    await Future<void>.delayed(_analysisDelay);

    switch (request.kind) {
      case NeedKind.konsumtif:
        // A want gets the opportunity cost and nothing else. No financing, and
        // no social assistance either: sending someone to the Dinas Sosial
        // because they want a new phone would be both useless and insulting.
        return MitigationResult(
          request: request,
          opportunityCost: Seed.opportunityCost,
        );

      case NeedKind.kebutuhanMendesak:
        // Rights and assistance only. This branch never shows a loan product,
        // at any interest rate.
        return MitigationResult(
          request: request,
          assistancePrograms: Seed.assistancePrograms(),
        );

      case NeedKind.produktif:
        final profit = request.monthlyNetProfit ?? 0;
        final paybackDays = profit <= 0
            ? 0
            : (request.amount / (profit / 30)).ceil();

        // Copied before sorting: the seed list is const, and sorting it in
        // place would both throw and let one request reorder the fixture for
        // every later one.
        final options = [...Seed.financingOptions()]
          // Fastest first. See MitigationResult.financingOptions for why this
          // ordering, and not cheapest first, is the default.
          ..sort(
            (a, b) => a.disbursementDays.compareTo(b.disbursementDays),
          );

        return MitigationResult(
          request: request,
          feasibility: FeasibilityResult(
            paybackDays: paybackDays,
            feasible: profit > 0 && paybackDays <= 90,
            explanation: profit <= 0
                ? 'Belum bisa dihitung karena untung bersihnya belum diisi.'
                : 'Dengan untung Rp${profit ~/ 1000} ribu per bulan, modalnya '
                      'kembali dalam sekitar $paybackDays hari.',
          ),
          financingOptions: options,
        );
    }
  }

  @override
  Future<FinancingOption?> financingOption(String id) async {
    await Future<void>.delayed(_shortDelay);
    for (final option in Seed.financingOptions()) {
      if (option.id == id) return option;
    }
    return null;
  }

  @override
  Future<AssistanceProgram?> assistanceProgram(String id) async {
    await Future<void>.delayed(_shortDelay);
    for (final program in Seed.assistancePrograms()) {
      if (program.id == id) return program;
    }
    return null;
  }
}

class MockNotificationScannerRepository
    implements NotificationScannerRepository {
  MockNotificationScannerRepository(this._store);

  final MockStore _store;

  @override
  Future<bool> isEnabled() async => _store.scannerEnabled;

  @override
  Future<void> setEnabled({required bool enabled}) async {
    _store.scannerEnabled = enabled;
  }

  @override
  Future<List<NotificationLog>> logs() async {
    await Future<void>.delayed(_shortDelay);
    final sorted = [..._store.notificationLogs]
      ..sort((a, b) => b.time.compareTo(a.time));
    return List.unmodifiable(sorted);
  }

  @override
  Future<void> record(NotificationLog log) async {
    _store.notificationLogs = [log, ..._store.notificationLogs];
  }

  @override
  Future<void> clearLogs() async {
    _store.notificationLogs = [];
  }

  @override
  Future<List<DetectedBill>> detectedBills() async {
    await Future<void>.delayed(_shortDelay);
    final sorted = [..._store.detectedBills]
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return List.unmodifiable(sorted);
  }

  @override
  Future<String> generateWarning(NotificationLog log) async {
    // TODO(backend): POST /api/v1/notification/generate-warning
    await Future<void>.delayed(_shortDelay);
    return log.reason ??
        'Pesan ini punya ciri tawaran pinjaman berisiko. Kami sembunyikan '
            'supaya kamu tidak tergoda dulu.';
  }
}

class MockChatRepository implements ChatRepository {
  MockChatRepository(this._store);

  final MockStore _store;

  var _counter = 0;

  String _nextId(String prefix) => '$prefix-${_counter++}';

  @override
  Future<ChatSession?> currentSession() async => _store.chatSession;

  @override
  Future<ChatSession> startSession({ChatContext? context}) async {
    final now = DateTime.now();
    final session = ChatSession(
      id: _nextId('session'),
      createdAt: now,
      lastActivityAt: now,
      context: context,
      messages: context == null
          ? const []
          : [
              ChatMessage(
                id: _nextId('msg'),
                role: ChatRole.assistant,
                text:
                    'Aku lihat kamu sedang menimbang ${context.label}. Mau '
                    'aku jelaskan syarat dan risikonya?',
                sentAt: now,
              ),
            ],
    );
    _store.chatSession = session;
    return session;
  }

  @override
  Future<ChatSession> send(String sessionId, String text) async {
    // TODO(backend): POST /api/v1/chat/advisor
    //
    // Only session.windowedMessages is ever sent: the last ten, per the
    // handoff's sliding window.
    final session = _store.chatSession;
    if (session == null) {
      throw StateError('Tidak ada sesi obrolan yang aktif.');
    }

    final askedAt = DateTime.now();
    final question = ChatMessage(
      id: _nextId('msg'),
      role: ChatRole.user,
      text: text,
      sentAt: askedAt,
    );

    await Future<void>.delayed(_analysisDelay);

    final repliedAt = DateTime.now();
    final lowered = text.toLowerCase();
    final offTopic =
        lowered.contains('saham') ||
        lowered.contains('kripto') ||
        lowered.contains('crypto') ||
        lowered.contains('trading');

    final answer = offTopic
        ? Seed.refusal(_nextId('msg'), repliedAt)
        : Seed.cannedAnswer(_nextId('msg'), repliedAt);

    final updated = session.copyWith(
      lastActivityAt: repliedAt,
      messages: [...session.messages, question, answer],
    );
    _store.chatSession = updated;
    return updated;
  }

  @override
  Future<void> purgeExpired() async {
    final session = _store.chatSession;
    if (session == null) return;
    if (session.isExpiredAt(DateTime.now())) {
      _store.chatSession = null;
    }
  }
}

class MockDemoRepository implements DemoRepository {
  MockDemoRepository(this._store);

  final MockStore _store;

  @override
  Future<void> resetToSeed() async {
    await Future<void>.delayed(_shortDelay);
    _store.resetToSeed();
  }
}
