import 'package:flutter/material.dart';

import '../router/routes.dart';
import '../theme/text_styles.dart';
import '../theme/tokens.dart';
import 'pikir_bottom_nav.dart';
import 'pikir_button.dart';

/// A screen that carries the bottom navigation.
///
/// The tab-to-route mapping lives here rather than on each screen, so the four
/// destinations cannot drift apart and a new tab cannot be wired up wrongly on
/// one screen only.
class PikirScaffold extends StatelessWidget {
  const PikirScaffold({
    super.key,
    required this.currentTab,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  });

  final PikirTab currentTab;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  static String routeOf(PikirTab tab) => switch (tab) {
    PikirTab.beranda => Routes.beranda,
    PikirTab.mitigasi => Routes.mitigasiKebutuhan,
    PikirTab.danaDarurat => Routes.danaDarurat,
    PikirTab.ledger => Routes.ledger,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: PikirBottomNav(
        current: currentTab,
        onSelect: (tab) {
          if (tab == currentTab) return;
          // Replaced rather than pushed: tabs are places, not steps, and a
          // back stack that remembers every tab visit would make the system
          // back button behave unpredictably.
          Navigator.of(context).pushReplacementNamed(routeOf(tab));
        },
        // Chat is pushed, because it is an action the user takes and then
        // comes back from.
        onTanyaPikir: () => Navigator.of(context).pushNamed(Routes.chat),
      ),
    );
  }
}

/// A quiet placeholder while a card's data loads.
///
/// Sized so the surrounding layout does not jump when the data arrives.
class PikirCardLoading extends StatelessWidget {
  const PikirCardLoading({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: PikirColors.primary,
          ),
        ),
      ),
    );
  }
}

/// What a card shows when its data could not be read.
///
/// Deliberately plain and blameless. Someone already anxious about money
/// should not also be handed a technical failure to interpret.
class PikirLoadFailure extends StatelessWidget {
  const PikirLoadFailure({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Datanya belum bisa ditampilkan', style: PikirText.title),
        const SizedBox(height: 6),
        Text('Coba buka lagi sebentar.', style: PikirText.bodySecondary),
        if (onRetry != null) ...[
          const SizedBox(height: PikirSpacing.cardGap),
          PikirButton(
            label: 'Coba lagi',
            variant: PikirButtonVariant.outlined,
            onPressed: onRetry,
          ),
        ],
      ],
    );
  }
}
