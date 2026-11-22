package com.marky.app.marky

import android.content.Intent
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val quickActionsChannel = "marky/quick_actions"
    private val homeWidgetChannel = "marky/home_widget"
    private val mainHandler = Handler(Looper.getMainLooper())
    private var quickActionsMethodChannel: MethodChannel? = null
    private var pendingInitialShortcutRoute: String? = null
    private var shareOverlayWarmUpScheduled = false
    private var flutterUiDisplayListener: FlutterUiDisplayListener? = null
    private val shareOverlayWarmUpRunnable = Runnable {
        if (isDestroyed || isFinishing) return@Runnable
        try {
            ShareOverlayFlutterHost.warmUpEngine(applicationContext)
        } catch (_: Throwable) {}
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val route = shortcutRouteFrom(intent) ?: return
        quickActionsMethodChannel?.invokeMethod("onShortcutRoute", route)
            ?: run { pendingInitialShortcutRoute = route }
    }

    override fun onDestroy() {
        mainHandler.removeCallbacks(shareOverlayWarmUpRunnable)
        flutterUiDisplayListener?.let { listener ->
            flutterEngine?.renderer?.removeIsDisplayingFlutterUiListener(listener)
            flutterUiDisplayListener = null
        }
        super.onDestroy()
    }

    private fun scheduleShareOverlayWarmUp() {
        if (shareOverlayWarmUpScheduled) return
        shareOverlayWarmUpScheduled = true
        mainHandler.postDelayed(
            shareOverlayWarmUpRunnable,
            SHARE_OVERLAY_WARMUP_DELAY_MS,
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Warm up the secondary ShareOverlay engine ONLY after Flutter's first
        // frame is already visibly painted and the splash screen has dismissed,
        // so cold-start launch is never blocked by booting a second engine.
        val renderer = flutterEngine.renderer
        if (renderer.isDisplayingFlutterUi) {
            scheduleShareOverlayWarmUp()
        } else {
            val listener = object : FlutterUiDisplayListener {
                override fun onFlutterUiDisplayed() {
                    renderer.removeIsDisplayingFlutterUiListener(this)
                    flutterUiDisplayListener = null
                    scheduleShareOverlayWarmUp()
                }

                override fun onFlutterUiNoLongerDisplayed() = Unit
            }
            flutterUiDisplayListener = listener
            renderer.addIsDisplayingFlutterUiListener(listener)
        }
        pendingInitialShortcutRoute = shortcutRouteFrom(intent)
        quickActionsMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            quickActionsChannel
        )
        quickActionsMethodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialShortcutRoute" -> {
                    val route = pendingInitialShortcutRoute
                    pendingInitialShortcutRoute = null
                    result.success(route)
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            homeWidgetChannel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateFeedWidget" -> {
                    MarkyFeedWidgetProvider.updateAll(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun shortcutRouteFrom(intent: Intent?): String? {
        if (intent?.action != openRouteAction) return null
        val route = intent.getStringExtra(routeExtra)?.trim() ?: return null
        return if (supportedShortcutRoutes.contains(route)) route else null
    }

    companion object {
        const val openRouteAction = "com.marky.app.marky.action.OPEN_ROUTE"
        const val routeExtra = "route"
        private const val SHARE_OVERLAY_WARMUP_DELAY_MS = 1500L
        private val supportedShortcutRoutes = setOf(
            "/home",
            "/add",
            "/search",
            "/home/unread",
            "/reminders",
        )
    }
}
