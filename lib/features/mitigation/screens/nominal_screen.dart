import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/mitigation.dart';
import '../mitigation_state.dart';
import '../widgets/step_indicator.dart';

/// Step two: how much is actually needed.
class NominalScreen extends ConsumerStatefulWidget {
  const NominalScreen({super.key});

  @override
  ConsumerState<NominalScreen> createState() => _NominalScreenState();
}

class _NominalScreenState extends ConsumerState<NominalScreen> {
  final _input = TextEditingController();

  static const _shortcuts = {
    '500 rb': 500000,
    '1 jt': 1000000,
    '2 jt': 2000000,
    '5 jt': 5000000,
  };

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  int? get _amount {
    final digits = _input.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  Future<void> _next() async {
    final amount = _amount;
    if (amount == null || amount <= 0) return;

    final controller = ref.read(mitigationControllerProvider.notifier);
    controller.setAmount(amount);

    final draft = ref.read(mitigationControllerProvider).draft;

    // Only the productive branch has a third question. The other two go
    // straight to their results, because asking somebody whose child is ill
    // about profit margins would be absurd.
    if (draft.kind == NeedKind.produktif) {
      await Navigator.of(context).pushNamed(Routes.mitigasiUntung);
      return;
    }

    final result = await controller.route();
    if (!mounted || result == null) return;

    await Navigator.of(context).pushNamed(
      result.request.kind == NeedKind.konsumtif
          ? Routes.mitigasiHasilKonsumtif
          : Routes.mitigasiHasilBantuan,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mitigationControllerProvider);
    final ready = (_amount ?? 0) > 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Cari jalan keluar')),
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
                  StepIndicator(step: 2, total: state.draft.totalSteps),
                  const SizedBox(height: 20),
                  Text('Butuh berapa?', style: PikirText.headlineLarge),
                  const SizedBox(height: 20),
                  RupiahField(
                    controller: _input,
                    autofocus: true,
                    onSubmitted: (_) => _next(),
                  ),
                  const SizedBox(height: 16),
                  // Shortcuts, none selected. Tapping one fills the field,
                  // which the user can still change.
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final entry in _shortcuts.entries)
                        AmountChip(
                          label: entry.key,
                          onTap: () {
                            _input.text = entry.value.toString();
                            _input.selection = TextSelection.collapsed(
                              offset: _input.text.length,
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Tulis jumlah yang benar-benar dibutuhkan, bukan yang '
                    'ditawarkan.',
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
              child: PikirButton(
                label: state.isRouting ? 'Menghitung...' : 'Lanjut',
                // Unavailable only while the field is empty. That is a
                // missing input, not a discouraged choice.
                onPressed: ready && !state.isRouting ? _next : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
