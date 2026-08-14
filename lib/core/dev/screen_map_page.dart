import 'package:flutter/material.dart';

import '../router/screen_registry.dart';
import '../theme/text_styles.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// A development index of every route in the app.
///
/// Phase 1 ships screens as labelled stubs, so this exists to make the claim
/// "every screen is reachable" something you can actually walk rather than
/// take on trust. It reads from the same registry the router does, so it can
/// never list a route that does not resolve.
///
/// This is not a product screen. It is not in SCREENS.md and it must not
/// appear in the submission recording. The demo flows the judges see belong
/// in Mode Demo instead, per CLAUDE.md section 8.
class ScreenMapPage extends StatelessWidget {
  const ScreenMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = <ScreenGroup, List<ScreenEntry>>{};
    for (final entry in kScreenRegistry) {
      if (entry.group == ScreenGroup.perkakas) continue;
      groups.putIfAbsent(entry.group, () => []).add(entry);
    }

    final counted = groups.values.fold<int>(0, (sum, l) => sum + l.length);

    return Scaffold(
      appBar: AppBar(title: const Text('Peta Layar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          PikirSpacing.screenHorizontal,
          0,
          PikirSpacing.screenHorizontal,
          32,
        ),
        children: [
          PikirCard(
            outlined: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alat pengembangan', style: PikirText.title),
                const SizedBox(height: 6),
                Text(
                  '$counted layar terdaftar. Halaman ini bukan bagian dari '
                  'produk dan tidak ikut direkam untuk pengumpulan.',
                  style: PikirText.bodySecondary,
                ),
              ],
            ),
          ),
          for (final group in groups.keys) ...[
            const SizedBox(height: 24),
            Text(group.label, style: PikirText.title),
            const SizedBox(height: 10),
            PikirCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final (i, entry) in groups[group]!.indexed) ...[
                    if (i > 0)
                      const Divider(indent: PikirSpacing.cardPadding),
                    _ScreenRow(entry: entry),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScreenRow extends StatelessWidget {
  const _ScreenRow({required this.entry});

  final ScreenEntry entry;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(entry.route),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: PikirSpacing.minTapTarget,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: PikirSpacing.cardPadding,
          vertical: 12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title, style: PikirText.body),
                  const SizedBox(height: 2),
                  Text(entry.route, style: PikirText.captionSecondary),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: PikirColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
