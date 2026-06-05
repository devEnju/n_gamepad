package com.marvinvogl.n_gamepad;

import androidx.annotation.Keep;

@Keep
public interface MotionCallable {
  void callback(int keyCode, int action);
}
