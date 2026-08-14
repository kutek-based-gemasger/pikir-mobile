import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../mitigation_state.dart';
import '../widgets/step_indicator.dart';

/// Step three, productive branch only: what the work actually clears.
///
/// The gloss beneath the field matters more than the field. "Untung bersih"
/// is a term people nod at and then answer with their gross takings, which
/// would make the payback estimate flattering and useless.
class UntungScreen extends ConsumerStatefulWidget {
  const UntungScreen({super.key});

  @override
  ConsumerState<UntungScreen> createState() => _UntungScreenState();
}

class _UntungScreenState extends ConsumerState<UntungScreen> {
  final _input = TextEditingController();

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

  int? get _profit {
    final digits = _input.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  Future<void> _next() async {
    final profit = _profit;
    if (profit == null || profit <= 0) return;

    final controller = ref.read(mitigationControllerProvider.notifier);
    controller.setProfit(profit);

    final result = await controller.route();
    if (!mounted || result == null) return;

    // Feasibility first, financing after. CLAUDE.md section 7 puts the test
    // before the options on purpose: whether this pays for itself is a
    // different question from who will lend the money.
    await Navigator.of(context).pushNamed(Routes.mitigasiUjiKelayakan);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mitigationControllerProvider);
    final ready = (_profit ?? 0) > 0;

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
                  StepIndicator(step: 3, total: state.draft.totalSteps),
                  const SizedBox(height: 20),
                  Text(
                    'Kira-kira untung bersih per bulan?',
                    style: PikirText.headline,
                  ),
                  const SizedBox(height: 20),
                  RupiahField(
                    controller: _input,
                    autofocus: true,
                    onSubmitted: (_) => _next(),
                  ),
                  const SizedBox(height: 14),
                  // The one-line plain-language gloss required for any
                  // financial term.
                  PikirCard(
                    outlined: true,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: PikirColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Untung bersih = pemasukan dikurangi bensin, '
                            'makan, dan setoran.',
                            style: PikirText.body,
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
                12,
              ),
              child: PikirButton(
                label: state.isRouting ? 'Menghitung...' : 'Lihat pilihanku',
                onPressed: ready && !state.isRouting ? _next : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
