package com.marvinvogl.n_gamepad

import android.util.SparseBooleanArray
import android.util.SparseIntArray
import android.view.KeyEvent
import androidx.core.util.size

class Gamepad {
    val id: Int = list.size
    val button = SparseBooleanArray()

    init {
        list.add(this)
    }
    companion object {
        private val list = mutableListOf<Gamepad>()
        private val map = SparseIntArray()

        val check get() = list.isEmpty()

        fun registerDevice(id: Int): Gamepad? {
            val count = map.size
            val index = map.get(id, count)

            // if (offline) before putting new devices in
            if (index != count) {
                return list[index]
            }
            if (index < list.size) {
                map.put(id, index)
                return list[index]
            }
            return null
        }


        val gyroscope = Gyroscope()
        val accelerometer = Accelerometer()

        val button = mapOf(
            KeyEvent.KEYCODE_BUTTON_A to Button('a'),
            KeyEvent.KEYCODE_BUTTON_B to Button('b'),
            KeyEvent.KEYCODE_BUTTON_X to Button('x'),
            KeyEvent.KEYCODE_BUTTON_Y to Button('y'),
            KeyEvent.KEYCODE_BUTTON_L1 to Button('l'),
            KeyEvent.KEYCODE_BUTTON_R1 to Button('r'),
            KeyEvent.KEYCODE_BUTTON_L2 to Button('u'),
            KeyEvent.KEYCODE_BUTTON_R2 to Button('v'),
            KeyEvent.KEYCODE_BUTTON_THUMBL to Button('t'),
            KeyEvent.KEYCODE_BUTTON_THUMBR to Button('z'),
            KeyEvent.KEYCODE_BUTTON_SELECT to Button('c'),
            KeyEvent.KEYCODE_BUTTON_START to Button('s'),
        )

        val dpad = Dpad()
        val triggerLeft = Trigger(Hand.LEFT, button[KeyEvent.KEYCODE_BUTTON_L2]!!)
        val triggerRight = Trigger(Hand.RIGHT, button[KeyEvent.KEYCODE_BUTTON_R2]!!)
        val joystickLeft = Joystick(Hand.LEFT)
        val joystickRight = Joystick(Hand.RIGHT)

        val control = mapOf(
            "gyroscope" to gyroscope,
            "accelerometer" to accelerometer,
            "a" to button[KeyEvent.KEYCODE_BUTTON_A]!!,
            "b" to button[KeyEvent.KEYCODE_BUTTON_B]!!,
            "x" to button[KeyEvent.KEYCODE_BUTTON_X]!!,
            "y" to button[KeyEvent.KEYCODE_BUTTON_Y]!!,
            "l" to button[KeyEvent.KEYCODE_BUTTON_L1]!!,
            "r" to button[KeyEvent.KEYCODE_BUTTON_R1]!!,
            "zl" to triggerLeft,
            "zr" to triggerRight,
            "tl" to button[KeyEvent.KEYCODE_BUTTON_THUMBL]!!,
            "tr" to button[KeyEvent.KEYCODE_BUTTON_THUMBR]!!,
            "jl" to joystickLeft,
            "jr" to joystickRight,
            "select" to button[KeyEvent.KEYCODE_BUTTON_SELECT]!!,
            "start" to button[KeyEvent.KEYCODE_BUTTON_START]!!,
            "dpad" to dpad,
            "up" to dpad,
            "down" to dpad,
            "left" to dpad,
            "right" to dpad,
        )
    }
}
