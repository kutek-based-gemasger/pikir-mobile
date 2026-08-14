import 'package:flutter/material.dart';

import '../theme/text_styles.dart';
import '../theme/tokens.dart';

/// The four destinations in the bottom bar.
///
/// There is no profile tab, because there are no accounts. Settings is
/// reached from the gear icon on Beranda, not from here.
enum PikirTab {
  beranda,
  mitigasi,
  danaDarurat,
  ledger;

  String get label => switch (this) {
    PikirTab.beranda => 'Beranda',
    PikirTab.mitigasi => 'Mitigasi',
    PikirTab.danaDarurat => 'Dana Darurat',
    PikirTab.ledger => 'Ledger',
  };

  IconData get activeIcon => switch (this) {
    PikirTab.beranda => Icons.home_rounded,
    PikirTab.mitigasi => Icons.alt_route_rounded,
    PikirTab.danaDarurat => Icons.savings_rounded,
    PikirTab.ledger => Icons.receipt_long_rounded,
  };

  IconData get inactiveIcon => switch (this) {
    PikirTab.beranda => Icons.home_outlined,
    PikirTab.mitigasi => Icons.alt_route_outlined,
    PikirTab.danaDarurat => Icons.savings_outlined,
    PikirTab.ledger => Icons.receipt_long_outlined,
  };
}

/// The bottom navigation bar, identical on every screen that shows one.
///
/// Labels are always visible. A low-digital-literacy user should never have
/// to learn what an unlabelled glyph means.
class PikirBottomNav extends StatelessWidget {
  const PikirBottomNav({
    super.key,
    required this.current,
    required this.onSelect,
    required this.onTanyaPikir,
  });

  /// The active destination, or null on a screen that is reachable from the
  /// bar but is not itself one of the four.
  final PikirTab? current;

  final ValueChanged<PikirTab> onSelect;

  /// The centre action. Chat is a FAB rather than a tab because it is an
  /// action the user takes, not a place they park.
  final VoidCallback onTanyaPikir;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PikirColors.surface,
        border: Border(top: BorderSide(color: PikirColors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: Row(
            children: [
              _NavItem(
                tab: PikirTab.beranda,
                active: current == PikirTab.beranda,
                onTap: () => onSelect(PikirTab.beranda),
              ),
              _NavItem(
                tab: PikirTab.mitigasi,
                active: current == PikirTab.mitigasi,
                onTap: () => onSelect(PikirTab.mitigasi),
              ),
              _TanyaPikirButton(onTap: onTanyaPikir),
              _NavItem(
                tab: PikirTab.danaDarurat,
                active: current == PikirTab.danaDarurat,
                onTap: () => onSelect(PikirTab.danaDarurat),
              ),
              _NavItem(
                tab: PikirTab.ledger,
                active: current == PikirTab.ledger,
                onTap: () => onSelect(PikirTab.ledger),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final PikirTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? PikirColors.primary : PikirColors.textSecondary;

    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: tab.label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                active ? tab.activeIcon : tab.inactiveIcon,
                size: 26,
                color: color,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: PikirText.caption.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TanyaPikirButton extends StatelessWidget {
  const _TanyaPikirButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: 'Tanya PIKIR',
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: PikirSpacing.minTapTarget,
                height: PikirSpacing.minTapTarget,
                decoration: const BoxDecoration(
                  color: PikirColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: PikirShadow.soft,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: PikirColors.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tanya PIKIR',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: PikirText.caption.copyWith(color: PikirColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
