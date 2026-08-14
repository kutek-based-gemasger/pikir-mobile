import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/rupiah.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/debt_entry.dart';
import '../../../data/queries.dart';
import '../intervention_state.dart';

/// The soft handover: record this, or do not.
///
/// Shown when the analysis decides there is nothing worth reflecting on and
/// the decision should simply be written down. Both buttons are the same
/// width, the same height, and the same weight, and neither is worded to make
/// the user feel judged for their answer. "Jangan catat" is a real option,
/// not a formality.
class CatatLedgerScreen extends ConsumerStatefulWidget {
  const CatatLedgerScreen({super.key});

  @override
  ConsumerState<CatatLedgerScreen> createState() => _CatatLedgerScreenState();
}

class _CatatLedgerScreenState extends ConsumerState<CatatLedgerScreen> {
  /// Null until the user picks one. Category may be left blank.
  DebtCategory? _category;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(interventionControllerProvider);
    final amount = state.analysis?.instalmentAmount ?? state.amount ?? 0;
    final purpose = state.itemName?.isNotEmpty == true
        ? state.itemName!
        : 'Cicilan baru';

    Future<void> save() async {
      await ref
          .read(interventionControllerProvider.notifier)
          .recordContinued(category: _category);
      ref.invalidate(debtsProvider);
      ref.invalidate(debtSummaryProvider);
      ref.invalidate(decisionsProvider);
      if (!context.mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Routes.ledger, (_) => false);
    }

    void skip() {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Routes.beranda, (_) => false);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  PikirSpacing.screenHorizontal,
                  24,
                  PikirSpacing.screenHorizontal,
                  16,
                ),
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: PikirColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu_book_outlined,
                        size: 34,
                        color: PikirColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Kami catat dulu ya',
                    textAlign: TextAlign.center,
                    style: PikirText.headline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Supaya total utangmu kelihatan nanti. Kami tidak '
                    'menghakimi.',
                    textAlign: TextAlign.center,
                    style: PikirText.bodySecondary,
                  ),
                  const SizedBox(height: 24),
                  PikirCard(
                    child: Column(
                      children: [
                        _Field(label: 'Nominal', value: formatRupiah(amount)),
                        const Divider(height: 24),
                        _Field(label: 'Buat apa', value: purpose),
                        const Divider(height: 24),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Kategori', style: PikirText.label),
                        ),
                        const SizedBox(height: 10),
                        // Nothing is pre-selected, and the row says so
                        // plainly rather than quietly defaulting to one.
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final category in DebtCategory.values)
                              _CategoryChoice(
                                label: category.label,
                                selected: _category == category,
                                onTap: () => setState(
                                  () => _category =
                                      _category == category ? null : category,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _category == null
                                ? 'Belum dipilih. Boleh dikosongkan.'
                                : 'Kategori membantu memisahkan utang yang '
                                      'menghasilkan dan yang tidak.',
                            style: PikirText.captionSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PikirSpacing.screenHorizontal,
                8,
                PikirSpacing.screenHorizontal,
                16,
              ),
              child: PikirButtonRow(
                buttons: [
                  PikirButton(
                    label: 'Jangan catat',
                    variant: PikirButtonVariant.outlined,
                    onPressed: skip,
                  ),
                  PikirButton(label: 'Catat', onPressed: save),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: PikirText.label)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PikirText.number.copyWith(fontSize: 17),
          ),
        ),
      ],
    );
  }
}

class _CategoryChoice extends StatelessWidget {
  const _CategoryChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? PikirColors.primaryContainer : PikirColors.surface,
      borderRadius: BorderRadius.circular(PikirRadius.chip),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PikirRadius.chip),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: PikirSpacing.minTapTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PikirRadius.chip),
            border: Border.all(
              color: selected ? PikirColors.primary : PikirColors.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: PikirText.label.copyWith(
              color: selected
                  ? PikirColors.primary
                  : PikirColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
