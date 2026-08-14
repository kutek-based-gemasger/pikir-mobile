package com.pikir.pikir

import android.app.Notification
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Handles the two actions on PIKIR's replacement notification.
 *
 * The reveal action is the important one. PIKIR dismissed a message that
 * belonged to the user, and this is how they get it back: the original title
 * and text, reposted verbatim and clearly labelled as the original rather than
 * paraphrased or summarised.
 */
class NotificationActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getStringExtra(NotificationService.EXTRA_ID) ?: return
        val store = ScanLogStore(context)
        val manager = context.getSystemService(NotificationManager::class.java)

        when (intent.action) {
            NotificationService.ACTION_REVEAL -> {
                val original = store.takeOriginal(id) ?: return
                val (appLabel, title, text) = original

                // Reposted word for word. PIKIR's only addition is saying
                // where it came from and that this is the original.
                val notification = Notification.Builder(
                    context,
                    NotificationService.CHANNEL_ID,
                )
                    .setSmallIcon(android.R.drawable.ic_dialog_email)
                    .setContentTitle(
                        if (title.isEmpty()) "Pesan asli dari $appLabel"
                        else title,
                    )
                    .setContentText(text)
                    .setStyle(
                        Notification.BigTextStyle()
                            .bigText(text)
                            .setSummaryText("Pesan asli dari $appLabel"),
                    )
                    .setAutoCancel(true)
                    .build()

                manager.notify("$id-original".hashCode(), notification)
                manager.cancel(id.hashCode())
            }

            NotificationService.ACTION_EXPLAIN -> {
                // Opens the app so the reasons can be read in full.
                //
                // TODO(nav): deep link straight to /scanner/peringatan once
                // that screen exists, rather than landing on the home screen.
                val launch = context.packageManager
                    .getLaunchIntentForPackage(context.packageName)
                    ?.apply { flags = Intent.FLAG_ACTIVITY_NEW_TASK }
                if (launch != null) context.startActivity(launch)
            }
        }
    }
}
