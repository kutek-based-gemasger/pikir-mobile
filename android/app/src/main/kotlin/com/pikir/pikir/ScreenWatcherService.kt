package com.pikir.pikir

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

/**
 * Watches for the two moments PIKIR exists to interrupt.
 *
 * A loan app opening, and a paylater checkout. Nothing else: Android is told
 * through res/xml/accessibility_service_config.xml which packages may deliver
 * events here, so outside that list this service never receives anything to
 * read in the first place. That is a stronger guarantee than filtering after
 * the fact, and it is what the proposal's "targeted whitelisting" claim rests
 * on.
 *
 * Nothing read here is stored or transmitted. The screen text is scanned for
 * two sets of phrases and a rupiah figure, then dropped.
 */
class ScreenWatcherService : AccessibilityService() {

    companion object {
        const val TAG = "PikirScreen"

        /** How long before the same app may trigger again. */
        private const val COOLDOWN_MS = 30_000L

        /** Caps the tree walk so a deep layout cannot stall the UI thread. */
        private const val MAX_NODES = 400
    }

    private var lastTriggerPackage: String? = null
    private var lastTriggerAt = 0L

    /** Read fresh on every event, so the switch takes effect immediately. */
    private val settings by lazy { WatcherSettings(this) }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.i(TAG, "connected: watching ${TriggerRules.watchedPackages.size} apps")
    }

    override fun onInterrupt() = Unit

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val packageName = event?.packageName?.toString() ?: return
        if (packageName == this.packageName) return

        // Checked before anything is read, not after. When the user has
        // switched detection off, the screen is not examined at all — the
        // promise is that PIKIR stops looking, not that it looks and then
        // keeps quiet about it.
        if (!settings.isEnabled) return

        if (packageName !in TriggerRules.watchedPackages) return

        when {
            // A lending app is blocked the moment it opens, before the user
            // has read a single offer.
            packageName in TriggerRules.loanPackages &&
                event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                fire(packageName, TRIGGER_LOAN_APP, null)
            }

            // A checkout needs both conditions, so the content of the screen
            // has to be examined rather than just its arrival.
            packageName in TriggerRules.ecommercePackages -> {
                inspectCheckout(packageName)
            }
        }
    }

    private fun inspectCheckout(packageName: String) {
        if (isCoolingDown(packageName)) return

        val root = rootInActiveWindow ?: return
        val text = try {
            collectText(root)
        } finally {
            root.recycle()
        }

        if (!TriggerRules.isPaylaterCheckout(text)) return

        fire(packageName, TRIGGER_CHECKOUT, TriggerRules.extractAmount(text))
    }

    /**
     * Flattens the visible text of the screen.
     *
     * Held in a local StringBuilder for the length of one comparison and never
     * written anywhere.
     */
    private fun collectText(root: AccessibilityNodeInfo): String {
        val builder = StringBuilder()
        val queue = ArrayDeque<AccessibilityNodeInfo>()
        queue.add(root)
        var visited = 0

        while (queue.isNotEmpty() && visited < MAX_NODES) {
            val node = queue.removeFirst()
            visited++

            node.text?.let { builder.append(it).append(' ') }
            node.contentDescription?.let { builder.append(it).append(' ') }

            for (i in 0 until node.childCount) {
                node.getChild(i)?.let { queue.add(it) }
            }
        }

        return builder.toString()
    }

    private fun isCoolingDown(packageName: String): Boolean {
        val now = System.currentTimeMillis()
        return packageName == lastTriggerPackage &&
            now - lastTriggerAt < COOLDOWN_MS
    }

    /**
     * Brings PIKIR to the front carrying what was detected.
     *
     * Starting an activity from the background needs the overlay permission to
     * be granted, which this app already asks for. Without it Android silently
     * drops the start, so the log line below is the only way to tell the
     * difference between "nothing matched" and "matched but could not show".
     */
    private fun fire(packageName: String, trigger: String, amount: Int?) {
        if (isCoolingDown(packageName)) return

        lastTriggerPackage = packageName
        lastTriggerAt = System.currentTimeMillis()

        Log.i(TAG, "trigger=$trigger from=$packageName amount=$amount")

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_SINGLE_TOP or
                Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
            putExtra(EXTRA_TRIGGER, trigger)
            putExtra(EXTRA_SOURCE_APP, packageName)
            if (amount != null) putExtra(EXTRA_AMOUNT, amount)
        }

        try {
            startActivity(intent)
        } catch (error: Exception) {
            Log.w(TAG, "could not show the intervention: $error")
        }
    }
}

const val TRIGGER_CHECKOUT = "checkout_paylater"
const val TRIGGER_LOAN_APP = "loan_app_opened"
const val EXTRA_TRIGGER = "pikir_trigger"
const val EXTRA_SOURCE_APP = "pikir_source_app"
const val EXTRA_AMOUNT = "pikir_amount"
