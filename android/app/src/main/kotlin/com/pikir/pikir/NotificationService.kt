package com.pikir.pikir

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Reads incoming notifications and acts on the predatory ones.
 *
 * What it does, in order:
 *  - classifies the text deterministically, on the device, with no network
 *  - leaves anything unflagged completely alone, with no PIKIR marking at all
 *  - records a due-date reminder for awareness but never touches it
 *  - dismisses a predatory offer and posts its own notification in its place
 *
 * The replacement always carries an action that reveals the original message.
 * Silencing something on somebody's behalf is only defensible if they can
 * still get to it, so the original text is kept before the dismissal and the
 * reveal action is not optional.
 */
class NotificationService : NotificationListenerService() {

    private lateinit var store: ScanLogStore

    companion object {
        /** Filter logcat with this to watch the scanner: `adb logcat -s PikirScanner`. */
        const val TAG = "PikirScanner"

        const val CHANNEL_ID = "pikir_scanner"
        const val ACTION_REVEAL = "com.pikir.pikir.REVEAL_ORIGINAL"
        const val ACTION_EXPLAIN = "com.pikir.pikir.EXPLAIN_WARNING"
        const val EXTRA_ID = "pikir_entry_id"

        fun isoNow(): String =
            SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.US).format(Date())

        fun ensureChannel(context: Context) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Peringatan PIKIR",
                // High enough to be seen in place of what was dismissed, while
                // the content itself stays factual rather than alarming.
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Pemberitahuan saat PIKIR menahan pesan berisiko."
            }
            context.getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }

        /**
         * Posts PIKIR's own notification in place of one that was dismissed.
         *
         * On the companion rather than the instance so Mode Demo can fire the
         * same code path. The real listener ignores our own package, otherwise
         * the replacement would itself be scanned and replaced, which means a
         * self-posted notification can never be intercepted for a recording.
         */
        fun postReplacement(
            context: Context,
            id: String,
            appLabel: String,
            reason: String?,
        ) {
            ensureChannel(context)

            val explanation = reason
                ?: "Pesan ini punya ciri tawaran pinjaman berisiko."

            val notification = Notification.Builder(context, CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentTitle("Kami tahan 1 pesan berisiko")
                .setContentText("Dari $appLabel. $explanation")
                .setStyle(
                    Notification.BigTextStyle().bigText(
                        "Dari $appLabel. $explanation Kami sembunyikan " +
                            "supaya kamu tidak tergoda dulu.",
                    ),
                )
                .setAutoCancel(false)
                .addAction(action(context, ACTION_EXPLAIN, id, "Lihat alasannya"))
                // Mandatory. The user is never locked out of their own
                // message, and this action is as readable as the one beside it.
                .addAction(
                    action(context, ACTION_REVEAL, id, "Tampilkan pesan aslinya"),
                )
                .build()

            context.getSystemService(NotificationManager::class.java)
                .notify(id.hashCode(), notification)
        }

        private fun action(
            context: Context,
            actionName: String,
            id: String,
            label: String,
        ): Notification.Action {
            val intent = Intent(context, NotificationActionReceiver::class.java)
                .apply {
                    action = actionName
                    putExtra(EXTRA_ID, id)
                    setPackage(context.packageName)
                }
            val pending = PendingIntent.getBroadcast(
                context,
                (actionName + id).hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            return Notification.Action.Builder(null, label, pending).build()
        }
    }

    override fun onCreate() {
        super.onCreate()
        store = ScanLogStore(this)
        ensureChannel(this)
        Log.i(TAG, "onCreate")
    }

    /**
     * Fires when Android actually binds the listener.
     *
     * Worth logging loudly: everything else in this class is dead code until
     * this runs, and the two reasons it does not are both invisible from
     * inside the app. Either notification access was never granted, or the app
     * was reinstalled and Android dropped the grant without saying so.
     */
    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.i(TAG, "onListenerConnected: PIKIR is receiving notifications")
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        Log.w(TAG, "onListenerDisconnected: no longer receiving notifications")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn == null) return

        // Each early return is logged with its reason. A scanner that silently
        // does nothing is indistinguishable from a broken one, and these are
        // the exact points where a working build still looks dead.
        if (!store.isEnabled) {
            Log.d(TAG, "skipped ${sbn.packageName}: scanning is switched off")
            return
        }

        // Never react to our own notifications, or the flow would loop.
        if (sbn.packageName == packageName) {
            Log.d(TAG, "skipped: our own notification")
            return
        }

        // Ongoing notifications are music players, downloads, and foreground
        // services. None of them is a loan offer.
        if (sbn.isOngoing) {
            Log.d(TAG, "skipped ${sbn.packageName}: ongoing")
            return
        }

        val extras = sbn.notification.extras
        val title = extras.getString(Notification.EXTRA_TITLE).orEmpty()
        val text =
            extras.getCharSequence(Notification.EXTRA_TEXT)?.toString().orEmpty()
        if (title.isEmpty() && text.isEmpty()) return

        val appLabel = appLabelOf(sbn.packageName)
        val combined = "$title $text"
        val result = NotificationClassifier.classify(combined)
        val id = "log-${System.currentTimeMillis()}-${sbn.id}"

        Log.d(
            TAG,
            "scanned ${sbn.packageName} -> ${result.status.wire} " +
                "signals=${result.signals} text=\"${
                    NotificationClassifier.snippet(combined, 80)
                }\"",
        )

        // Everything is logged, flagged or not, because the scan history is
        // how the user checks what PIKIR has been doing on their behalf.
        store.record(
            id = id,
            timeIso = isoNow(),
            sourceApp = appLabel,
            snippet = NotificationClassifier.snippet(combined),
            status = result.status,
            reason = result.reason,
        )

        if (result.status != ScanStatus.SUSPICIOUS) return

        // Kept before anything is dismissed, so the reveal action always has
        // something to show. Dismissal comes before the replacement so the
        // original and the warning never sit in the shade together.
        store.rememberOriginal(id, appLabel, title, text)
        cancelNotification(sbn.key)
        postReplacement(this, id, appLabel, result.reason)
        Log.i(TAG, "held a message from $appLabel and posted the replacement")
    }

    private fun appLabelOf(pkg: String): String = try {
        val info = packageManager.getApplicationInfo(pkg, 0)
        packageManager.getApplicationLabel(info).toString()
    } catch (_: Exception) {
        pkg
    }
}
