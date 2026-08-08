package com.pikir.pikir

import android.animation.ValueAnimator
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView
import kotlin.math.abs

class FloatingService : Service() {

    // Tracks if the service is alive so Flutter can query it upon startup
    companion object {
        var isRunning = false
    }

    private lateinit var windowManager: WindowManager
    private lateinit var floatingView: View
    private lateinit var chatHeadContainer: LinearLayout
    private lateinit var notificationText: TextView
    private lateinit var broadcastReceiver: BroadcastReceiver
    private lateinit var params: WindowManager.LayoutParams
    
    // Handler to hide the message bubble after a few seconds
    private val hideTextHandler = Handler(Looper.getMainLooper())
    private val hideTextRunnable = Runnable {
        notificationText.visibility = View.GONE
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        isRunning = true // Mark service as alive

        startForegroundServiceSafely()

        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        floatingView = LayoutInflater.from(this).inflate(R.layout.layout_floating_widget, null)
        
        chatHeadContainer = floatingView.findViewById(R.id.chatHeadContainer)
        notificationText = floatingView.findViewById(R.id.notificationText)

        params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 0
            y = 300
        }

        setupTouchListener()
        windowManager.addView(floatingView, params)
        setupBroadcastReceiver()
    }

    private fun startForegroundServiceSafely() {
        val channelId = "floating_service_channel"
        val channel = NotificationChannel(channelId, "Floating UI Service", NotificationManager.IMPORTANCE_LOW)
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(channel)

        val notification = Notification.Builder(this, channelId)
            .setContentTitle("Chat Head Active")
            .setContentText("Listening for notifications...")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .build()

        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(1, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(1, notification)
        }
    }

    private fun setupTouchListener() {
        floatingView.setOnTouchListener(object : View.OnTouchListener {
            private var initialX = 0
            private var initialY = 0
            private var initialTouchX = 0f
            private var initialTouchY = 0f
            private var isDragging = false

            override fun onTouch(v: View, event: MotionEvent): Boolean {
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        isDragging = false
                        initialX = params.x
                        initialY = params.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        
                        // NEW: Shrink animation on press for premium feel
                        chatHeadContainer.animate().scaleX(0.92f).scaleY(0.92f).setDuration(100).start()
                        
                        hideTextHandler.removeCallbacks(hideTextRunnable)
                        notificationText.visibility = View.GONE
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        if (abs(event.rawX - initialTouchX) > 10 || abs(event.rawY - initialTouchY) > 10) {
                            isDragging = true
                        }

                        if (isDragging) {
                            val newX = initialX + (event.rawX - initialTouchX).toInt()
                            val newY = initialY + (event.rawY - initialTouchY).toInt()

                            val displayBounds = windowManager.currentWindowMetrics.bounds
                            val maxY = displayBounds.height() - floatingView.height
                            params.y = newY.coerceIn(0, maxY) 
                            params.x = newX
                            
                            windowManager.updateViewLayout(floatingView, params)
                        }
                        return true
                    }
                    MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                        // NEW: Bounce back to full size on release
                        chatHeadContainer.animate().scaleX(1.0f).scaleY(1.0f).setDuration(150).start()

                        if (!isDragging && event.action == MotionEvent.ACTION_UP) {
                            val intent = Intent(this@FloatingService, MainActivity::class.java).apply {
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                            }
                            startActivity(intent)
                        } else if (isDragging) {
                            val displayBounds = windowManager.currentWindowMetrics.bounds
                            val midScreenX = displayBounds.width() / 2
                            
                            val isLeftHalf = (params.x + (floatingView.width / 2)) < midScreenX
                            val targetX = if (isLeftHalf) 0 else displayBounds.width() - floatingView.width

                            chatHeadContainer.layoutDirection = if (isLeftHalf) {
                                View.LAYOUT_DIRECTION_LTR 
                            } else {
                                View.LAYOUT_DIRECTION_RTL 
                            }

                            animateSnap(params.x, targetX)
                        }
                        return true
                    }
                }
                return false
            }
        })
    }

    private fun animateSnap(startX: Int, endX: Int) {
        val animator = ValueAnimator.ofInt(startX, endX)
        animator.duration = 200
        animator.addUpdateListener { animation ->
            params.x = animation.animatedValue as Int
            windowManager.updateViewLayout(floatingView, params)
        }
        animator.start()
    }

    private fun setupBroadcastReceiver() {
        broadcastReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val title = intent?.getStringExtra("title") ?: return
                val text = intent?.getStringExtra("text") ?: return
                
                // 1. Show the Messenger-style pop out
                notificationText.text = "$title\n$text"
                notificationText.visibility = View.VISIBLE
                
                // 2. Hide it automatically after 4 seconds
                hideTextHandler.removeCallbacks(hideTextRunnable)
                hideTextHandler.postDelayed(hideTextRunnable, 4000)

                // 3. Push a verification notification
                pushVerificationNotification(title, text)
            }
        }
        val filter = IntentFilter("com.pikir.pikir.NEW_NOTIFICATION")
        if (Build.VERSION.SDK_INT >= 33) {
            registerReceiver(broadcastReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(broadcastReceiver, filter)
        }
    }

    private fun pushVerificationNotification(title: String, text: String) {
        val channelId = "verification_channel"
        val manager = getSystemService(NotificationManager::class.java)

        // Create a separate channel for these verification pings
        val channel = NotificationChannel(channelId, "Verification Pings", NotificationManager.IMPORTANCE_HIGH)
        manager.createNotificationChannel(channel)

        val notification = Notification.Builder(this, channelId)
            .setContentTitle("✅ Pikir Captured: $title")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_dialog_email)
            .setAutoCancel(true)
            .build()

        // Use a random ID so multiple verification notifications can stack up in your tray
        manager.notify(System.currentTimeMillis().toInt(), notification)
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false // Mark service as dead
        hideTextHandler.removeCallbacks(hideTextRunnable)
        if (::floatingView.isInitialized) {
            windowManager.removeView(floatingView)
        }
        if (::broadcastReceiver.isInitialized) {
            unregisterReceiver(broadcastReceiver)
        }
    }
}