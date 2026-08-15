import 'package:sqflite_sqlcipher/sqflite.dart';

import '../models/chat.dart';
import 'secure_key_store.dart';

/// The encrypted local database.
///
/// SQLite through SQLCipher, so the file on disk is AES-256 ciphertext rather
/// than a readable database. This is what backs the privacy screen's claim
/// that records are locked on the device, and it is the only store the ledger,
/// the chat history, and the emergency fund profile are written to.
///
/// Nothing here syncs anywhere. There is no account to sync to.
class PikirDatabase {
  PikirDatabase({SecureKeyStore? keyStore})
    : _keyStore = keyStore ?? const SecureKeyStore();

  static const _fileName = 'pikir.db';
  static const _version = 1;

  final SecureKeyStore _keyStore;
  Database? _db;

  Future<Database> open() async {
    final existing = _db;
    if (existing != null) return existing;

    final password = await _keyStore.databaseKey();
    final path = '${await getDatabasesPath()}/$_fileName';

    final db = await openDatabase(
      path,
      password: password,
      version: _version,
      onCreate: _createSchema,
      onOpen: (db) => _purgeExpiredChats(db),
    );

    _db = db;
    return db;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE debts (
        id TEXT PRIMARY KEY,
        purpose TEXT NOT NULL,
        principal INTEGER NOT NULL,
        monthly_instalment INTEGER NOT NULL,
        category TEXT,
        source TEXT NOT NULL,
        recorded_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE decisions (
        id TEXT PRIMARY KEY,
        occurred_at TEXT NOT NULL,
        trigger_context TEXT NOT NULL,
        outcome TEXT NOT NULL,
        result_line TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        rhythm TEXT,
        monthly_income INTEGER NOT NULL,
        mandatory_expense INTEGER NOT NULL,
        dependents INTEGER NOT NULL,
        risk TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE emergency_fund (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        current_amount INTEGER NOT NULL,
        tiers_json TEXT NOT NULL,
        reminder_json TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE deposits (
        id TEXT PRIMARY KEY,
        amount INTEGER NOT NULL,
        recorded_at TEXT NOT NULL
      )
    ''');

    // Chat is stored with its creation time so the 24 hour sweep has something
    // to compare against. The proposal promises the history does not outlive a
    // day, and that promise has to be enforced by the store rather than by the
    // screen remembering to ask.
    await db.execute('''
      CREATE TABLE chat_sessions (
        id TEXT PRIMARY KEY,
        created_at TEXT NOT NULL,
        last_activity_at TEXT NOT NULL,
        context_label TEXT,
        context_detail TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        role TEXT NOT NULL,
        text TEXT NOT NULL,
        sent_at TEXT NOT NULL,
        calculation TEXT,
        is_refusal INTEGER NOT NULL DEFAULT 0,
        sources_json TEXT NOT NULL DEFAULT '[]',
        FOREIGN KEY (session_id) REFERENCES chat_sessions (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Deletes chat older than [kChatHistoryLifetime].
  ///
  /// Runs on every open rather than on a timer, because the app is not running
  /// most of the time and a timer would only fire for users who happen to keep
  /// it open. Encryption protects the file at rest; this is what stops it
  /// accumulating in the first place.
  static Future<int> _purgeExpiredChats(Database db) async {
    final cutoff = DateTime.now().subtract(kChatHistoryLifetime);
    return db.delete(
      'chat_sessions',
      where: 'created_at < ?',
      whereArgs: [cutoff.toIso8601String()],
    );
  }

  Future<int> purgeExpiredChats() async => _purgeExpiredChats(await open());

  /// Empties every table, keeping the file and its key.
  ///
  /// This is Mode Demo's reset, which immediately reseeds afterwards.
  Future<void> wipe() async {
    final db = await open();
    await db.transaction((txn) async {
      for (final table in const [
        'chat_messages',
        'chat_sessions',
        'deposits',
        'emergency_fund',
        'profile',
        'decisions',
        'debts',
      ]) {
        await txn.delete(table);
      }
    });
  }

  /// Deletes the database file itself.
  ///
  /// Used by "Hapus semua data di HP ini", where the key is destroyed too.
  /// The file has to go with it: emptying the tables would leave ciphertext on
  /// disk encrypted with a key that no longer exists, and the next launch
  /// would generate a fresh key that cannot open it. The store would be
  /// permanently unopenable rather than empty.
  ///
  /// Closing first matters for the same reason: an open handle would keep
  /// writing to a file that is being removed.
  Future<void> destroy() async {
    final path = '${await getDatabasesPath()}/$_fileName';
    await close();
    await deleteDatabase(path);
  }
}
