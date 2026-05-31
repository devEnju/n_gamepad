package com.marvinvogl.n_gamepad;

import androidx.annotation.Keep;

@Keep
public final class GamepadChannel {
  private static KeyEventListener listener;

  public static KeyEventListener assignListener(KeyEventListener keyListener) {
    listener = keyListener;
    return listener;
  }

  public static void clearListener() {
    listener = null;
  }

  public static boolean dispatchKeyEvent(int keyCode, int action) {
    if (listener != null) {
      listener.onKeyEvent(keyCode, action);
      return true;
    }

    return false;
  }
}
