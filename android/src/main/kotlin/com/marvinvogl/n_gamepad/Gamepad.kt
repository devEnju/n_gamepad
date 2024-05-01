package com.marvinvogl.n_gamepad

import android.view.KeyEvent

class Gamepad {
    val gyroscope = Gyroscope()

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
    val joystickLeft = Joystick(Hand.LEFT)
    val joystickRight = Joystick(Hand.RIGHT)
    val triggerLeft = Trigger(Hand.LEFT, button[KeyEvent.KEYCODE_BUTTON_L2]!!)
    val triggerRight = Trigger(Hand.RIGHT, button[KeyEvent.KEYCODE_BUTTON_R2]!!)

    val control = mapOf(
        "gyro" to gyroscope,
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
