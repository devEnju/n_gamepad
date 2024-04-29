package com.marvinvogl.n_gamepad

import android.view.MotionEvent

class Joystick(
    private val hand: Hand,
) : Control(hand.joystick) {
    private val data = FloatArray(2)

    private var x = 0f
    private var y = 0f

    fun onEvent(event: MotionEvent): Boolean {
        if (event.action == MotionEvent.ACTION_MOVE) {
            data[0] = event.getAxisValueWithMotionRange(hand.axisX)
            data[1] = event.getAxisValueWithMotionRange(hand.axisY)

            if (x != data[0] || y != data[1]) {
                x = data[0]
                y = data[1]

                return prepareMotionData(event.deviceId, MotionListener.buffer)
            }
        }
        return false
    }

    private fun prepareMotionData(id: Int, buffer: ControlBuffer): Boolean {
        sink?.success(listOf(id, x, y))

        if (transmission) {
            buffer.bitfield += bitmask
            buffer.putFloatData(data)

            return true
        }
        return false
    }
}
