package com.marky.app.marky

internal interface ShareOverlayHost {
    fun attach()
    fun onResume()
    fun onPause()
    fun onStop()
    fun destroy()
}
