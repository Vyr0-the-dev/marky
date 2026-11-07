package com.marky.app.marky

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.widget.FrameLayout
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterTextureView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import io.flutter.plugin.common.MethodChannel

internal class ShareOverlayFlutterHost(
    private val activity: Activity,
    private val container: FrameLayout,
    private val initialPayloadProvider: () -> String?,
    private val onFlutterReady: () -> Unit,
    private val onFinishOverlay: () -> Unit,
    private val onOpenMainApp: () -> Unit,
) : ShareOverlayHost {
    companion object {
        const val ENGINE_CACHE_ID = "marky_share_overlay_engine"

        fun warmUpEngine(context: Context) {
            val cache = FlutterEngineCache.getInstance()
            if (cache.contains(ENGINE_CACHE_ID)) return

            val appContext = context.applicationContext
            val loader = FlutterInjector.instance().flutterLoader()
            loader.startInitialization(appContext)
            loader.ensureInitializationComplete(appContext, null)

            val engine = FlutterEngine(appContext)
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(
                    loader.findAppBundlePath(),
                    "shareOverlayMain",
                ),
            )
            cache.put(ENGINE_CACHE_ID, engine)
        }
    }

    private val shareOverlayChannel = "marky/share_overlay"
    private var flutterEngine: FlutterEngine? = null
    private var flutterView: FlutterView? = null
    private var flutterUiDisplayListener: FlutterUiDisplayListener? = null
    private var methodChannel: MethodChannel? = null

    override fun attach() {
        if (flutterEngine != null) return

        val cache = FlutterEngineCache.getInstance()
        var engine = cache.get(ENGINE_CACHE_ID)
        val isWarmEngine = engine != null

        if (engine == null) {
            val appContext = activity.applicationContext
            val loader = FlutterInjector.instance().flutterLoader()
            loader.startInitialization(appContext)
            loader.ensureInitializationComplete(appContext, null)

            engine = FlutterEngine(appContext)
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(
                    loader.findAppBundlePath(),
                    "shareOverlayMain",
                ),
            )
            cache.put(ENGINE_CACHE_ID, engine)
        }

        flutterEngine = engine
        configureShareOverlayChannel(engine)

        val flutterTextureView = FlutterTextureView(activity).apply {
            setOpaque(false)
        }
        val view = FlutterView(activity, flutterTextureView)
        view.setBackgroundColor(Color.TRANSPARENT)
        container.setBackgroundColor(Color.TRANSPARENT)

        val uiDisplayListener = object : FlutterUiDisplayListener {
            override fun onFlutterUiDisplayed() {
                onFlutterReady()
            }

            override fun onFlutterUiNoLongerDisplayed() = Unit
        }
        flutterUiDisplayListener = uiDisplayListener
        view.addOnFirstFrameRenderedListener(uiDisplayListener)

        container.addView(
            view,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )
        view.attachToFlutterEngine(engine)
        engine.lifecycleChannel.appIsResumed()

        if (isWarmEngine) {
            container.post {
                onFlutterReady()
            }
            initialPayloadProvider()?.let { payload ->
                onNewPayload(payload)
            }
        }

        flutterView = view
    }

    override fun onResume() {
        flutterEngine?.lifecycleChannel?.appIsResumed()
    }

    override fun onPause() {
        flutterEngine?.lifecycleChannel?.appIsInactive()
    }

    override fun onStop() {
        flutterEngine?.lifecycleChannel?.appIsPaused()
    }

    override fun destroy() {
        flutterUiDisplayListener?.let { listener ->
            flutterView?.removeOnFirstFrameRenderedListener(listener)
        }
        flutterUiDisplayListener = null
        flutterView?.detachFromFlutterEngine()
        container.removeView(flutterView)
        flutterView = null
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null

        // Pause lifecycle instead of destroying the FlutterEngine so it remains warm in FlutterEngineCache
        flutterEngine?.lifecycleChannel?.appIsPaused()
        flutterEngine = null
    }

    override fun onNewPayload(payload: String?) {
        flutterEngine?.let { engine ->
            MethodChannel(
                engine.dartExecutor.binaryMessenger,
                shareOverlayChannel,
            ).invokeMethod("newPayload", payload)
        }
    }

    private fun configureShareOverlayChannel(engine: FlutterEngine) {
        val channel = MethodChannel(
            engine.dartExecutor.binaryMessenger,
            shareOverlayChannel,
        )
        methodChannel = channel
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialPayload" -> result.success(initialPayloadProvider())
                "flutterReady" -> {
                    onFlutterReady()
                    result.success(null)
                }
                "finishOverlay" -> {
                    onFinishOverlay()
                    result.success(null)
                }
                "openMainApp" -> {
                    onOpenMainApp()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
