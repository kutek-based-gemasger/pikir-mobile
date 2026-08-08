package com.pikir.pikir

import android.app.Notification
import android.content.Intent
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class NotificationService : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn == null) return

        // Extract information
        val packageName = sbn.packageName
        val extras = sbn.notification.extras
        val title = extras.getString(Notification.EXTRA_TITLE) ?: "App"
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""

        // Skip empty notifications or our own foreground service notification
        if (text.isEmpty() || packageName == this.packageName) return

        // Broadcast to our FloatingService
        val intent = Intent("com.pikir.pikir.NEW_NOTIFICATION").apply {
            putExtra("title", title)
            putExtra("text", text)
            setPackage(this@NotificationService.packageName) // Security: only our app can receive this
        }
        sendBroadcast(intent)
    }
}