/// Where implementations are chosen.
///
/// CLAUDE.md section 4: mock repositories are injected at the top so a real
/// implementation can replace them later without touching the UI. This file is
/// that top. Screens depend on the interfaces in repositories.dart and never
/// name a Mock class, so swapping one is an edit here and nowhere else.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local/method_channel_scanner_repository.dart';
import 'local/shared_preferences_scanner_repository.dart';
import 'mock/mock_repositories.dart';
import 'repositories/repositories.dart';

/// The shared in-memory state behind every mock.
///
/// Single instance so a debt recorded from an intervention shows up on the
/// home screen, and so Mode Demo's reset clears everything at once.
final mockStoreProvider = Provider<MockStore>((ref) => MockStore());

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => MockProfileRepository(ref.watch(mockStoreProvider)),
);

final ledgerRepositoryProvider = Provider<LedgerRepository>(
  (ref) => MockLedgerRepository(ref.watch(mockStoreProvider)),
);

final emergencyFundRepositoryProvider = Provider<EmergencyFundRepository>(
  (ref) => MockEmergencyFundRepository(ref.watch(mockStoreProvider)),
);

final interventionRepositoryProvider = Provider<InterventionRepository>(
  (ref) => MockInterventionRepository(ref.watch(mockStoreProvider)),
);

final mitigationRepositoryProvider = Provider<MitigationRepository>(
  (ref) => MockMitigationRepository(),
);

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => MockChatRepository(ref.watch(mockStoreProvider)),
);

final demoRepositoryProvider = Provider<DemoRepository>(
  (ref) => MockDemoRepository(ref.watch(mockStoreProvider)),
);

/// The notification scanner, currently served from seeded mock data.
///
/// [SharedPreferencesScannerRepository] already implements this same interface
/// against real on-device storage. Phase 5 switches the scanner screens to
/// live data by changing this one line to:
///
/// ```dart
/// final notificationScannerRepositoryProvider =
///     Provider<NotificationScannerRepository>(
///   (ref) => SharedPreferencesScannerRepository(),
/// );
/// ```
///
/// Read the notes on that class before flipping it. It stores notification
/// excerpts unencrypted, and its detectedBills is empty until due-date
/// extraction is written, so the Tagihan screen goes blank on the real source.
final notificationScannerRepositoryProvider =
    Provider<NotificationScannerRepository>(
      (ref) => MockNotificationScannerRepository(ref.watch(mockStoreProvider)),
    );

/// The Dart-side on-device store, for logs written by Flutter.
final sharedPreferencesScannerRepositoryProvider =
    Provider<SharedPreferencesScannerRepository>(
      (ref) => SharedPreferencesScannerRepository(),
    );

/// The live scan log written by the Android NotificationListenerService.
///
/// Reading this on a device with the listener permission granted returns real
/// notifications PIKIR has classified. It returns an empty list anywhere the
/// channel is absent, which includes every test and every non-Android host, so
/// pointing the screens at it is safe but would leave them blank in the demo
/// until the permission is granted on the recording device.
final platformScannerRepositoryProvider =
    Provider<MethodChannelScannerRepository>(
      (ref) => const MethodChannelScannerRepository(),
    );
