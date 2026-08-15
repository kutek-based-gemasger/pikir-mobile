import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the database key.
///
/// The key lives in the Android Keystore rather than in the app's own files,
/// so it is not sitting next to the database it unlocks. It is generated once
/// on first run from a cryptographic random source and never leaves the
/// device: there is no account to sync it to and no server to escrow it with.
///
/// Losing the key means losing the data, which is the correct trade here. The
/// alternative is a key derived from something guessable, which would make the
/// encryption decorative.
class SecureKeyStore {
  const SecureKeyStore();

  static const _keyName = 'pikir.db.key.v1';

  // Defaults are already Keystore-backed on Android: AES-GCM for the value,
  // RSA-OAEP to wrap the key. Nothing to tighten here.
  static const _storage = FlutterSecureStorage();

  /// Returns the existing key, creating one on first run.
  Future<String> databaseKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null && existing.isNotEmpty) return existing;

    final generated = _generateKey();
    await _storage.write(key: _keyName, value: generated);
    return generated;
  }

  /// Drops the key, which makes the database permanently unreadable.
  ///
  /// Used by "Hapus semua data di HP ini": deleting the key is what makes the
  /// deletion final, since a file on disk can survive an uninstall on some
  /// devices but ciphertext without its key cannot be read either way.
  Future<void> destroyKey() => _storage.delete(key: _keyName);

  /// 256 bits from the platform's secure random source, base64 encoded.
  String _generateKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }
}
