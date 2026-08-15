import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/debt_entry.dart';
import '../../../data/providers.dart';
import '../../../data/queries.dart';

/// What can be done to one entry in the ledger: finish it, or delete it.
///
/// The two are genuinely different and the sheet says so rather than leaving
/// the user to guess. Marking a debt paid off keeps the record and stops it
/// counting against the month; deleting throws the record away, which is only
/// right for something entered by mistake.
///
/// Neither is pre-selected and neither is dressed up as the expected answer,
/// so the cards are the same size and weight. The delete path adds a
/// hold-to-confirm afterwards, because it cannot be undone — the friction is
/// in the gesture, never in hiding or shrinking the option.
Future<void> showAturUtangSheet(BuildContext context, DebtEntry debt) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: PikirColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(PikirRadius.sheet),
      ),
    ),
    builder: (_) => _AturUtangSheet(debt: debt),
  );
}

class _AturUtangSheet extends ConsumerStatefulWidget {
  const _AturUtangSheet({required this.debt});

  final DebtEntry debt;

  @override
  ConsumerState<_AturUtangSheet> createState() => _AturUtangSheetState();
}

class _AturUtangSheetState extends ConsumerState<_AturUtangSheet> {
  /// True once the user has chosen deleting and is being asked to hold.
  bool _confirmingDelete = false;

  void _refresh() {
    ref.invalidate(debtsProvider);
    ref.invalidate(debtSummaryProvider);
  }

  Future<void> _toggleSettled() async {
    final settled = !widget.debt.isSettled;
    await ref
        .read(ledgerRepositoryProvider)
        .setDebtSettled(widget.debt.id, settled: settled);
    _refresh();

    if (!mounted) return;
    Navigator.of(context).pop();
    // Stated plainly, with the consequence for the monthly figure. No
    // celebration: paying off a debt is the user's own doing, and a burst of
    // confetti from the app would take credit for it.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          settled
              ? '"${widget.debt.purpose}" ditandai lunas dan tidak lagi '
                    'dihitung di beban bulananmu.'
              : '"${widget.debt.purpose}" dihitung lagi sebagai utang '
                    'berjalan.',
        ),
        backgroundColor: PikirColors.textPrimary,
      ),
    );
  }

  Future<void> _delete() async {
    await ref.read(ledgerRepositoryProvider).removeDebt(widget.debt.id);
    _refresh();

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Catatan "${widget.debt.purpose}" dihapus.'),
        backgroundColor: PikirColors.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PikirSpacing.screenHorizontal,
          12,
          PikirSpacing.screenHorizontal,
          20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: PikirColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(widget.debt.purpose, style: PikirText.titleLarge),
            const SizedBox(height: 4),
            Text(
              widget.debt.isSettled ? 'Sudah lunas' : 'Masih berjalan',
              style: PikirText.captionSecondary,
            ),
            const SizedBox(height: PikirSpacing.cardGap),
            if (_confirmingDelete)
              _DeleteConfirmation(
                onConfirmed: _delete,
                onCancel: () => setState(() => _confirmingDelete = false),
              )
            else
              _Choices(
                debt: widget.debt,
                onToggleSettled: _toggleSettled,
                onDeleteChosen: () => setState(() => _confirmingDelete = true),
              ),
          ],
        ),
      ),
    );
  }
}

class _Choices extends StatelessWidget {
  const _Choices({
    required this.debt,
    required this.onToggleSettled,
    required this.onDeleteChosen,
  });

  final DebtEntry debt;
  final VoidCallback onToggleSettled;
  final VoidCallback onDeleteChosen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OptionCard(
          icon: debt.isSettled
              ? Icons.undo_rounded
              : Icons.check_circle_outline_rounded,
          label: debt.isSettled ? 'Batalkan tanda lunas' : 'Tandai lunas',
          example: debt.isSettled
              ? 'Utang ini dihitung lagi di beban bulananmu.'
              : 'Catatannya tetap tersimpan, tapi berhenti dihitung di beban '
                    'bulananmu.',
          onTap: onToggleSettled,
        ),
        const SizedBox(height: 12),
        OptionCard(
          icon: Icons.delete_outline_rounded,
          label: 'Hapus catatan',
          // Says what is lost, not "are you sure". The user is told the
          // consequence and then trusted with it.
          example: 'Catatannya hilang dan tidak bisa dikembalikan. Dipakai '
              'kalau kamu salah catat.',
          onTap: onDeleteChosen,
        ),
      ],
    );
  }
}

class _DeleteConfirmation extends StatelessWidget {
  const _DeleteConfirmation({
    required this.onConfirmed,
    required this.onCancel,
  });

  final Future<void> Function() onConfirmed;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PikirCard(
          color: PikirColors.dangerContainer,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: PikirColors.danger,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Catatan ini akan hilang dari HP-mu dan tidak bisa '
                  'dikembalikan.',
                  style: PikirText.body,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PikirSpacing.cardGap),
        // Neutral, the same variant the interception uses for "Saya tetap
        // lanjut". Deleting is the user's call and the button does not argue
        // with them; the warning above already says what is lost.
        HoldToConfirmButton(
          label: 'Tahan untuk hapus',
          icon: Icons.delete_outline_rounded,
          onConfirmed: onConfirmed,
        ),
        const SizedBox(height: 12),
        // Same size and same weight as holding to delete. Backing out is a
        // legitimate answer and is never made the smaller button.
        PikirButton(
          label: 'Batal',
          variant: PikirButtonVariant.outlined,
          onPressed: onCancel,
        ),
      ],
    );
  }
}
