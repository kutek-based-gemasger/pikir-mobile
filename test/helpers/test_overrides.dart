import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Override is exported from misc.dart rather than the main entry point.
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
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
///
/// [overrides] are appended, so a test can replace something the mocks cannot
/// reach, such as a provider that reads a platform channel.
Widget mockScope({
  required Widget child,
  List<Override> overrides = const [],
}) {
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
      ...overrides,
    ],
    child: child,
  );
}

/// Answers the two service channels as if the OS had been asked.
///
/// Without this a channel call never completes under `flutter test`: nothing
/// is listening, so the future hangs rather than failing, and any screen that
/// waits on one sits on its spinner until the test times out. Call it from any
/// test that opens a screen reading a permission.
///
/// [granted] decides the answer for every permission at once, which is the
/// only distinction the screens make.
///
/// [postNotificationApplicable] stands in for the Android version: false is a
/// phone below API 33, where the OS grants notification posting at install
/// time and the permission page leaves it out entirely.
void mockServiceChannels({
  required bool granted,
  bool postNotificationApplicable = false,
}) {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  for (final channel in const [
    MethodChannel('com.pikir.pikir/screen'),
    MethodChannel('com.pikir.pikir/scanner'),
  ]) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      return switch (call.method) {
        'checkScreenAccess' ||
        'checkOverlayPermission' ||
        'checkNotificationAccess' ||
        'checkPostNotification' => granted,
        'postNotificationApplicable' => postNotificationApplicable,
        'requestPostNotification' => <String, Object?>{
          'granted': granted,
          'permanentlyDenied': false,
        },
        'watchedApps' => const <String>['com.tokopedia.tkpd'],
        // Nothing was detected, which is what a test with no trigger means.
        'consumePendingTrigger' => null,
        _ => null,
      };
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
  }
}
