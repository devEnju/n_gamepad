package com.marvinvogl.n_gamepad;

import android.view.KeyEvent;

import androidx.annotation.Keep;

@Keep
public final class GamepadBridge {
  public static void createDevice() {
    Gamepad gamepad = new Gamepad();

    gamepad.getButton().put(KeyEvent.KEYCODE_BUTTON_A, false);
    gamepad.getButton().put(KeyEvent.KEYCODE_BUTTON_B, false);
    gamepad.getButton().put(KeyEvent.KEYCODE_BUTTON_X, false);
    gamepad.getButton().put(KeyEvent.KEYCODE_BUTTON_Y, false);
    gamepad.getButton().put(KeyEvent.KEYCODE_BUTTON_L1, false);
    gamepad.getButton().put(KeyEvent.KEYCODE_BUTTON_R1, false);
    gamepad.getButton().put(KeyEvent.KEYCODE_BUTTON_L2, false);
    gamepad.getButton().put(KeyEvent.KEYCODE_BUTTON_R2, false);
    gamepad.getButton().put(KeyEvent.KEYCODE_BUTTON_THUMBL, false);
    gamepad.getButton().put(KeyEvent.KEYCODE_BUTTON_THUMBR, false);
    gamepad.getButton().put(KeyEvent.KEYCODE_BUTTON_SELECT, false);
    gamepad.getButton().put(KeyEvent.KEYCODE_BUTTON_START, false);
  }

  public static void resetControl(String string) {

  }
}
