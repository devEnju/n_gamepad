package com.marvinvogl.n_gamepad

import android.view.KeyEvent

class Button(
    private val data: Char,
) : Control(0b00000100) {
    private var isPressed = false

    fun onEvent(event: KeyEvent): Boolean {
        if (event.action == KeyEvent.ACTION_DOWN) {
            if (!isPressed) {
                isPressed = true

                return prepareKeyDownData(KeyListener.buffer)
            }
        }
        if (event.action == KeyEvent.ACTION_UP) {
            if (isPressed) {
                isPressed = false

                return prepareKeyUpData(KeyListener.buffer)
            }
        }
        return false
    }

    private fun prepareKeyDownData(buffer: ControlBuffer): Boolean {
        if (transmission) {
            buffer.bitfield = bitmask
            buffer.putCharData(data)

            return true
        }
        return false
    }

    private fun prepareKeyUpData(buffer: ControlBuffer): Boolean {
        if (transmission) {
            buffer.bitfield = bitmask
            buffer.putCharData(data.uppercaseChar())

            return true
        }
        return false
    }
}
