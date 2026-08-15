package com.pikir.pikir

import android.content.Context

/**
 * The user's own switch for screen detection.
 *
 * Separate from the Android permission, and deliberately so. The permission is
 * granted once on a settings screen the app cannot reach into; this is the
 * switch inside PIKIR that says whether the detection should act right now.
 * Somebody who wants the interception off for an afternoon should not have to
 * dig through Android's accessibility settings and then remember to put it
 * back — and an app that can only be silenced by revoking its permission is an
 * app people uninstall instead.
 *
 * Read on the service's own thread with no Flutter engine running, which is
 * why it lives in SharedPreferences here rather than in the encrypted store.
 * Nothing sensitive is kept in it: one boolean.
 */
class WatcherSettings(context: Context) {

    private val prefs =
        context.getSharedPreferences("pikir_watcher", Context.MODE_PRIVATE)

    /**
     * Defaults to on.
     *
     * Someone who has granted the accessibility permission has already said
     * what they want; making them flip a second switch afterwards would just
     * be a way for the protection to look broken.
     */
    var isEnabled: Boolean
        get() = prefs.getBoolean(KEY_ENABLED, true)
        set(value) = prefs.edit().putBoolean(KEY_ENABLED, value).apply()

    private companion object {
        const val KEY_ENABLED = "enabled"
    }
}
