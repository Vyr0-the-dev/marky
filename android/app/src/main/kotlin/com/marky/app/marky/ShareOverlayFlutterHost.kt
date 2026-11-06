package com.marky.app.marky

import android.app.Activity
import android.graphics.Color
import android.widget.FrameLayout
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterTextureView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
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
    private val shareOverlayChannel = "marky/share_overlay"
    private var flutterEngine: FlutterEngine? = null
    private var flutterView: FlutterView? = null
    private var flutterUiDisplayListener: FlutterUiDisplayListener? = null

    override fun attach() {
        if (flutterEngine != null) return

        val engine = FlutterEngine(activity)
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

        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(activity)
        loader.ensureInitializationComplete(activity, null)
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(
                loader.findAppBundlePath(),
                "shareOverlayMain",
            ),
        )
        engine.lifecycleChannel.appIsResumed()

        flutterEngine = engine
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
        flutterView = null
        flutterEngine?.lifecycleChannel?.appIsDetached()
        flutterEngine?.destroy()
        flutterEngine = null
    }

    private fun configureShareOverlayChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            shareOverlayChannel,
        ).setMethodCallHandler { call, result ->
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
