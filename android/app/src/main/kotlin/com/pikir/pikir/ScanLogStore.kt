package com.pikir.pikir

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

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
    }

    var isEnabled: Boolean
        get() = prefs.getBoolean(KEY_ENABLED, true)
        set(value) = prefs.edit().putBoolean(KEY_ENABLED, value).apply()

    /** Newest first, as a JSON array string ready to hand to Flutter. */
    fun logsJson(): String = prefs.getString(KEY_LOGS, "[]") ?: "[]"

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
