package com.pikir.pikir

/** What the scanner concluded about one notification. */
enum class ScanStatus(val wire: String) {
    /** Matched the predatory-lending patterns. Dismissed and replaced. */
    SUSPICIOUS("mencurigakan"),

    /** A due date. Recorded for awareness; the notification is left alone. */
    BILL("tagihan"),

    /** Nothing matched. Left completely untouched. */
    SAFE("aman"),
}

data class ScanResult(
    val status: ScanStatus,
    val reason: String? = null,
    val signals: List<String> = emptyList(),
)

/**
 * Deterministic keyword and regex matching over notification text.
 *
 * Runs entirely on the device with no network involved, which is what lets the
 * permission screen promise that notification text never leaves the phone.
 *
 * This mirrors lib/data/notification_classifier.dart. The two are kept in step
 * by hand for now; when the model lands, both should call it rather than
 * drifting apart.
 *
 * TODO(ml): replace deterministic keyword check with TFLite classifier
 */
object NotificationClassifier {

    /** Predatory-lending phrasing, paired with why it is a warning sign. */
    private val predatorySignals = linkedMapOf(
        "tanpa bi checking" to
            "Menghindari pemeriksaan yang wajib pada pemberi pinjaman resmi.",
        "tanpa slip gaji" to "Melewati pengecekan kemampuan bayar.",
        "tanpa jaminan cair" to "Menjanjikan uang tanpa syarat yang masuk akal.",
        "tanpa survey" to "Melewati verifikasi yang biasa dilakukan lembaga resmi.",
        "langsung cair" to "Janji pencairan super cepat.",
        "cair 3 menit" to "Janji pencairan super cepat.",
        "cair 5 menit" to "Janji pencairan super cepat.",
        "cair hitungan menit" to "Janji pencairan super cepat.",
        "klik sekarang" to "Mendesak kamu memutuskan cepat.",
        "buruan" to "Mendesak kamu memutuskan cepat.",
        "limit kamu naik" to "Menawarkan utang yang tidak kamu minta.",
        "limit naik" to "Menawarkan utang yang tidak kamu minta.",
        "pinjaman disetujui" to "Mengaku menyetujui pinjaman yang tidak kamu ajukan.",
        "dana talangan" to "Istilah yang sering dipakai pinjaman ilegal.",
    )

    /**
     * Due-date phrasing. These are recorded for awareness and never dismissed:
     * a real bill is the user's own business.
     */
    private val billPatterns = listOf(
        Regex("jatuh tempo"),
        Regex("bayar minimum"),
        Regex("segera bayar"),
        Regex("tagihan .*(jatuh|tempo|bayar)"),
    )

    private val repeatedLetter = Regex("([a-z])\\1+")

    /**
     * Lowercases and collapses runs of the same letter.
     *
     * Defeats the common trick of padding words to slip past a filter, so
     * "caiiiir" and "cair" compare equal. Lossy on ordinary words too, which is
     * harmless because both sides of every comparison are normalised the same
     * way.
     */
    private fun normalise(text: String): String =
        repeatedLetter.replace(text.lowercase()) { it.groupValues[1] }

    fun classify(text: String): ScanResult {
        val normalised = normalise(text)

        val matched = mutableListOf<String>()
        val reasons = mutableListOf<String>()
        for ((phrase, reason) in predatorySignals) {
            if (normalised.contains(normalise(phrase))) {
                matched.add(phrase)
                if (!reasons.contains(reason)) reasons.add(reason)
            }
        }

        if (matched.isNotEmpty()) {
            return ScanResult(ScanStatus.SUSPICIOUS, reasons.first(), matched)
        }

        for (pattern in billPatterns) {
            if (pattern.containsMatchIn(normalised)) {
                return ScanResult(
                    ScanStatus.BILL,
                    "Terdeteksi sebagai pengingat jatuh tempo.",
                )
            }
        }

        return ScanResult(ScanStatus.SAFE)
    }

    /** Trims text the way the log stores it. Also used for log lines. */
    fun snippet(text: String, limit: Int = 120): String {
        val collapsed = text.replace(Regex("\\s+"), " ").trim()
        if (collapsed.length <= limit) return collapsed
        return collapsed.substring(0, limit - 1) + "…"
    }
}
