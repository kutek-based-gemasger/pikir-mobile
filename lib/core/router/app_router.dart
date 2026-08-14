import 'package:flutter/material.dart';

import '../theme/text_styles.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';
import 'routes.dart';
import 'screen_registry.dart';

/// Resolves named routes from the screen registry.
abstract final class AppRouter {
  /// Returns null for an unregistered name so [onUnknownRoute] can handle it.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final entry = kScreenByRoute[settings.name];
    if (entry == null) return null;

    return MaterialPageRoute<void>(
      builder: entry.builder,
      settings: settings,
    );
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => _UnknownRoutePage(name: settings.name),
      settings: settings,
    );
  }
}

/// Shown when a route name has no entry in the registry.
///
/// Phrased for a developer rather than a user: this state should never reach
/// a real device, and dressing it up as a friendly product screen would only
/// make it easier to miss.
class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rute tidak dikenal')),
      body: Padding(
        padding: const EdgeInsets.all(PikirSpacing.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PikirCard(
              outlined: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rute belum terdaftar', style: PikirText.title),
                  const SizedBox(height: 6),
                  Text(
                    name == null
                        ? 'Tidak ada nama rute.'
                        : 'Tidak ada layar untuk "$name" di screen_registry.dart.',
                    style: PikirText.bodySecondary,
                  ),
                ],
              ),
            ),
            const Spacer(),
            PikirButton(
              label: 'Buka peta layar',
              variant: PikirButtonVariant.outlined,
              onPressed: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routes.petaLayar, (_) => false),
            ),
          ],
        ),
      ),
    );
  }
}
