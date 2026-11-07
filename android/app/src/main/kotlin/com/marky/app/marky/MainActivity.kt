package com.marky.app.marky

import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val quickActionsChannel = "marky/quick_actions"
    private val homeWidgetChannel = "marky/home_widget"
    private var quickActionsMethodChannel: MethodChannel? = null
    private var pendingInitialShortcutRoute: String? = null

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val route = shortcutRouteFrom(intent) ?: return
        quickActionsMethodChannel?.invokeMethod("onShortcutRoute", route)
            ?: run { pendingInitialShortcutRoute = route }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Defer warming up secondary engine until the main thread has rendered and is idle
        android.os.Looper.myQueue().addIdleHandler {
            try {
                ShareOverlayFlutterHost.warmUpEngine(applicationContext)
            } catch (_: Throwable) {}
            false
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
        private val supportedShortcutRoutes = setOf(
            "/home",
            "/add",
            "/search",
            "/home/unread",
            "/reminders",
        )
    }
}
