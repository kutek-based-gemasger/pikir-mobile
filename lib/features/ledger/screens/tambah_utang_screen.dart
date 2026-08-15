import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/debt_entry.dart';
import '../../../data/providers.dart';
import '../../../data/queries.dart';
import '../../mitigation/widgets/step_indicator.dart';

/// Records a debt the user already has.
///
/// Every field starts empty and the category starts unchosen. A form that
/// arrives with a category already picked is the app deciding what kind of
/// borrower somebody is before they have said anything.
///
/// The tone matters as much as the fields. Someone typing a debt into this
/// screen is doing the harder, more honest thing, and the copy should not read
/// like an audit.
class TambahUtangScreen extends ConsumerStatefulWidget {
  const TambahUtangScreen({super.key});

  @override
  ConsumerState<TambahUtangScreen> createState() => _TambahUtangScreenState();
}

class _TambahUtangScreenState extends ConsumerState<TambahUtangScreen> {
  final _principal = TextEditingController();
  final _instalment = TextEditingController();
  final _purpose = TextEditingController();

  /// Null until the user picks. Category may be left blank.
  DebtCategory? _category;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_principal, _instalment, _purpose]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _principal.dispose();
    _instalment.dispose();
    _purpose.dispose();
    super.dispose();
  }

  int? _digits(TextEditingController controller) {
    final digits = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  bool get _ready =>
      (_digits(_principal) ?? 0) > 0 && _purpose.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_ready || _saving) return;
    setState(() => _saving = true);

    final now = DateTime.now();
    await ref.read(ledgerRepositoryProvider).addDebt(
      DebtEntry(
        id: 'debt-${now.millisecondsSinceEpoch}',
        purpose: _purpose.text.trim(),
        principal: _digits(_principal)!,
        // Zero when left blank, which the ledger card reports honestly rather
        // than printing "Rp0 per bulan". See the note beside the field.
        monthlyInstalment: _digits(_instalment) ?? 0,
        source: DebtSource.manual,
        recordedAt: now,
        category: _category,
      ),
    );

    ref.invalidate(debtsProvider);
    ref.invalidate(debtSummaryProvider);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah catatan utang')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  PikirSpacing.screenHorizontal,
                  0,
                  PikirSpacing.screenHorizontal,
                  16,
                ),
                children: [
                  Text('Nominal awal', style: PikirText.label),
                  const SizedBox(height: 8),
                  RupiahField(controller: _principal, autofocus: true),
                  const SizedBox(height: PikirSpacing.cardGap),

                  Text('Cicilan per bulan', style: PikirText.label),
                  const SizedBox(height: 8),
                  RupiahField(controller: _instalment),
                  const SizedBox(height: 8),
                  // Optional, and the reason is stated rather than assumed.
                  // The debt ratio on Beranda is built from instalments, so a
                  // debt recorded without one raises the total but not the
                  // ratio. Saying so is better than silently under-reporting
                  // the number the whole app is organised around.
                  Text(
                    'Boleh dikosongkan. Kalau diisi, utang ini ikut dihitung '
                    'ke beban utang bulananmu di Beranda.',
                    style: PikirText.captionSecondary,
                  ),
                  const SizedBox(height: PikirSpacing.cardGap),

                  Text('Buat apa?', style: PikirText.label),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _purpose,
                    textInputAction: TextInputAction.done,
                    style: PikirText.body,
                    decoration: const InputDecoration(
                      hintText: 'contoh: bayar kontrakan',
                    ),
                  ),
                  const SizedBox(height: PikirSpacing.cardGap),

                  Text('Kategori, boleh dikosongkan', style: PikirText.label),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in DebtCategory.values)
                        _CategoryChoice(
                          label: category.label,
                          selected: _category == category,
                          // Tapping the chosen one clears it, so a category
                          // picked by accident can be taken back.
                          onTap: () => setState(
                            () => _category =
                                _category == category ? null : category,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _category == null
                        ? 'Belum dipilih.'
                        : 'Kategori membantu memisahkan utang yang '
                              'menghasilkan dan yang tidak.',
                    style: PikirText.captionSecondary,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PikirSpacing.screenHorizontal,
                8,
                PikirSpacing.screenHorizontal,
                12,
              ),
              // Equal width and height. SCREENS.md draws "Batal" as a bare
              // text link, which CLAUDE.md section 6 rule 3 forbids: the
              // option that exits is never made smaller than the one that
              // proceeds.
              child: PikirButtonRow(
                buttons: [
                  PikirButton(
                    label: 'Batal',
                    variant: PikirButtonVariant.outlined,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  PikirButton(
                    label: _saving ? 'Menyimpan...' : 'Simpan',
                    onPressed: _ready && !_saving ? _save : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
              color: selected ? PikirColors.primary : PikirColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
