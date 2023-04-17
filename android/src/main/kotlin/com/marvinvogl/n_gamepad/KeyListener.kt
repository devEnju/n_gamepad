package com.marvinvogl.n_gamepad

import android.view.InputDevice
import android.view.KeyEvent
import android.view.View
import android.view.View.OnKeyListener

class KeyListener(
    private val observer: GamepadObserver,
    private val gamepad: Gamepad,
    private val connection: Connection,
) : OnKeyListener {
    companion object {
        val buffer = ControlBuffer(1)
    }

    override fun onKey(v: View?, keyCode: Int, event: KeyEvent?): Boolean {
        if (event != null) {
            event.dispatch(observer.activity, null, null)

            observer.flutterView.dispatchKeyEvent(event)

            if (event.source and InputDevice.SOURCE_GAMEPAD == InputDevice.SOURCE_GAMEPAD) {
                gamepad.button[keyCode]?.onEvent(event) ?: return false

                return connection.send(buffer)
            }

            if (event.source and InputDevice.SOURCE_DPAD == InputDevice.SOURCE_DPAD) {
                gamepad.dpad.onEvent(keyCode, event)

                return connection.send(MotionListener.buffer)
            }
        }
        return false
    }
}
