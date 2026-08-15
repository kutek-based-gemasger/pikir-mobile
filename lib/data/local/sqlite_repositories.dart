/// Repositories backed by the encrypted database.
///
/// These are the real implementations of the same interfaces the mocks
/// satisfy, so switching between them is a change in providers.dart and
/// nothing else. The mocks stay: they are what the widget tests run against,
/// because sqflite needs a platform channel that a unit test does not have.
library;

import 'dart:convert';

import 'package:sqflite_sqlcipher/sqflite.dart';

import '../mock/seed.dart';
import '../models/chat.dart';
import '../models/debt_entry.dart';
import '../models/decision_record.dart';
import '../models/emergency_fund.dart';
import '../models/income_profile.dart';
import '../repositories/repositories.dart';
import 'pikir_database.dart';

/// Looks an enum up by name without throwing on unknown values.
T? _enumOrNull<T extends Enum>(List<T> values, String? name) {
  if (name == null) return null;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}

/// Writes the seeded starting state into an empty database.
///
/// Runs once on first open and again on Mode Demo's reset, so the recording
/// always begins from the figures CLAUDE.md section 8 pins.
class SeedInstaller {
  const SeedInstaller(this._database);

  final PikirDatabase _database;

  Future<void> installIfEmpty() async {
    final db = await _database.open();
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM debts'),
    );
    if ((count ?? 0) > 0) return;
    await install();
  }

  Future<void> install() async {
    final db = await _database.open();

    await db.transaction((txn) async {
      for (final debt in Seed.debts()) {
        await txn.insert('debts', _debtRow(debt));
      }
      for (final decision in Seed.decisions()) {
        await txn.insert('decisions', _decisionRow(decision));
      }

      const profile = Seed.profile;
      await txn.insert('profile', {
        'id': 1,
        'rhythm': profile.rhythm?.name,
        'monthly_income': profile.monthlyIncome,
        'mandatory_expense': profile.mandatoryMonthlyExpense,
        'dependents': profile.dependents,
        'risk': profile.risk?.name,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      final fund = Seed.emergencyFund();
      await txn.insert('emergency_fund', {
        'id': 1,
        'current_amount': fund.currentAmount,
        'tiers_json': jsonEncode([
          for (final tier in fund.tiers)
            {
              'level': tier.level,
              'target': tier.target,
              'covers': tier.covers,
              'optional': tier.optional,
            },
        ]),
        'reminder_json': jsonEncode(_reminderMap(fund.reminder)),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      for (final deposit in fund.deposits) {
        await txn.insert('deposits', {
          'id': deposit.id,
          'amount': deposit.amount,
          'recorded_at': deposit.recordedAt.toIso8601String(),
        });
      }
    });
  }
}

Map<String, Object?> _debtRow(DebtEntry debt) => {
  'id': debt.id,
  'purpose': debt.purpose,
  'principal': debt.principal,
  'monthly_instalment': debt.monthlyInstalment,
  'category': debt.category?.name,
  'source': debt.source.name,
  'recorded_at': debt.recordedAt.toIso8601String(),
  'settled_at': debt.settledAt?.toIso8601String(),
};

DebtEntry _debtFrom(Map<String, Object?> row) => DebtEntry(
  id: row['id']! as String,
  purpose: row['purpose']! as String,
  principal: row['principal']! as int,
  monthlyInstalment: row['monthly_instalment']! as int,
  category: _enumOrNull(DebtCategory.values, row['category'] as String?),
  source:
      _enumOrNull(DebtSource.values, row['source'] as String?) ??
      DebtSource.manual,
  recordedAt: DateTime.parse(row['recorded_at']! as String),
  settledAt: switch (row['settled_at']) {
    final String at => DateTime.parse(at),
    _ => null,
  },
);

Map<String, Object?> _decisionRow(DecisionRecord record) => {
  'id': record.id,
  'occurred_at': record.occurredAt.toIso8601String(),
  'trigger_context': record.triggerContext,
  'outcome': record.outcome.name,
  'result_line': record.resultLine,
};

Map<String, Object?> _reminderMap(SavingsReminder reminder) => {
  'enabled': reminder.enabled,
  'hour': reminder.hour,
  'minute': reminder.minute,
  'days': reminder.days.toList(),
  'mode': reminder.mode?.name,
  'percentage': reminder.percentage,
  'fixedAmount': reminder.fixedAmount,
};

SavingsReminder _reminderFrom(Map<String, Object?> json) => SavingsReminder(
  enabled: json['enabled'] as bool? ?? false,
  hour: json['hour'] as int?,
  minute: json['minute'] as int?,
  days: {...?(json['days'] as List?)?.cast<int>()},
  mode: _enumOrNull(SavingsMode.values, json['mode'] as String?),
  percentage: json['percentage'] as int?,
  fixedAmount: json['fixedAmount'] as int?,
);

class SqliteProfileRepository implements ProfileRepository {
  const SqliteProfileRepository(this._database);

  final PikirDatabase _database;

  @override
  Future<IncomeProfile> load() async {
    final db = await _database.open();
    final rows = await db.query('profile', where: 'id = 1');
    if (rows.isEmpty) return const IncomeProfile();

    final row = rows.first;
    return IncomeProfile(
      rhythm: _enumOrNull(IncomeRhythm.values, row['rhythm'] as String?),
      monthlyIncome: row['monthly_income']! as int,
      mandatoryMonthlyExpense: row['mandatory_expense']! as int,
      dependents: row['dependents']! as int,
      risk: _enumOrNull(JobRisk.values, row['risk'] as String?),
    );
  }

  @override
  Future<void> save(IncomeProfile profile) async {
    final db = await _database.open();
    await db.insert('profile', {
      'id': 1,
      'rhythm': profile.rhythm?.name,
      'monthly_income': profile.monthlyIncome,
      'mandatory_expense': profile.mandatoryMonthlyExpense,
      'dependents': profile.dependents,
      'risk': profile.risk?.name,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

class SqliteLedgerRepository implements LedgerRepository {
  const SqliteLedgerRepository(this._database, this._profile);

  final PikirDatabase _database;
  final ProfileRepository _profile;

  @override
  Future<List<DebtEntry>> debts() async {
    final db = await _database.open();
    final rows = await db.query('debts', orderBy: 'recorded_at DESC');
    return List.unmodifiable(rows.map(_debtFrom));
  }

  @override
  Future<DebtSummary> summary() async {
    final entries = await debts();
    final profile = await _profile.load();

    return DebtSummary.of(entries, income: profile.monthlyIncome);
  }

  @override
  Future<void> addDebt(DebtEntry entry) async {
    final db = await _database.open();
    await db.insert(
      'debts',
      _debtRow(entry),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeDebt(String id) async {
    final db = await _database.open();
    await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> setDebtSettled(String id, {required bool settled}) async {
    final db = await _database.open();
    await db.update(
      'debts',
      {'settled_at': settled ? DateTime.now().toIso8601String() : null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<DecisionRecord>> decisions() async {
    final db = await _database.open();
    final rows = await db.query('decisions', orderBy: 'occurred_at DESC');
    return List.unmodifiable(
      rows.map(
        (row) => DecisionRecord(
          id: row['id']! as String,
          occurredAt: DateTime.parse(row['occurred_at']! as String),
          triggerContext: row['trigger_context']! as String,
          outcome:
              _enumOrNull(DecisionOutcome.values, row['outcome'] as String?) ??
              DecisionOutcome.dilanjutkan,
          resultLine: row['result_line']! as String,
        ),
      ),
    );
  }

  @override
  Future<DecisionStats> decisionStats() async {
    final records = await decisions();
    var paused = 0;
    var continued = 0;
    for (final record in records) {
      if (record.outcome == DecisionOutcome.ditunda) paused++;
      if (record.outcome == DecisionOutcome.dilanjutkan) continued++;
    }

    // Counted from the records themselves rather than stored, so the strip
    // cannot drift away from the list beneath it.
    return DecisionStats(
      paused: paused,
      continued: continued,
      interestAvoided: paused * Seed.opportunityCost.interestIfBorrowed,
    );
  }

  @override
  Future<void> recordDecision(DecisionRecord record) async {
    final db = await _database.open();
    await db.insert(
      'decisions',
      _decisionRow(record),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

class SqliteEmergencyFundRepository implements EmergencyFundRepository {
  const SqliteEmergencyFundRepository(this._database);

  final PikirDatabase _database;

  @override
  Future<EmergencyFundPlan> plan() async {
    final db = await _database.open();
    final rows = await db.query('emergency_fund', where: 'id = 1');
    if (rows.isEmpty) return Seed.emergencyFund();

    final row = rows.first;
    final tiers = (jsonDecode(row['tiers_json']! as String) as List)
        .cast<Map<String, dynamic>>()
        .map(
          (t) => EmergencyFundTier(
            level: t['level'] as int,
            target: t['target'] as int,
            covers: t['covers'] as String,
            optional: t['optional'] as bool? ?? false,
          ),
        )
        .toList();

    final depositRows = await db.query('deposits', orderBy: 'recorded_at DESC');

    return EmergencyFundPlan(
      currentAmount: row['current_amount']! as int,
      tiers: tiers,
      deposits: depositRows
          .map(
            (d) => SavingsDeposit(
              id: d['id']! as String,
              amount: d['amount']! as int,
              recordedAt: DateTime.parse(d['recorded_at']! as String),
            ),
          )
          .toList(),
      reminder: _reminderFrom(
        jsonDecode(row['reminder_json']! as String) as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<EmergencyFundPlan> calculatePlan(IncomeProfile profile) async {
    // TODO(backend): POST /api/v1/planning/emergency-fund
    final base = profile.mandatoryMonthlyExpense;
    final risk = profile.risk ?? JobRisk.kadang;
    int round(int value) =>
        ((value / 50000).round() * 50000).clamp(50000, 1 << 40);

    final tier1 = round(base * risk.weight ~/ 2);
    final current = await plan();

    final tiers = [
      EmergencyFundTier(
        level: 1,
        target: tier1,
        covers: 'Menutup satu kejadian: servis motor atau berobat mendadak.',
      ),
      EmergencyFundTier(
        level: 2,
        target: round(tier1 * 2),
        covers: 'Dua kejadian sekaligus, atau sepi order seminggu.',
      ),
      EmergencyFundTier(
        level: 3,
        target: round(base * 3),
        covers: 'Tiga bulan biaya hidup.',
        optional: true,
      ),
    ];

    await _write(current.currentAmount, tiers, current.reminder);
    return plan();
  }

  @override
  Future<void> addDeposit(SavingsDeposit deposit) async {
    final db = await _database.open();
    final current = await plan();

    await db.transaction((txn) async {
      await txn.insert('deposits', {
        'id': deposit.id,
        'amount': deposit.amount,
        'recorded_at': deposit.recordedAt.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await txn.update(
        'emergency_fund',
        {'current_amount': current.currentAmount + deposit.amount},
        where: 'id = 1',
      );
    });
  }

  @override
  Future<void> saveReminder(SavingsReminder reminder) async {
    final current = await plan();
    await _write(current.currentAmount, current.tiers, reminder);
  }

  Future<void> _write(
    int amount,
    List<EmergencyFundTier> tiers,
    SavingsReminder reminder,
  ) async {
    final db = await _database.open();
    await db.insert('emergency_fund', {
      'id': 1,
      'current_amount': amount,
      'tiers_json': jsonEncode([
        for (final tier in tiers)
          {
            'level': tier.level,
            'target': tier.target,
            'covers': tier.covers,
            'optional': tier.optional,
          },
      ]),
      'reminder_json': jsonEncode(_reminderMap(reminder)),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

class SqliteChatRepository implements ChatRepository {
  SqliteChatRepository(this._database);

  final PikirDatabase _database;
  var _counter = 0;

  String _nextId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_counter++}';

  @override
  Future<ChatSession?> currentSession() async {
    final db = await _database.open();
    final rows = await db.query(
      'chat_sessions',
      orderBy: 'last_activity_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _sessionFrom(db, rows.first);
  }

  Future<ChatSession> _sessionFrom(Database db, Map<String, Object?> row) async {
    final id = row['id']! as String;
    final messageRows = await db.query(
      'chat_messages',
      where: 'session_id = ?',
      whereArgs: [id],
      orderBy: 'sent_at ASC',
    );

    final label = row['context_label'] as String?;
    final detail = row['context_detail'] as String?;

    return ChatSession(
      id: id,
      createdAt: DateTime.parse(row['created_at']! as String),
      lastActivityAt: DateTime.parse(row['last_activity_at']! as String),
      context: label == null || detail == null
          ? null
          : ChatContext(label: label, detail: detail),
      messages: messageRows.map((m) {
        final sources = (jsonDecode(m['sources_json']! as String) as List)
            .cast<Map<String, dynamic>>()
            .map(
              (s) => ChatSource(
                label: s['label'] as String,
                url: s['url'] as String?,
              ),
            )
            .toList();

        return ChatMessage(
          id: m['id']! as String,
          role: _enumOrNull(ChatRole.values, m['role'] as String?) ??
              ChatRole.assistant,
          text: m['text']! as String,
          sentAt: DateTime.parse(m['sent_at']! as String),
          calculation: m['calculation'] as String?,
          isRefusal: (m['is_refusal']! as int) == 1,
          sources: sources,
        );
      }).toList(),
    );
  }

  @override
  Future<ChatSession> startSession({ChatContext? context}) async {
    final db = await _database.open();
    final now = DateTime.now();
    final id = _nextId('session');

    await db.insert('chat_sessions', {
      'id': id,
      'created_at': now.toIso8601String(),
      'last_activity_at': now.toIso8601String(),
      'context_label': context?.label,
      'context_detail': context?.detail,
    });

    if (context != null) {
      await _insertMessage(
        db,
        id,
        ChatMessage(
          id: _nextId('msg'),
          role: ChatRole.assistant,
          text:
              'Aku lihat kamu sedang menimbang ${context.label}. Mau aku '
              'jelaskan syarat dan risikonya?',
          sentAt: now,
        ),
      );
    }

    return (await currentSession())!;
  }

  @override
  Future<ChatSession> send(String sessionId, String text) async {
    // TODO(backend): POST /api/v1/chat/advisor
    //
    // Only session.windowedMessages is ever sent: the last ten, per the
    // handoff's sliding window.
    final db = await _database.open();
    final askedAt = DateTime.now();

    await _insertMessage(
      db,
      sessionId,
      ChatMessage(
        id: _nextId('msg'),
        role: ChatRole.user,
        text: text,
        sentAt: askedAt,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 900));

    final repliedAt = DateTime.now();
    final lowered = text.toLowerCase();
    final offTopic =
        lowered.contains('saham') ||
        lowered.contains('kripto') ||
        lowered.contains('crypto') ||
        lowered.contains('trading');

    await _insertMessage(
      db,
      sessionId,
      offTopic
          ? Seed.refusal(_nextId('msg'), repliedAt)
          : Seed.cannedAnswer(_nextId('msg'), repliedAt),
    );

    await db.update(
      'chat_sessions',
      {'last_activity_at': repliedAt.toIso8601String()},
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    return (await currentSession())!;
  }

  Future<void> _insertMessage(
    Database db,
    String sessionId,
    ChatMessage message,
  ) {
    return db.insert('chat_messages', {
      'id': message.id,
      'session_id': sessionId,
      'role': message.role.name,
      'text': message.text,
      'sent_at': message.sentAt.toIso8601String(),
      'calculation': message.calculation,
      'is_refusal': message.isRefusal ? 1 : 0,
      'sources_json': jsonEncode([
        for (final source in message.sources)
          {'label': source.label, 'url': source.url},
      ]),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> purgeExpired() => _database.purgeExpiredChats();
}

/// Restores the seeded state, for Mode Demo.
class SqliteDemoRepository implements DemoRepository {
  const SqliteDemoRepository(this._database);

  final PikirDatabase _database;

  @override
  Future<void> resetToSeed() async {
    await _database.wipe();
    await SeedInstaller(_database).install();
  }
}
