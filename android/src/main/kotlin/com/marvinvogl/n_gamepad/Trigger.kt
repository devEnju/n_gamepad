package com.marvinvogl.n_gamepad

import android.view.MotionEvent

class Trigger(
    private val hand: Hand,
    private val button: Button,
) : Control(hand.trigger) {
    private val data = FloatArray(1)

    private var z = 0f

    fun onEvent(event: MotionEvent): Boolean {
        if (event.action == MotionEvent.ACTION_MOVE) {
            data[0] = event.getAxisValueWithMotionRange(hand.axisZ)

            if (data[0] == 0f) {
                data[0] = event.getAxisValueWithMotionRange(hand.axis)
            }

            if (z != data[0]) {
                z = data[0]

                return prepareMotionData(event.deviceId, MotionListener.buffer)
            }
        }
        return false
    }

    private fun prepareMotionData(id: Int, buffer: ControlBuffer): Boolean {
        sink?.success(listOf(id, z))

        if (transmission) {
            buffer.bitfield += bitmask
            buffer.putFloatData(data)

            return true
        }
        return false
    }

    override fun stop() {
        button.stop()
        super.stop()
    }

    override fun block() {
        button.block()
        super.block()
    }

    override fun resume(safe: Boolean): Boolean {
        button.resume(safe)
        return super.resume(safe)
    }
}
