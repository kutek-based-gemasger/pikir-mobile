import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the bundled typeface.
///
/// Plus Jakarta Sans is downloaded and committed rather than fetched at
/// runtime, which means a bad download is a silent, permanent defect: the app
/// still builds and simply renders in the platform's fallback font. This test
/// makes the engine actually parse the file, so a truncated or wrong-content
/// asset fails here instead of on a judge's screen.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the bundled Plus Jakarta Sans asset is a font the engine can load', () async {
    final data = await rootBundle.load('assets/fonts/PlusJakartaSans.ttf');

    // TrueType outlines begin with the 0x00010000 version tag.
    expect(
      data.getUint32(0),
      0x00010000,
      reason: 'Not a TrueType file. A failed download often lands here as an '
          'HTML error page of roughly plausible size.',
    );

    final loader = FontLoader('PlusJakartaSans')
      ..addFont(Future.value(data));

    // Throws if the engine cannot decode the bytes.
    await loader.load();
  });
}
