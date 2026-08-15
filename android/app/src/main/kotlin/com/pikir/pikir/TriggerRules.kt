package com.pikir.pikir

/**
 * What PIKIR watches for, and nothing else.
 *
 * Everything the screen watcher knows lives here so the scope of the
 * Accessibility permission is auditable in one file. The service is also
 * restricted at the OS level by `android:packageNames` in
 * res/xml/accessibility_service_config.xml, so Android itself will not deliver
 * events from any app outside this list. Both lists must be kept in step.
 */
object TriggerRules {

    /**
     * E-commerce apps where a paylater checkout can happen.
     *
     * Edit freely: add a package here and to accessibility_service_config.xml.
     */
    val ecommercePackages = setOf(
        "com.tokopedia.tkpd", // verified
        "com.ss.android.ugc.trill", // verified; TikTok, which carries TikTok Shop
        "com.shopee.id", // unverified
        "com.lazada.android", // unverified
        "com.bukalapak.android", // unverified
    )

    /**
     * Lending apps that trigger the moment they open.
     *
     * These are licensed, popular apps rather than illegal ones. That is
     * deliberate: the proposal's own argument is that the larger harm by volume
     * comes from legal lenders disbursing quickly for consumptive needs, so
     * intervening only on illegal apps would miss most of the problem.
     *
     * A wrong package name here fails silently: the trigger simply never
     * fires, with no error to notice. Verify each one against a device that
     * has the app installed before trusting it:
     *
     *     adb shell pm list packages | grep -i <nama aplikasi>
     *
     * Verified on a real device: Easycash only. The rest are unverified and
     * should be checked the same way before the recording.
     */
    val loanPackages = setOf(
        "com.fintopia.idnEasycash.google", // verified
        "com.kredivo.mobile", // unverified
        "com.akulaku.android", // unverified
        "com.adakami.id", // unverified
        "com.julo.app", // unverified
        "com.indodana.customer", // unverified
    )

    val watchedPackages: Set<String> = ecommercePackages + loanPackages

    /**
     * Phrases that mean "this is a checkout screen".
     *
     * Matched case-insensitively against the visible text of the current
     * screen. Nothing is stored and nothing leaves the device.
     */
    private val checkoutPhrases = listOf(
        "checkout",
        "buat pesanan",
        "ringkasan pesanan",
        "metode pembayaran",
        "total pembayaran",
        "total bayar",
        "pilih pembayaran",
        "bayar sekarang",
    )

    /** Phrases that mean a paylater method is in play. */
    private val paylaterPhrases = listOf(
        "paylater",
        "pay later",
        "spaylater",
        "gopaylater",
        "bayar nanti",
        "cicilan",
        "cicil ",
        "kredivo",
        "akulaku",
        "indodana",
    )

    /** Finds a rupiah figure so the intervention can name the real amount. */
    private val amountPattern = Regex("""rp\s?([0-9][0-9.,]{3,})""")

    /**
     * Whether the screen is a checkout AND a paylater method is present.
     *
     * Both, never either. CLAUDE.md section 7 is explicit about this, and the
     * reason is behavioural rather than technical: firing on every checkout
     * would interrupt each ordinary purchase the user makes and teach them to
     * dismiss PIKIR without reading it, which costs the one moment that
     * matters.
     */
    fun isPaylaterCheckout(screenText: String): Boolean {
        val text = screenText.lowercase()
        val isCheckout = checkoutPhrases.any { text.contains(it) }
        val hasPaylater = paylaterPhrases.any { text.contains(it) }
        return isCheckout && hasPaylater
    }

    /** The largest rupiah figure on screen, which is usually the total. */
    fun extractAmount(screenText: String): Int? {
        val matches = amountPattern.findAll(screenText.lowercase())
        var largest: Int? = null
        for (match in matches) {
            val digits = match.groupValues[1].replace(Regex("[^0-9]"), "")
            if (digits.isEmpty() || digits.length > 12) continue
            val value = digits.toLongOrNull() ?: continue
            // Below ten thousand is usually a unit price or a shipping fee,
            // not the total the user is about to commit to.
            if (value < 10_000) continue
            if (largest == null || value > largest!!) largest = value.toInt()
        }
        return largest
    }
}
