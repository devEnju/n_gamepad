package com.marvinvogl.n_gamepad;

import androidx.annotation.Keep;

@Keep
public final class GamepadChannel {
  private static KeyCallback key;
  private static MotionCallback motion;

  public static KeyCallback assignKeyCallback(KeyCallback callback) {
    key = callback;
    return callback;
  }

  public static MotionCallback assignMotionCallback(MotionCallback callback) {
    motion = callback;
    return callback;
  }

  public static void clearListener() {
    key = null;
    motion = null;
  }

  public static boolean dispatchKeyEvent(int keyCode, int action) {
    if (key != null) {
      key.onKeyEvent(keyCode, action);
      return true;
    }

    return false;
  }
}
