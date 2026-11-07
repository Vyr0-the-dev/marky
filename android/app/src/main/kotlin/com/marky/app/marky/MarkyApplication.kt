package com.marky.app.marky

import io.flutter.FlutterInjector
import io.flutter.app.FlutterApplication

class MarkyApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        try {
            val loader = FlutterInjector.instance().flutterLoader()
            loader.startInitialization(this)
        } catch (_: Throwable) {}
    }
}
