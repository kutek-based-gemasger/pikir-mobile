import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/scanner_channel.dart';
import '../../core/platform/screen_channel.dart';

/// The permissions PIKIR needs, and what stops working without each.
///
/// Named rather than described in prose so the status page and the launch
/// check read from the same list: a permission added later cannot be shown in
/// one place and forgotten in the other.
enum PikirPermission {
  screenAccess(
    title: 'Deteksi layar',
    what: 'Mengenali saat kamu membuka aplikasi pinjaman atau halaman '
        'checkout paylater.',
    limit: 'Yang dibaca hanya jenis halamannya, bukan isi pesan atau '
        'kontakmu. Di luar aplikasi yang terdaftar, PIKIR tidak membaca '
        'layarmu sama sekali.',
    missing: 'Tanpa ini, PIKIR tidak akan muncul saat kamu hendak berutang.',
  ),
  overlay(
    title: 'Tampil di atas aplikasi lain',
    what: 'Menampilkan layar PIKIR di atas aplikasi yang sedang kamu buka.',
    limit: 'Hanya dipakai pada dua momen di atas, bukan sepanjang waktu.',
    missing:
        'Tanpa ini, PIKIR mengenali momennya tapi layarnya tidak pernah '
        'muncul.',
  ),
  notificationAccess(
    title: 'Akses notifikasi',
    what: 'Memeriksa notifikasi yang masuk untuk menahan tawaran pinjaman '
        'berisiko.',
    limit: 'Diperiksa di dalam HP-mu tanpa internet. Isi chat dan SMS lama '
        'tidak pernah dibaca.',
    missing: 'Tanpa ini, pemindai tidak akan menahan notifikasi apa pun.',
  ),
  postNotification(
    title: 'Mengirim notifikasi',
    what: 'Menampilkan peringatan PIKIR di panel notifikasi, sebagai '
        'pengganti pesan yang ditahan.',
    limit: 'Yang dikirim hanya peringatan dari PIKIR sendiri, dan selalu ada '
        'tombol untuk melihat pesan aslinya.',
    missing:
        'Tanpa ini, pesan berisiko tetap ditahan tapi kamu tidak diberi tahu '
        'sama sekali.',
    usesSystemDialog: true,
  );

  const PikirPermission({
    required this.title,
    required this.what,
    required this.limit,
    required this.missing,
    this.usesSystemDialog = false,
  });

  /// What the permission lets PIKIR do.
  final String what;

  /// Where it stops. Stated beside every request, because a permission screen
  /// that only says what it wants is asking the user to trust it blindly.
  final String limit;

  /// What breaks while it is off, in plain terms.
  final String missing;

  final String title;

  /// Whether Android will ask for this one itself.
  ///
  /// True for exactly one of them. The other three are what Android calls
  /// special access: there is no dialog to show, so the only route is the
  /// settings screen the OS opens for us.
  final bool usesSystemDialog;
}

/// Which permissions apply on this device, and which are granted.
///
/// Only the permissions the user can actually act on are listed. Below Android
/// 13 the OS grants [PikirPermission.postNotification] at install time, so
/// listing it would mean showing a row nobody can change and counting it
/// towards a total that then reads wrong.
class PermissionStatus {
  const PermissionStatus(this.granted);

  final Map<PikirPermission, bool> granted;

  /// In enum order, which is the order the cards appear in.
  Iterable<PikirPermission> get applicable => granted.keys;

  int get total => granted.length;

  bool isGranted(PikirPermission permission) => granted[permission] ?? false;

  bool get allGranted => granted.values.every((granted) => granted);

  Iterable<PikirPermission> get missing => granted.entries
      .where((entry) => !entry.value)
      .map((entry) => entry.key);
}

/// Reads the permissions from the platform.
///
/// Returns everything as denied where the channels are absent, which is every
/// widget test and every non-Android host. That is the honest answer: nothing
/// is watching.
final permissionStatusProvider = FutureProvider<PermissionStatus>((ref) async {
  final screen = await ScreenChannel.hasScreenAccess();
  final overlay = await ScreenChannel.hasOverlayPermission();
  final notifications = await ScannerChannel.hasNotificationAccess();
  final postApplicable = await ScannerChannel.postNotificationApplicable();

  return PermissionStatus({
    PikirPermission.screenAccess: screen,
    PikirPermission.overlay: overlay,
    PikirPermission.notificationAccess: notifications,
    if (postApplicable)
      PikirPermission.postNotification:
          await ScannerChannel.hasPostNotification(),
  });
});

/// Whether screen detection is switched on inside PIKIR.
///
/// Kept beside the permission state because the two are read together on the
/// same rows: an interception needs the Android permission **and** this switch.
final screenWatchEnabledProvider = FutureProvider<bool>(
  (ref) => ScreenChannel.screenWatchIsEnabled(),
);

/// The apps the watcher is allowed to see, straight from the Kotlin whitelist.
///
/// Read from the platform rather than duplicated in Dart, so the number shown
/// in Settings cannot drift away from the list that actually governs
/// detection.
final watchedAppsProvider = FutureProvider<List<String>>(
  (ref) => ScreenChannel.watchedApps(),
);

/// Asks for [permission], however this particular one can be asked for.
///
/// Three of them cannot be granted by the app at all: the best it can do is
/// open the settings screen and explain first. The fourth has a real dialog,
/// and falls back to the settings screen once that dialog has been refused for
/// good and stops appearing.
Future<void> requestPermission(PikirPermission permission) async {
  switch (permission) {
    case PikirPermission.screenAccess:
      await ScreenChannel.openScreenAccessSettings();
    case PikirPermission.overlay:
      await ScreenChannel.openOverlaySettings();
    case PikirPermission.notificationAccess:
      await ScannerChannel.openNotificationAccessSettings();
    case PikirPermission.postNotification:
      final outcome = await ScannerChannel.requestPostNotification();
      if (outcome.permanentlyDenied) {
        await ScannerChannel.openAppNotificationSettings();
      }
  }
}

/// Route argument that marks the permission page as the launch prompt.
///
/// The same route serves both entry points, so the page cannot be improved in
/// Settings and left stale at launch. Only the framing differs.
const kIzinLaunchPrompt = 'launch-prompt';
