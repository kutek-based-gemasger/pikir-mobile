import 'package:flutter_test/flutter_test.dart';
import 'package:pikir/core/format/rupiah.dart';

/// CLAUDE.md section 6 rule 6: costs are shown as `Rp1.800.000`, no cents.
/// The format is a product rule, so it gets a test rather than a convention.
void main() {
  test('formats with dot separators and no cents', () {
    expect(formatRupiah(1800000), 'Rp1.800.000');
    expect(formatRupiah(3150000), 'Rp3.150.000');
    expect(formatRupiah(450000), 'Rp450.000');
  });

  test('handles boundaries around the separator', () {
    expect(formatRupiah(0), 'Rp0');
    expect(formatRupiah(999), 'Rp999');
    expect(formatRupiah(1000), 'Rp1.000');
    expect(formatRupiah(10000), 'Rp10.000');
    expect(formatRupiah(100000), 'Rp100.000');
    expect(formatRupiah(1000000), 'Rp1.000.000');
  });

  test('keeps the minus sign outside the digits', () {
    expect(formatRupiah(-1250000), '-Rp1.250.000');
  });

  test('percentages are whole numbers', () {
    expect(formatPercent(0.18), '18%');
    expect(formatPercent(0.34), '34%');
    expect(formatPercent(0.3), '30%');
  });
}
