package com.marvinvogl.n_gamepad

import android.view.InputDevice
import android.view.MotionEvent
import android.view.View
import android.view.View.OnGenericMotionListener

class MotionListener(
    private val connection: Connection,
) : OnGenericMotionListener {
    companion object {
        val buffer = ControlBuffer(28, 2, 0b1000)
    }

    override fun onGenericMotion(v: View?, event: MotionEvent?): Boolean {
        if (event != null) {
            if (event.isFromSource(InputDevice.SOURCE_JOYSTICK)) {
                Gamepad.dpad.onEvent(event)

                connection.send(KeyListener.buffer)

                Gamepad.triggerLeft.onEvent(event)
                Gamepad.triggerRight.onEvent(event)
                Gamepad.joystickLeft.onEvent(event)
                Gamepad.joystickRight.onEvent(event)

                return connection.send(buffer)
            }
        }
        return false
    }
}
