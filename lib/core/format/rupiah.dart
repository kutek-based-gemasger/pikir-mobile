/// Currency formatting for PIKIR.
///
/// CLAUDE.md section 6 rule 6: all costs are shown in rupiah, formatted
/// `Rp1.800.000`, with no cents. Dot separators, no space after `Rp`.
///
/// Written by hand rather than pulled from `intl` because this is the only
/// formatting the app needs and the rule is one line long.
library;

/// Formats [amount] as `Rp1.800.000`.
///
/// Cents do not exist in this app's money. Callers pass whole rupiah.
///
/// A negative amount reads `-Rp1.250.000`: the sign belongs to the whole
/// figure, so it sits outside the currency mark rather than between it and
/// the digits.
String formatRupiah(int amount) =>
    amount < 0 ? '-Rp${formatThousands(-amount)}' : 'Rp${formatThousands(amount)}';

/// Formats [amount] with dot thousand separators and no currency prefix,
/// for the places where `Rp` is already rendered as a separate prefix element,
/// such as a large input field.
String formatThousands(int amount) {
  final negative = amount < 0;
  final digits = amount.abs().toString();

  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    // A separator goes before every digit whose distance from the end is a
    // multiple of three, except at the very start of the number.
    final remaining = digits.length - i;
    if (i > 0 && remaining % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }

  return negative ? '-$buffer' : buffer.toString();
}

/// Formats a 0..1 ratio as a whole-number percentage, `18%`.
///
/// Debt ratios are always shown as whole percentages: a decimal place implies
/// a precision the underlying estimate does not have.
String formatPercent(double ratio) => '${(ratio * 100).round()}%';
