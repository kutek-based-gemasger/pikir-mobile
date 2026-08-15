import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pikir/data/mock/mock_repositories.dart';
import 'package:pikir/data/providers.dart';

/// Wraps [child] in a ProviderScope with every repository pointed at the
/// in-memory mocks.
///
/// The app itself runs on an encrypted SQLite database, which needs a platform
/// channel that `flutter test` does not provide. Overriding here rather than
/// weakening providers.dart keeps the production wiring honest: the app really
/// does use the encrypted store, and these tests really do exercise the same
/// screens through the same interfaces.
///
/// A fresh MockStore per call, so one test cannot leave state behind for the
/// next.
Widget mockScope({required Widget child}) {
  final store = MockStore();

  return ProviderScope(
    overrides: [
      mockStoreProvider.overrideWithValue(store),
      profileRepositoryProvider.overrideWith(
        (ref) => MockProfileRepository(store),
      ),
      ledgerRepositoryProvider.overrideWith(
        (ref) => MockLedgerRepository(store),
      ),
      emergencyFundRepositoryProvider.overrideWith(
        (ref) => MockEmergencyFundRepository(store),
      ),
      chatRepositoryProvider.overrideWith((ref) => MockChatRepository(store)),
      demoRepositoryProvider.overrideWith((ref) => MockDemoRepository(store)),
      notificationScannerRepositoryProvider.overrideWith(
        (ref) => MockNotificationScannerRepository(store),
      ),
    ],
    child: child,
  );
}
