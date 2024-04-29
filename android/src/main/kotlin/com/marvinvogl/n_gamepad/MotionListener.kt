package com.marvinvogl.n_gamepad

import android.view.InputDevice
import android.view.MotionEvent
import android.view.View
import android.view.View.OnGenericMotionListener

class MotionListener(
    private val gamepad: Gamepad,
    private val connection: Connection,
) : OnGenericMotionListener {
    companion object {
        val buffer = ControlBuffer(26)
    }

    override fun onGenericMotion(v: View?, event: MotionEvent?): Boolean {
        if (event != null) {
            if (event.isFromSource(InputDevice.SOURCE_JOYSTICK)) {
                gamepad.dpad.onEvent(event)
                gamepad.joystickLeft.onEvent(event)
                gamepad.joystickRight.onEvent(event)
                gamepad.triggerLeft.onEvent(event)
                gamepad.triggerRight.onEvent(event)

                return connection.send(buffer)
            }
        }
        return false
    }
}
