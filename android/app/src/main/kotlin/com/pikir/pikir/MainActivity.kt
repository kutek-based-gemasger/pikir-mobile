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

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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
        // Since minSdk is 31, we always call startForegroundService
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