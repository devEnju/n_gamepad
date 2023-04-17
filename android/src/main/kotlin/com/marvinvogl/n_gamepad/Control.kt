package com.marvinvogl.n_gamepad

import android.view.MotionEvent
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import kotlin.math.abs

abstract class Control(
    val bitmask: Int,
) : StreamHandler {
    var sink: EventSink? = null

    private var stop = true
    private var block = true

    val transmission get() = stop && block

    override fun onListen(arguments: Any?, events: EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    open fun stop() {
        stop = false
    }

    open fun block() {
        block = false
    }
    
    open fun resume(safe: Boolean): Boolean {
        if (!safe) {
            val temp = transmission
            stop = true
            block = true
            return !temp
        }
        block = false
        return transmission
    }

    fun MotionEvent.getAxisValueWithMotionRange(axis: Int): Float {
        val value = getAxisValue(axis)
        val flat = device.getMotionRange(axis, source)?.flat ?: return value

        if (abs(value) > flat) {
            return value
        }
        return 0f
    }
}
