import 'package:flutter_test/flutter_test.dart';
import 'package:pikir/data/local/shared_preferences_scanner_repository.dart';
import 'package:pikir/data/models/notification_log.dart';
import 'package:pikir/data/notification_classifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('classifier', () {
    test('flags predatory phrasing and says why', () {
      final result = NotificationClassifier.classify(
        'Selamat! Limit kamu naik Rp5.000.000. Cair 3 menit tanpa BI '
        'Checking. Klik sekarang!',
      );

      expect(result.status, NotificationStatus.mencurigakan);
      expect(result.reason, isNotNull);
      // A verdict the user cannot check is not much better than the offer it
      // is warning about.
      expect(result.signals, isNotEmpty);
    });

    test('sees through padded letters', () {
      // The squashing exists to defeat exactly this evasion.
      final result = NotificationClassifier.classify(
        'CAAAAIR 3 MENIIIT tanpa BI Cheeecking!!',
      );

      expect(result.status, NotificationStatus.mencurigakan);
    });

    test('does not emit a literal dollar-one from the squash', () {
      // Dart's replaceAll takes its replacement literally, so the handoff's
      // JavaScript-style r'$1' would have written "$1" into the text. Guard
      // the correction.
      final result = NotificationClassifier.classify('Halooo duniaaa');

      expect(result.status, NotificationStatus.aman);
      expect(
        NotificationLog.makeSnippet('Halooo duniaaa'),
        isNot(contains(r'$1')),
      );
    });

    test('recognises a due-date reminder without flagging it', () {
      final result = NotificationClassifier.classify(
        'Tagihan kartu kredit jatuh tempo 16 Agustus. Bayar minimum '
        'Rp320.000.',
      );

      // A real bill is the user's own business: recorded for awareness, never
      // dismissed.
      expect(result.status, NotificationStatus.tagihan);
    });

    test('leaves an ordinary message alone', () {
      final result = NotificationClassifier.classify(
        'Bang, order sampai jam berapa hari ini?',
      );

      expect(result.status, NotificationStatus.aman);
      expect(result.reason, isNull);
    });
  });

  group('NotificationLog', () {
    test('survives a JSON round trip', () {
      final original = NotificationLog(
        id: 'log-1',
        time: DateTime(2026, 8, 12, 23, 41),
        sourceApp: 'DanaKilat',
        snippet: 'Cair 3 menit tanpa BI Checking',
        status: NotificationStatus.mencurigakan,
        reason: 'Janji pencairan super cepat.',
      );

      final restored = NotificationLog.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.time, original.time);
      expect(restored.sourceApp, original.sourceApp);
      expect(restored.snippet, original.snippet);
      expect(restored.status, original.status);
      expect(restored.reason, original.reason);
    });

    test('trims long text to the snippet limit', () {
      final snippet = NotificationLog.makeSnippet('a' * 500);

      expect(snippet.length, NotificationLog.snippetLimit);
      expect(snippet, endsWith('…'));
    });

    test('an unknown stored status degrades to aman rather than throwing', () {
      final restored = NotificationLog.fromJson({
        'id': 'x',
        'time': 'not-a-date',
        'sourceApp': 'App',
        'snippet': 's',
        'status': 'sesuatu-yang-tidak-dikenal',
      });

      expect(restored.status, NotificationStatus.aman);
    });
  });

  group('SharedPreferences store', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<SharedPreferencesScannerRepository> build() async {
      final prefs = await SharedPreferences.getInstance();
      return SharedPreferencesScannerRepository(preferences: prefs);
    }

    test('scanning is off until switched on', () async {
      final repo = await build();

      expect(await repo.isEnabled(), isFalse);

      await repo.setEnabled(enabled: true);
      expect(await repo.isEnabled(), isTrue);
    });

    test('records and reads back, newest first', () async {
      final repo = await build();

      await repo.record(
        NotificationLog(
          id: 'old',
          time: DateTime(2026, 8, 10),
          sourceApp: 'A',
          snippet: 'lama',
          status: NotificationStatus.aman,
        ),
      );
      await repo.record(
        NotificationLog(
          id: 'new',
          time: DateTime(2026, 8, 12),
          sourceApp: 'B',
          snippet: 'baru',
          status: NotificationStatus.mencurigakan,
          reason: 'Janji pencairan super cepat.',
        ),
      );

      final logs = await repo.logs();

      expect(logs.map((l) => l.id), ['new', 'old']);
      expect(logs.first.status, NotificationStatus.mencurigakan);
    });

    test('clearing removes everything', () async {
      final repo = await build();
      await repo.record(
        NotificationLog(
          id: 'a',
          time: DateTime(2026, 8, 12),
          sourceApp: 'A',
          snippet: 's',
          status: NotificationStatus.aman,
        ),
      );

      await repo.clearLogs();

      expect(await repo.logs(), isEmpty);
    });

    test('a corrupted row is skipped, not fatal', () async {
      SharedPreferences.setMockInitialValues({
        'pikir.scanner.logs.v1': <String>['{ this is not json', '{}'],
      });
      final repo = await build();

      // Losing one row of history beats a scanner screen that crashes and
      // hides all of it.
      final logs = await repo.logs();
      expect(logs, hasLength(1));
    });

    test('the stored log is capped', () async {
      final repo = await build();

      for (var i = 0; i < SharedPreferencesScannerRepository.maxEntries + 20; i++) {
        await repo.record(
          NotificationLog(
            id: 'log-$i',
            time: DateTime(2026, 8, 12).add(Duration(minutes: i)),
            sourceApp: 'A',
            snippet: 's',
            status: NotificationStatus.aman,
          ),
        );
      }

      final logs = await repo.logs();
      expect(logs, hasLength(SharedPreferencesScannerRepository.maxEntries));
    });
  });
}
