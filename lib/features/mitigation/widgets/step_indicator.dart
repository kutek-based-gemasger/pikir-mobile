import 'package:flutter/material.dart';

import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';

/// "Langkah 2 dari 3" with a thin progress bar.
///
/// [total] is passed in rather than fixed, because the productive branch asks
/// one more question than the others and the indicator should say so. A
/// wizard that promises three steps and delivers two is a small lie, and this
/// app has no credibility to spare.
class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Langkah $step dari $total', style: PikirText.captionSecondary),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: step / total,
            minHeight: 5,
            backgroundColor: PikirColors.outline,
            valueColor: const AlwaysStoppedAnimation(PikirColors.primary),
          ),
        ),
      ],
    );
  }
}

/// A large amount field with a fixed "Rp" prefix.
///
/// The number is the hero even while it is being typed, so it is set at
/// display size with tabular figures.
class RupiahField extends StatelessWidget {
  const RupiahField({
    super.key,
    required this.controller,
    this.autofocus = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: PikirColors.surface,
        borderRadius: BorderRadius.circular(PikirRadius.input),
        border: Border.all(color: PikirColors.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Rp',
            style: PikirText.displayNumber.copyWith(
              fontSize: 26,
              color: PikirColors.textSecondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: onSubmitted,
              style: PikirText.displayNumber.copyWith(fontSize: 32),
              decoration: InputDecoration(
                // Starts empty. A pre-filled amount would be the app
                // suggesting how much to borrow.
                hintText: '0',
                hintStyle: PikirText.displayNumber.copyWith(
                  fontSize: 32,
                  color: PikirColors.outline,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// An unselected shortcut that fills the amount field.
class AmountChip extends StatelessWidget {
  const AmountChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PikirColors.surface,
      borderRadius: BorderRadius.circular(PikirRadius.chip),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PikirRadius.chip),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: PikirSpacing.minTapTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PikirRadius.chip),
            border: Border.all(color: PikirColors.outline),
          ),
          child: Text(label, style: PikirText.label),
        ),
      ),
    );
  }
}
