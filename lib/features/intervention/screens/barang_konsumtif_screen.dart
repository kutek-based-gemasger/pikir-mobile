import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../intervention_state.dart';
import '../widgets/intervention_overlay.dart';

/// Asks what the user actually wants to buy.
///
/// The user types it themselves. Naming the thing out loud is most of the
/// work this screen does, and putting a guess in the box for them would take
/// that away as well as pre-filling an answer the app has no business
/// assuming.
class BarangKonsumtifScreen extends ConsumerStatefulWidget {
  const BarangKonsumtifScreen({super.key});

  @override
  ConsumerState<BarangKonsumtifScreen> createState() =>
      _BarangKonsumtifScreenState();
}

class _BarangKonsumtifScreenState
    extends ConsumerState<BarangKonsumtifScreen> {
  final _input = TextEditingController();

  static const _quickChips = [
    'HP atau gadget',
    'Baju atau sepatu',
    'Makan atau nongkrong',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    // Rebuilds so the continue button reflects whether anything was typed.
    _input.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _continue() {
    final name = _input.text.trim();
    if (name.isEmpty) return;

    ref.read(interventionControllerProvider.notifier)
      ..startLoanApp()
      ..setItemName(name);

    Navigator.of(context).pushNamed(Routes.intervensiBlanket);
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _input.text.trim().isNotEmpty;

    return InterventionOverlay(
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: PikirSpacing.screenHorizontal,
        ),
        children: [
          const SizedBox(height: 12),
          Text(
            'Barang apa yang mau dibeli?',
            style: PikirText.headline.copyWith(color: PikirColors.onPrimary),
          ),
          const SizedBox(height: 10),
          Text(
            'Tulis apa adanya. Tidak ada jawaban yang salah.',
            style: PikirText.body.copyWith(
              color: PikirColors.onPrimary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _input,
            autofocus: true,
            textInputAction: TextInputAction.done,
            style: PikirText.body,
            onSubmitted: (_) => _continue(),
            decoration: InputDecoration(
              // Placeholder text only. The field starts empty.
              hintText: 'contoh: HP second, sepatu, kuota',
              filled: true,
              fillColor: PikirColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Shortcuts, not selections. Tapping one fills the field, which the
          // user can still edit or replace.
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final chip in _quickChips)
                _QuickChip(
                  label: chip,
                  onTap: () {
                    _input.text = chip;
                    _input.selection = TextSelection.collapsed(
                      offset: chip.length,
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 32),
          PikirButton(
            label: 'Lanjut',
            variant: PikirButtonVariant.overlayFilled,
            // Unavailable only until the user has written something. This is
            // a missing input, not a discouraged choice.
            onPressed: hasText ? _continue : null,
          ),
          const SizedBox(height: 12),
          PikirButton(
            label: 'Kembali',
            variant: PikirButtonVariant.overlayOutlined,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(PikirRadius.chip),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PikirRadius.chip),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: PikirSpacing.minTapTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PikirRadius.chip),
            border: Border.all(color: PikirColors.onPrimary),
          ),
          child: Text(
            label,
            style: PikirText.label.copyWith(color: PikirColors.onPrimary),
          ),
        ),
      ),
    );
  }
}
