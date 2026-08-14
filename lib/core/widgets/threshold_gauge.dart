import 'package:flutter/material.dart';

import '../format/rupiah.dart';
import '../theme/text_styles.dart';
import '../theme/tokens.dart';
import 'status_chip.dart';

/// The debt-ratio gauge: a horizontal bar with a marked threshold line, the
/// percentage as the largest element, and a status pill.
///
/// The number is the hero. The bar is supporting evidence, and the status is
/// spelled out in words beside it so the bar's colour is never the only thing
/// telling the user where they stand.
class ThresholdGauge extends StatelessWidget {
  const ThresholdGauge({
    super.key,
    required this.value,
    this.threshold = 0.30,
    this.thresholdLabel = 'Batas aman 30%',
    this.caption,
    this.status,
    this.statusLabel,
    this.footnote,
  }) : assert(value >= 0, 'A debt ratio is never negative.');

  /// The current ratio, 0 to 1. Values above 1 are clamped for drawing but
  /// still reported truthfully in the number.
  final double value;

  /// The caution threshold, 0 to 1. Thirty percent is a prudence convention,
  /// not an official rule, and screens using this should say so.
  final double threshold;

  final String thresholdLabel;

  /// The line beneath the big number, such as "dari penghasilanmu".
  final String? caption;

  /// Overrides the derived status.
  ///
  /// The reflection flow passes [PikirStatus.caution] even when the ratio is
  /// over the threshold, because that flow uses no red at all: the user is
  /// weighing a decision, not being told off.
  final PikirStatus? status;

  final String? statusLabel;

  /// A caption below the gauge, such as "Rp720.000 dari Rp4.000.000".
  final String? footnote;

  PikirStatus get _status =>
      status ??
      switch (value) {
        _ when value > threshold => PikirStatus.danger,
        _ when value > threshold * 0.8 => PikirStatus.caution,
        _ => PikirStatus.safe,
      };

  String get _statusLabel =>
      statusLabel ??
      switch (_status) {
        PikirStatus.safe => 'Aman',
        PikirStatus.caution => 'Perlu hati-hati',
        PikirStatus.danger => 'Di atas batas aman',
        PikirStatus.neutral => 'Belum dihitung',
      };

  Color get _valueColor => switch (_status) {
    PikirStatus.safe => PikirColors.safe,
    PikirStatus.caution => PikirColors.caution,
    PikirStatus.danger => PikirColors.danger,
    PikirStatus.neutral => PikirColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final drawnValue = value.clamp(0.0, 1.0);
    final drawnThreshold = threshold.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatPercent(value),
                    style: PikirText.displayNumber.copyWith(
                      color: _valueColor,
                    ),
                  ),
                  if (caption != null)
                    Text(caption!, style: PikirText.captionSecondary),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Flexible, so the chip receives a bounded width and the label
            // inside it can shorten. A non-flex child of a Row is measured
            // against infinity, which would leave a long status such as
            // "Di atas batas aman" pushing the row past the card edge.
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: StatusChip(status: _status, label: _statusLabel),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _GaugeBar(
          value: drawnValue,
          threshold: drawnThreshold,
          fillColor: _valueColor,
        ),
        const SizedBox(height: 6),
        // Aligning the label to the threshold's own position keeps the mark
        // and its meaning together. Align clamps at both edges, so an extreme
        // threshold cannot push the text out of the card.
        Align(
          alignment: Alignment(-1 + 2 * drawnThreshold, 0),
          child: Text(thresholdLabel, style: PikirText.captionSecondary),
        ),
        if (footnote != null) ...[
          const SizedBox(height: 10),
          Text(footnote!, style: PikirText.captionSecondary),
        ],
      ],
    );
  }
}

class _GaugeBar extends StatelessWidget {
  const _GaugeBar({
    required this.value,
    required this.threshold,
    required this.fillColor,
  });

  final double value;
  final double threshold;
  final Color fillColor;

  static const _height = 14.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const markerWidth = 3.0;

        return SizedBox(
          height: _height,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: PikirColors.outline,
                  borderRadius: BorderRadius.circular(_height / 2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(_height / 2),
                  ),
                ),
              ),
              Positioned(
                left: (width * threshold - markerWidth / 2)
                    .clamp(0.0, width - markerWidth),
                top: -2,
                bottom: -2,
                child: Container(
                  width: markerWidth,
                  decoration: BoxDecoration(
                    color: PikirColors.textPrimary,
                    borderRadius: BorderRadius.circular(markerWidth / 2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
