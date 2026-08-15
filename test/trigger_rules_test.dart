import 'package:flutter_test/flutter_test.dart';

/// The checkout rule, mirrored from TriggerRules.kt.
///
/// The Kotlin is the implementation; this asserts the rule it encodes, because
/// the rule is a product decision CLAUDE.md section 7 is explicit about and
/// there is no Kotlin test harness in this project. Both must be changed
/// together.
bool isPaylaterCheckout(String screenText) {
  const checkout = [
    'checkout', 'buat pesanan', 'ringkasan pesanan', 'metode pembayaran',
    'total pembayaran', 'total bayar', 'pilih pembayaran', 'bayar sekarang',
  ];
  const paylater = [
    'paylater', 'pay later', 'spaylater', 'gopaylater', 'bayar nanti',
    'cicilan', 'cicil ', 'kredivo', 'akulaku', 'indodana',
  ];
  final text = screenText.toLowerCase();
  return checkout.any(text.contains) && paylater.any(text.contains);
}

void main() {
  test('a checkout without paylater does not trigger', () {
    // Both conditions, never either. Firing on every checkout would interrupt
    // each ordinary purchase and teach the user to dismiss PIKIR unread.
    expect(
      isPaylaterCheckout('Checkout  Total pembayaran Rp250.000  Transfer Bank'),
      isFalse,
    );
  });

  test('paylater outside a checkout does not trigger', () {
    expect(
      isPaylaterCheckout('Promo SPayLater diskon 50% untuk pengguna baru'),
      isFalse,
    );
  });

  test('both together trigger', () {
    expect(
      isPaylaterCheckout(
        'Checkout  Metode pembayaran  SPayLater  Total bayar Rp1.250.000',
      ),
      isTrue,
    );
  });

  test('an ordinary browsing screen does not trigger', () {
    expect(isPaylaterCheckout('Rekomendasi untukmu  Sepatu Pria  Rp199.000'),
        isFalse);
  });
}
