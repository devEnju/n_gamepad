package com.marvinvogl.n_gamepad

import android.view.KeyEvent

class Button(
    private val data: Char,
) : Control(0b00000100) {
    private var state = false

    fun onEvent(event: KeyEvent): Boolean {
        if (event.action == KeyEvent.ACTION_DOWN) {
            if (!state) {
                state = true

                return prepareKeyDownData(event.deviceId, KeyListener.buffer)
            }
        }
        if (event.action == KeyEvent.ACTION_UP) {
            if (state) {
                state = false

                return prepareKeyUpData(event.deviceId, KeyListener.buffer)
            }
        }
        return false
    }

    private fun prepareKeyDownData(id: Int, buffer: ControlBuffer): Boolean {
        Handler.button.sink?.success(listOf(data.code, id, state))

        if (transmission) {
            buffer.bitfield = bitmask
            buffer.putCharData(data)

            return true
        }
        return false
    }

    private fun prepareKeyUpData(id: Int, buffer: ControlBuffer): Boolean {
        Handler.button.sink?.success(listOf(data.code, id, state))

        if (transmission) {
            buffer.bitfield = bitmask
            buffer.putCharData(data.uppercaseChar())

            return true
        }
        return false
    }
}
