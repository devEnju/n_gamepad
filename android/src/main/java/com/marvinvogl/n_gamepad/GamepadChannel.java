package com.marvinvogl.n_gamepad;

import androidx.annotation.Keep;

@Keep
public final class GamepadChannel {
  private static KeyCallable key;
  private static MotionCallable motion;

  public static KeyCallable assignKeyCallable(KeyCallable callable) {
    key = callable;
    return callable;
  }

  public static MotionCallable assignMotionCallable(MotionCallable callable) {
    motion = callable;
    return callable;
  }

  public static void clearListener() {
    key = null;
    motion = null;
  }

  static KeyCallable getKey() {
    return key;
  }

  static MotionCallable getMotion() {
    return motion;
  }
}
