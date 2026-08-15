package com.pikir.pikir

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Locale

/**
 * The scan log, on the device.
 *
 * Kept in the app's own SharedPreferences file rather than the one the Flutter
 * shared_preferences plugin owns. That plugin encodes a List<String> with an
 * internal marker prefix, so writing to it from Kotlin would mean depending on
 * a private encoding that can change with a plugin update. Flutter reads this
 * store through a MethodChannel instead, which is a contract both sides can
 * see.
 *
 * The log is capped and stores only a short excerpt. It exists so the user can
 * see what PIKIR has been doing on their behalf, not so the app accumulates a
 * copy of their inbox.
 *
 * TODO(storage): this is plain key-value storage, not encrypted, and it holds
 * excerpts of notification text. The privacy screen promises encryption at
 * rest, so this must move to an encrypted store before any real release.
 */
class ScanLogStore(context: Context) {

    private val prefs =
        context.getSharedPreferences("pikir_scanner", Context.MODE_PRIVATE)

    companion object {
        private const val KEY_LOGS = "logs"
        private const val KEY_ENABLED = "enabled"
        private const val KEY_ORIGINALS = "originals"
        private const val MAX_ENTRIES = 200

        /** Matches the chat history window: nothing lingers past a day. */
        private const val RETENTION_HOURS = 24
    }

    var isEnabled: Boolean
        get() = prefs.getBoolean(KEY_ENABLED, true)
        set(value) = prefs.edit().putBoolean(KEY_ENABLED, value).apply()

    /**
     * Newest first, as a JSON array string ready to hand to Flutter.
     *
     * Expired rows are dropped on read, so the log cannot outlive its window
     * just because nothing happened to write to it.
     */
    fun logsJson(): String {
        val pruned = pruneExpired(JSONArray(prefs.getString(KEY_LOGS, "[]") ?: "[]"))
        return pruned.toString()
    }

    /**
     * Drops entries older than [RETENTION_HOURS], and the original text kept
     * alongside them.
     *
     * The proposal promises notification content does not accumulate on the
     * device. It cannot promise the content is never stored at all, because
     * the replacement notification has to be able to show the user the message
     * it dismissed, and that means keeping it. Bounded retention is the honest
     * version of that promise, and this is where it is enforced.
     */
    private fun pruneExpired(entries: JSONArray): JSONArray {
        val cutoff = System.currentTimeMillis() - RETENTION_HOURS * 3_600_000L
        val kept = JSONArray()
        val keptIds = mutableSetOf<String>()

        for (i in 0 until entries.length()) {
            val entry = entries.optJSONObject(i) ?: continue
            val time = parseIso(entry.optString("time"))
            if (time != null && time < cutoff) continue
            kept.put(entry)
            keptIds.add(entry.optString("id"))
        }

        if (kept.length() != entries.length()) {
            prefs.edit().putString(KEY_LOGS, kept.toString()).apply()
            forgetOriginalsExcept(keptIds)
        }

        return kept
    }

    private fun parseIso(value: String?): Long? {
        if (value.isNullOrEmpty()) return null
        return try {
            SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.US)
                .parse(value)?.time
        } catch (_: Exception) {
            null
        }
    }

    /** Removes stored originals whose log entry is gone. */
    private fun forgetOriginalsExcept(keepIds: Set<String>) {
        val originals = JSONObject(prefs.getString(KEY_ORIGINALS, "{}") ?: "{}")
        val trimmed = JSONObject()
        for (key in originals.keys()) {
            if (keepIds.contains(key)) trimmed.put(key, originals.get(key))
        }
        prefs.edit().putString(KEY_ORIGINALS, trimmed.toString()).apply()
    }

    fun record(
        id: String,
        timeIso: String,
        sourceApp: String,
        snippet: String,
        status: ScanStatus,
        reason: String?,
    ) {
        val entry = JSONObject().apply {
            put("id", id)
            put("time", timeIso)
            put("sourceApp", sourceApp)
            put("snippet", snippet)
            put("status", status.wire)
            put("reason", reason ?: JSONObject.NULL)
        }

        val existing = JSONArray(logsJson())
        val trimmed = JSONArray().apply {
            put(entry)
            for (i in 0 until minOf(existing.length(), MAX_ENTRIES - 1)) {
                put(existing.get(i))
            }
        }

        prefs.edit().putString(KEY_LOGS, trimmed.toString()).apply()
    }

    fun clear() = prefs.edit().remove(KEY_LOGS).apply()

    /**
     * Keeps the text of a notification that was dismissed.
     *
     * Without this the reveal action would have nothing to show, and the user
     * would be locked out of their own message. That is the one thing the
     * scanner must never do.
     */
    fun rememberOriginal(id: String, appLabel: String, title: String, text: String) {
        val originals = JSONObject(prefs.getString(KEY_ORIGINALS, "{}") ?: "{}")
        originals.put(
            id,
            JSONObject().apply {
                put("appLabel", appLabel)
                put("title", title)
                put("text", text)
            },
        )
        prefs.edit().putString(KEY_ORIGINALS, originals.toString()).apply()
    }

    fun takeOriginal(id: String): Triple<String, String, String>? {
        val originals = JSONObject(prefs.getString(KEY_ORIGINALS, "{}") ?: "{}")
        val entry = originals.optJSONObject(id) ?: return null
        return Triple(
            entry.optString("appLabel", "Aplikasi"),
            entry.optString("title", ""),
            entry.optString("text", ""),
        )
    }
}
