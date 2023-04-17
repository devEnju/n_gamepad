package com.marvinvogl.n_gamepad

import android.view.KeyEvent
import android.view.MotionEvent

class Dpad : Control(0b00001000) {
    private val data = IntArray(2)

    private var x = 0
    private var y = 0

    fun onEvent(keyCode: Int, event: KeyEvent): Boolean {
        when (keyCode) {
            KeyEvent.KEYCODE_DPAD_CENTER -> {
                data[0] = 0
                data[1] = 0
            }
            KeyEvent.KEYCODE_DPAD_LEFT -> {
                data[0] = -1
            }
            KeyEvent.KEYCODE_DPAD_RIGHT -> {
                data[0] = 1
            }
            KeyEvent.KEYCODE_DPAD_UP -> {
                data[1] = -1
            }
            KeyEvent.KEYCODE_DPAD_DOWN -> {
                data[1] = 1
            }
        }

        if (x != data[0] || y != data[1]) {
            x = data[0]
            y = data[1]

            return prepareMotionData(MotionListener.buffer)
        }
        return false
    }

    fun onEvent(event: MotionEvent): Boolean {
        if (event.action == MotionEvent.ACTION_MOVE) {
            data[0] = event.getAxisValue(MotionEvent.AXIS_HAT_X).toInt()
            data[1] = event.getAxisValue(MotionEvent.AXIS_HAT_Y).toInt()

            if (x != data[0] || y != data[1]) {
                x = data[0]
                y = data[1]

                return prepareMotionData(MotionListener.buffer)
            }
        }
        return false
    }

    private fun prepareMotionData(buffer: ControlBuffer): Boolean {
        sink?.success(data)

        if (transmission) {
            buffer.bitfield += bitmask
            buffer.putIntData(data)

            return true
        }
        return false
    }
}
