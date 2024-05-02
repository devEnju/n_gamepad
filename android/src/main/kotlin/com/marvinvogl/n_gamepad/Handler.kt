package com.marvinvogl.n_gamepad

import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler

class Handler : StreamHandler {
    companion object {
        val button = Handler()
        val dpad = Handler()
        val joystick = Handler()
        val trigger = Handler()
    }

    private var count = 0

    var sink: EventSink? = null
        private set

    override fun onListen(arguments: Any?, events: EventSink?) {
        count++

        sink = events
    }

    override fun onCancel(arguments: Any?) {
        count--

        if (count == 0) {
            sink = null
        }
    }
}
