package com.marky.app.marky

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.widget.FrameLayout

class ShareOverlayActivity : Activity() {
    private var initialPayload: String? = null
    private var startupOverlay: View? = null
    private var rootLayout: FrameLayout? = null
    private var flutterContainer: FrameLayout? = null
    private var flutterHost: ShareOverlayHost? = null
    private var flutterAttached = false
    private val attachFlutterRunnable = Runnable {
        if (!isFinishing && !isDestroyed) {
            attachFlutterEngine()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        initialPayload = extractPayload(intent)
        super.onCreate(savedInstanceState)
        applyZeroTransitions()
        try {
            val loader = io.flutter.FlutterInjector.instance().flutterLoader()
            loader.startInitialization(applicationContext)
        } catch (_: Throwable) {}
        window.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        val root = FrameLayout(this).apply {
            setBackgroundColor(Color.TRANSPARENT)
            val flutterHost = FrameLayout(this@ShareOverlayActivity)
            flutterContainer = flutterHost
            addView(
                flutterHost,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT,
                ),
            )
        }
        rootLayout = root
        setContentView(root)
        val isWarm = io.flutter.embedding.engine.FlutterEngineCache.getInstance().contains(ShareOverlayFlutterHost.ENGINE_CACHE_ID)
        if (!isWarm) {
            showStartupOverlay()
        }
        attachFlutterAfterFirstNativeDraw(root)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val payload = extractPayload(intent)
        initialPayload = payload
        flutterHost?.onNewPayload(payload)
    }

    override fun onResume() {
        super.onResume()
        flutterHost?.onResume()
    }

    override fun onPause() {
        flutterHost?.onPause()
        super.onPause()
    }

    override fun onStop() {
        flutterHost?.onStop()
        super.onStop()
    }

    override fun onDestroy() {
        rootLayout?.removeCallbacks(attachFlutterRunnable)
        rootLayout = null
        flutterContainer = null
        flutterHost?.destroy()
        flutterHost = null
        super.onDestroy()
    }

    override fun onBackPressed() {
        finishOverlayNow()
    }

    override fun finish() {
        super.finish()
        applyZeroTransitions()
    }

    private fun attachFlutterEngine() {
        if (flutterAttached) return
        flutterAttached = true
        val container = flutterContainer ?: return
        flutterHost = createFlutterHost(container).also { host ->
            host.attach()
        }
    }

    private fun createFlutterHost(container: FrameLayout): ShareOverlayHost {
        val hostClass = Class.forName("com.marky.app.marky.ShareOverlayFlutterHost")
        val constructor = hostClass.getDeclaredConstructor(
            Activity::class.java,
            FrameLayout::class.java,
            kotlin.jvm.functions.Function0::class.java,
            kotlin.jvm.functions.Function0::class.java,
            kotlin.jvm.functions.Function0::class.java,
            kotlin.jvm.functions.Function0::class.java,
        )
        constructor.isAccessible = true
        return constructor.newInstance(
            this,
            container,
            { initialPayload },
            { hideStartupOverlay() },
            {
                finishOverlayNow()
            },
            {
                val openIntent = Intent(this, MainActivity::class.java).apply {
                    action = Intent.ACTION_MAIN
                    addCategory(Intent.CATEGORY_LAUNCHER)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                }
                startActivity(openIntent)
                finishOverlayNow()
            },
        ) as ShareOverlayHost
    }

    private fun attachFlutterAfterFirstNativeDraw(root: View) {
        root.viewTreeObserver.addOnPreDrawListener(
            object : ViewTreeObserver.OnPreDrawListener {
                override fun onPreDraw(): Boolean {
                    if (root.viewTreeObserver.isAlive) {
                        root.viewTreeObserver.removeOnPreDrawListener(this)
                    }
                    root.post(attachFlutterRunnable)
                    return true
                }
            },
        )
    }

    private fun extractPayload(intent: Intent?): String? {
        if (intent == null) return null

        val parts = mutableListOf<String>()
        when (intent.action) {
            Intent.ACTION_SEND -> {
                intent.getStringExtra(Intent.EXTRA_TEXT)?.let(parts::add)
                intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)?.toString()?.let(parts::add)
                appendClipData(intent, parts)
            }
            Intent.ACTION_SEND_MULTIPLE -> {
                val texts = intent.getStringArrayListExtra(Intent.EXTRA_TEXT)
                if (!texts.isNullOrEmpty()) {
                    parts.addAll(texts)
                } else {
                    intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)
                        ?.map(Uri::toString)
                        ?.let(parts::addAll)
                }
                appendClipData(intent, parts)
            }
        }

        return parts
            .map(String::trim)
            .filter(String::isNotEmpty)
            .distinct()
            .joinToString(separator = "\n")
            .takeIf(String::isNotEmpty)
    }

    private fun appendClipData(intent: Intent, parts: MutableList<String>) {
        val clipData = intent.clipData ?: return
        for (index in 0 until clipData.itemCount) {
            val item = clipData.getItemAt(index)
            item.text?.toString()?.let(parts::add)
            item.uri?.toString()?.let(parts::add)
        }
    }

    private fun showStartupOverlay() {
        if (startupOverlay != null) return
        val overlay = FrameLayout(this).apply {
            setBackgroundColor(Color.TRANSPARENT)
        }
        startupOverlay = overlay
        addContentView(
            overlay,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )
    }

    private fun hideStartupOverlay() {
        val overlay = startupOverlay ?: return
        startupOverlay = null
        overlay.visibility = View.GONE
        (overlay.parent as? ViewGroup)?.removeView(overlay)
    }

    private fun finishOverlayNow() {
        hideStartupOverlay()
        finish()
        applyZeroTransitions()
    }

    private fun applyZeroTransitions() {
        if (Build.VERSION.SDK_INT >= 34) {
            overrideActivityTransition(Activity.OVERRIDE_TRANSITION_OPEN, 0, 0)
            overrideActivityTransition(Activity.OVERRIDE_TRANSITION_CLOSE, 0, 0)
        } else {
            @Suppress("DEPRECATION")
            overridePendingTransition(0, 0)
        }
    }
}


