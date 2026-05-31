package com.marvinvogl.n_gamepad;

import androidx.annotation.Keep;

@Keep
public interface MotionCallback {
  void onMotionEvent(int keyCode, int action);
}
