package com.pikir.pikir

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.yourdomain.chat_head_app/overlay"

    /** The notification scanner's own channel, one per service. */
    private val SCANNER_CHANNEL = "com.pikir.pikir/scanner"

    /** The screen watcher's own channel, one per service. */
    private val SCREEN_CHANNEL = "com.pikir.pikir/screen"

    /**
     * The trigger the screen watcher arrived with, if any.
     *
     * Held until Flutter asks for it and cleared on read, so a trigger is
     * acted on exactly once. onNewIntent updates it when the activity is
     * already running, which is the usual case: PIKIR stays warm in the
     * background.
     */
    private var pendingTrigger: Map<String, Any?>? = null

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        captureTrigger(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        captureTrigger(intent)
    }

    private fun captureTrigger(intent: Intent?) {
        val trigger = intent?.getStringExtra(EXTRA_TRIGGER) ?: return
        pendingTrigger = mapOf(
            "trigger" to trigger,
            "sourceApp" to intent.getStringExtra(EXTRA_SOURCE_APP),
            "amount" to
                if (intent.hasExtra(EXTRA_AMOUNT)) intent.getIntExtra(EXTRA_AMOUNT, 0)
                else null,
        )
        // Cleared from the intent too, so a configuration change does not
        // replay the same interception.
        intent.removeExtra(EXTRA_TRIGGER)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCREEN_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Only the user can grant this, from Android's own
                    // settings. The app can ask and check; it can never switch
                    // it on for them.
                    "checkScreenAccess" -> {
                        val enabled = Settings.Secure.getString(
                            contentResolver,
                            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
                        )
                        result.success(
                            enabled != null &&
                                enabled.contains("$packageName/.ScreenWatcherService"),
                        )
                    }
                    "openScreenAccessSettings" -> {
                        startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                        result.success(null)
                    }
                    // Read once. Returning null means nothing is waiting.
                    "consumePendingTrigger" -> {
                        val trigger = pendingTrigger
                        pendingTrigger = null
                        result.success(trigger)
                    }
                    "watchedApps" -> {
                        result.success(TriggerRules.watchedPackages.toList())
                    }
                    else -> result.notImplemented()
                }
            }

        // The scan log lives in the service's own store, because the service
        // has to keep working with the Flutter engine shut down. Flutter reads
        // it across this channel rather than reaching into the
        // shared_preferences plugin's private encoding.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCANNER_CHANNEL)
            .setMethodCallHandler { call, result ->
                val store = ScanLogStore(this)
                when (call.method) {
                    "scannerLogs" -> result.success(store.logsJson())
                    // Only the user can grant notification access, from
                    // Android's own settings. The app can ask and check; it
                    // can never switch it on for them.
                    "checkNotificationAccess" -> {
                        val flat = Settings.Secure.getString(
                            contentResolver,
                            "enabled_notification_listeners",
                        )
                        result.success(flat != null && flat.contains(packageName))
                    }
                    "openNotificationAccessSettings" -> {
                        startActivity(
                            Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS),
                        )
                        result.success(null)
                    }
                    "scannerIsEnabled" -> result.success(store.isEnabled)
                    "scannerSetEnabled" -> {
                        store.isEnabled = call.argument<Boolean>("enabled") ?: true
                        result.success(null)
                    }
                    "scannerClearLogs" -> {
                        store.clear()
                        result.success(null)
                    }
                    // Mode demo. The real listener ignores our own package,
                    // otherwise the replacement it posts would be scanned and
                    // replaced in turn, so a self-posted notification can
                    // never be intercepted for a recording. This runs the same
                    // classify, record, and replace path directly rather than
                    // faking its result, so what the judges see is the real
                    // behaviour.
                    "demoFlaggedNotification" -> {
                        val appLabel = call.argument<String>("appLabel")
                            ?: "DanaKilat"
                        val title = call.argument<String>("title").orEmpty()
                        val text = call.argument<String>("text").orEmpty()
                        val combined = "$title $text"
                        val scan = NotificationClassifier.classify(combined)
                        val id = "log-${System.currentTimeMillis()}-demo"

                        store.record(
                            id = id,
                            timeIso = NotificationService.isoNow(),
                            sourceApp = appLabel,
                            snippet = NotificationClassifier.snippet(combined),
                            status = scan.status,
                            reason = scan.reason,
                        )

                        if (scan.status == ScanStatus.SUSPICIOUS) {
                            store.rememberOriginal(id, appLabel, title, text)
                            NotificationService.postReplacement(
                                this, id, appLabel, scan.reason,
                            )
                        }

                        result.success(
                            mapOf(
                                "id" to id,
                                "status" to scan.status.wire,
                                "reason" to scan.reason,
                            ),
                        )
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkOverlayPermission" -> {
                    result.success(hasOverlayPermission())
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(null)
                }
                "checkNotificationPermission" -> {
                    result.success(hasNotificationPermission())
                }
                "requestNotificationPermission" -> {
                    requestNotificationPermission()
                    result.success(null)
                }
                "startFloatingService" -> {
                    startFloatingService()
                    result.success(null)
                }
                "stopFloatingService" -> {
                    stopFloatingService()
                    result.success(null)
                }
                "checkPostNotificationPermission" -> {
                    result.success(checkPostNotificationPermission())
                }
                "requestPostNotificationPermission" -> {
                    requestPostNotificationPermission()
                    result.success(null)
                }
                "isServiceRunning" -> {
                    result.success(FloatingService.isRunning)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun hasOverlayPermission(): Boolean {
        // Direct API 31+ call, no conditional checks needed
        return Settings.canDrawOverlays(this)
    }

    private fun requestOverlayPermission() {
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:$packageName")
        )
        startActivity(intent)
    }

    private fun hasNotificationPermission(): Boolean {
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        return flat != null && flat.contains(packageName)
    }

    private fun requestNotificationPermission() {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
        startActivity(intent)
    }

    private fun startFloatingService() {
        val intent = Intent(this, FloatingService::class.java)
        startForegroundService(intent)
    }

    private fun stopFloatingService() {
        val intent = Intent(this, FloatingService::class.java)
        stopService(intent)
    }

    private fun checkPostNotificationPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= 33) { // Android 13+
            checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) == android.content.pm.PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun requestPostNotificationPermission() {
        if (Build.VERSION.SDK_INT >= 33) {
            requestPermissions(arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), 101)
        }
    }
}