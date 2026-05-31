package com.marvinvogl.n_gamepad;

import androidx.annotation.Keep;

@Keep
public interface MotionEventListener {
  void onMotionEvent(int keyCode, int action);
}
