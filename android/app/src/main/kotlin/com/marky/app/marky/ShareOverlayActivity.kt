package com.marky.app.marky

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.animation.ValueAnimator
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.os.Build
import android.os.LocaleList
import android.os.Bundle
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import java.util.Locale
import kotlin.math.max
import kotlin.math.min

class ShareOverlayActivity : Activity() {
    private var initialPayload: String? = null
    private var startupOverlay: View? = null
    private var startupPulse: AnimatorSet? = null
    private var rootLayout: FrameLayout? = null
    private var flutterContainer: FrameLayout? = null
    private var flutterHost: ShareOverlayHost? = null
    private var flutterAttached = false
    private val flutterAttachDelayMillis = 700L
    private val attachFlutterRunnable = Runnable {
        if (!isFinishing && !isDestroyed) {
            attachFlutterEngine()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        initialPayload = extractPayload(intent)
        super.onCreate(savedInstanceState)
        try {
            val loader = io.flutter.FlutterInjector.instance().flutterLoader()
            loader.startInitialization(applicationContext)
        } catch (_: Throwable) {}
        window.setBackgroundDrawableResource(R.drawable.share_overlay_dim_background)
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
        showStartupOverlay()
        attachFlutterAfterFirstNativeDraw(root)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        initialPayload = extractPayload(intent)
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
        val copy = startupCopy()

        val overlay = FrameLayout(this).apply {
            setBackgroundColor(Color.TRANSPARENT)
            isClickable = true
        }

        val panel = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(dp(24), dp(14), dp(24), dp(24))
            background = GradientDrawable().apply {
                setColor(Color.rgb(3, 3, 3))
                val r = dp(28).toFloat()
                cornerRadii = floatArrayOf(r, r, r, r, 0f, 0f, 0f, 0f)
                setStroke(dp(1), Color.argb(80, 255, 255, 255))
            }
            elevation = dp(18).toFloat()
            minimumHeight = dp(384)
        }
        bindStartupPanelDrag(panel)

        val handle = View(this).apply {
            background = GradientDrawable().apply {
                setColor(Color.argb(70, 255, 255, 255))
                cornerRadius = dp(999).toFloat()
            }
        }
        panel.addView(
            handle,
            LinearLayout.LayoutParams(dp(42), dp(5)).apply {
                bottomMargin = dp(36)
            },
        )

        val statusHost = FrameLayout(this).apply {
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.argb(26, 143, 163, 255))
            }
        }
        val statusDot = View(this).apply {
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.rgb(143, 163, 255))
            }
        }
        statusHost.addView(
            statusDot,
            FrameLayout.LayoutParams(dp(34), dp(34), Gravity.CENTER),
        )
        startPulse(statusHost)
        panel.addView(
            statusHost,
            LinearLayout.LayoutParams(dp(116), dp(116)).apply {
                bottomMargin = dp(12)
            },
        )

        val title = TextView(this).apply {
            text = copy.title
            setTextColor(Color.WHITE)
            textSize = 22f
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
        }
        panel.addView(title)

        val message = TextView(this).apply {
            text = copy.message
            setTextColor(Color.argb(190, 255, 255, 255))
            textSize = 14f
            gravity = Gravity.CENTER
            setPadding(0, dp(8), 0, 0)
        }
        panel.addView(message)

        panel.addView(
            View(this),
            LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f),
        )

        val action = TextView(this).apply {
            text = copy.action
            setTextColor(Color.argb(150, 255, 255, 255))
            textSize = 15f
            gravity = Gravity.CENTER
            background = GradientDrawable().apply {
                setColor(Color.argb(46, 255, 255, 255))
                cornerRadius = dp(18).toFloat()
            }
        }
        panel.addView(
            action,
            LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, dp(52)),
        )

        overlay.addView(
            panel,
            FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, dp(384)).apply {
                gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
                leftMargin = 0
                rightMargin = 0
                bottomMargin = 0
            },
        )

        startupOverlay = overlay
        addContentView(
            overlay,
            FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT),
        )
    }

    private fun hideStartupOverlay() {
        val overlay = startupOverlay ?: return
        startupOverlay = null
        startupPulse?.cancel()
        startupPulse = null
        window.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        overlay.post {
            (overlay.parent as? ViewGroup)?.removeView(overlay)
        }
    }

    private fun startPulse(view: View) {
        val scaleX = ObjectAnimator.ofFloat(view, View.SCALE_X, 0.94f, 1.04f)
        val scaleY = ObjectAnimator.ofFloat(view, View.SCALE_Y, 0.94f, 1.04f)
        val alpha = ObjectAnimator.ofFloat(view, View.ALPHA, 0.72f, 1f)
        listOf(scaleX, scaleY, alpha).forEach { animator ->
            animator.repeatCount = ValueAnimator.INFINITE
            animator.repeatMode = ValueAnimator.REVERSE
        }
        startupPulse = AnimatorSet().apply {
            playTogether(scaleX, scaleY, alpha)
            duration = 900L
            interpolator = AccelerateDecelerateInterpolator()
            start()
        }
    }

    private fun bindStartupPanelDrag(panel: View) {
        var startY = 0f
        var offsetY = 0f
        panel.setOnTouchListener { view, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    startY = event.rawY
                    offsetY = 0f
                    view.animate().cancel()
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    offsetY = max(0f, min(dp(180).toFloat(), event.rawY - startY))
                    view.translationY = offsetY
                    true
                }
                MotionEvent.ACTION_UP -> {
                    if (offsetY > dp(56)) {
                        finishOverlayNow()
                    } else {
                        view.animate().translationY(0f).setDuration(150).start()
                    }
                    true
                }
                MotionEvent.ACTION_CANCEL -> {
                    view.animate().translationY(0f).setDuration(150).start()
                    true
                }
                else -> false
            }
        }
    }

    private fun finishOverlayNow() {
        hideStartupOverlay()
        finish()
        overridePendingTransition(0, 0)
    }

    private fun startupCopy(): StartupCopy {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val storedLocale = prefs.getString("flutter.v2.settings.locale", "system")
        val language = when (storedLocale) {
            "en" -> "en"
            "tr" -> "tr"
            else -> deviceLanguage()
        }
        return if (language == "tr") {
            StartupCopy(
                title = "Kaydediliyor",
                message = "Paylaşım Marky’ye aktarılıyor.",
                action = "Kaydediliyor...",
            )
        } else {
            StartupCopy(
                title = "Saving",
                message = "Sending the shared item to Marky.",
                action = "Saving...",
            )
        }
    }

    private fun deviceLanguage(): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val locales = LocaleList.getDefault()
            val locale = if (locales.size() == 0) null else locales.get(0)
            locale?.language?.lowercase() ?: "en"
        } else {
            Locale.getDefault().language.lowercase()
        }
    }

    private data class StartupCopy(
        val title: String,
        val message: String,
        val action: String,
    )

    private fun dp(value: Int): Int {
        return (value * resources.displayMetrics.density).toInt()
    }
}


