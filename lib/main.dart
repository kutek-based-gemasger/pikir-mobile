import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/local/pikir_database.dart';
import 'data/local/sqlite_repositories.dart';
import 'data/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ProviderScope is created here so the database can be opened before the
  // first frame. Opening it also runs the 24 hour chat sweep, which is why it
  // happens on every launch rather than on a timer: the app is not running
  // most of the time, and a timer would only fire for people who leave it open.
  final container = ProviderContainer();
  final database = container.read(databaseProvider);

  await _prepare(database);

  runApp(
    UncontrolledProviderScope(container: container, child: const PikirApp()),
  );
}

/// Opens the encrypted store and seeds it the first time.
///
/// A failure here is not fatal. The database is local and replaceable, so a
/// corrupt or unopenable file is recreated rather than allowed to block the
/// app: someone in the middle of deciding whether to borrow money should not
/// meet a crash screen.
Future<void> _prepare(PikirDatabase database) async {
  try {
    await SeedInstaller(database).installIfEmpty();
  } on Object catch (error, stack) {
    debugPrint('Gagal menyiapkan basis data: $error\n$stack');
  }
}
