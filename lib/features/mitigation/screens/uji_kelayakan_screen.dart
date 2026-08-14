import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/rupiah.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../mitigation_state.dart';

/// The feasibility verdict, shown before any financing option.
///
/// CLAUDE.md section 7 puts the test before the options deliberately. Whether
/// this pays for itself is a different question from who will lend the money,
/// and answering them in that order gives the user a reason to walk away that
/// has nothing to do with which lender is cheapest.
class UjiKelayakanScreen extends ConsumerWidget {
  const UjiKelayakanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mitigationControllerProvider);
    final result = state.result;
    final feasibility = result?.feasibility;
    final amount = state.draft.amount ?? 0;
    final profit = state.draft.monthlyNetProfit ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Uji kelayakan')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: feasibility == null
                  ? const PikirCardLoading(height: 300)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        PikirSpacing.screenHorizontal,
                        0,
                        PikirSpacing.screenHorizontal,
                        16,
                      ),
                      children: [
                        PikirCard(
                          hero: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StatusChip(
                                status: feasibility.feasible
                                    ? PikirStatus.safe
                                    : PikirStatus.caution,
                                label: feasibility.feasible
                                    ? 'Layak'
                                    : 'Perlu dipikir lagi',
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Balik modal sekitar '
                                '${feasibility.paybackDays} hari',
                                style: PikirText.headlineLarge,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                feasibility.explanation,
                                style: PikirText.bodySecondary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: PikirSpacing.cardGap),
                        PikirCard(
                          outlined: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cara kami menghitung',
                                style: PikirText.title,
                              ),
                              const SizedBox(height: 12),
                              // The working is shown so the verdict can be
                              // argued with rather than merely believed.
                              _Line(
                                label: 'Modal yang dibutuhkan',
                                value: formatRupiah(amount),
                              ),
                              const Divider(height: 22),
                              _Line(
                                label: 'Untung bersih per bulan',
                                value: formatRupiah(profit),
                              ),
                              const Divider(height: 22),
                              _Line(
                                label: 'Untung bersih per hari',
                                value: formatRupiah(profit ~/ 30),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Perkiraan kasar. Kalau order sepi, baliknya '
                                'lebih lama.',
                                style: PikirText.captionSecondary,
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
              child: PikirButtonStack(
                buttons: [
                  PikirButton(
                    label: 'Lihat pilihan pembiayaan',
                    onPressed: feasibility == null
                        ? null
                        : () => Navigator.of(
                            context,
                          ).pushNamed(Routes.mitigasiHasilProduktif),
                  ),
                  // An exit of equal size and equal weight. Deciding this is
                  // not worth borrowing for is a legitimate outcome, not a
                  // failure state to be nudged away from.
                  PikirButton(
                    label: 'Belum, saya pikir dulu',
                    variant: PikirButtonVariant.outlined,
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(Routes.beranda, (_) => false),
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

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: PikirText.body)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PikirText.number,
          ),
        ),
      ],
    );
  }
}
