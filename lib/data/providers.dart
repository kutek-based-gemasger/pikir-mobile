/// Where implementations are chosen.
///
/// CLAUDE.md section 4: repositories are injected at the top so an
/// implementation can be replaced without touching the UI. This file is that
/// top, and it is now the only place that knows the app runs on an encrypted
/// database rather than on mock data.
///
/// The mocks have not gone anywhere. Widget tests override these providers
/// with them, because sqflite needs a platform channel a unit test does not
/// have, and because a test that seeds its own data is easier to read than one
/// that sets up a database first.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local/method_channel_scanner_repository.dart';
import 'local/pikir_database.dart';
import 'local/secure_key_store.dart';
import 'local/shared_preferences_scanner_repository.dart';
import 'local/sqlite_repositories.dart';
import 'mock/mock_repositories.dart';
import 'repositories/repositories.dart';

/// The encrypted database, opened once and shared.
final databaseProvider = Provider<PikirDatabase>((ref) {
  final database = PikirDatabase();
  ref.onDispose(database.close);
  return database;
});

final secureKeyStoreProvider = Provider<SecureKeyStore>(
  (ref) => const SecureKeyStore(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => SqliteProfileRepository(ref.watch(databaseProvider)),
);

final ledgerRepositoryProvider = Provider<LedgerRepository>(
  (ref) => SqliteLedgerRepository(
    ref.watch(databaseProvider),
    ref.watch(profileRepositoryProvider),
  ),
);

final emergencyFundRepositoryProvider = Provider<EmergencyFundRepository>(
  (ref) => SqliteEmergencyFundRepository(ref.watch(databaseProvider)),
);

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => SqliteChatRepository(ref.watch(databaseProvider)),
);

final demoRepositoryProvider = Provider<DemoRepository>(
  (ref) => SqliteDemoRepository(ref.watch(databaseProvider)),
);

/// Routing and intervention analysis have nothing to persist.
///
/// They compute a result from what the user just answered, so there is no
/// mock to replace: this is the real implementation until a backend exists,
/// and its call sites carry the endpoint names.
final mitigationRepositoryProvider = Provider<MitigationRepository>(
  (ref) => MockMitigationRepository(),
);

final interventionRepositoryProvider = Provider<InterventionRepository>(
  (ref) => MockInterventionRepository(ref.watch(mockStoreProvider)),
);

/// Backing state for the two computed repositories above.
final mockStoreProvider = Provider<MockStore>((ref) => MockStore());

/// The notification scanner, served from seeded mock data.
///
/// [MethodChannelScannerRepository] implements the same interface against the
/// live Android service. Pointing the scanner screens at real data is a change
/// to this one line:
///
/// ```dart
/// final notificationScannerRepositoryProvider =
///     Provider<NotificationScannerRepository>(
///   (ref) => const MethodChannelScannerRepository(),
/// );
/// ```
///
/// Read the notes on that class first. Its detectedBills is empty until
/// due-date extraction is written, so the Tagihan screen goes blank on the
/// real source.
final notificationScannerRepositoryProvider =
    Provider<NotificationScannerRepository>(
      (ref) => MockNotificationScannerRepository(ref.watch(mockStoreProvider)),
    );

/// The Dart-side key-value scan log, for logs written by Flutter.
final sharedPreferencesScannerRepositoryProvider =
    Provider<SharedPreferencesScannerRepository>(
      (ref) => SharedPreferencesScannerRepository(),
    );

/// The live scan log written by the Android NotificationListenerService.
final platformScannerRepositoryProvider =
    Provider<MethodChannelScannerRepository>(
      (ref) => const MethodChannelScannerRepository(),
    );
